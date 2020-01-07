QS 接口调用频率限制 

**背景**

分析了一下之前 890 的事故，结合之前的代码逻辑聊一下吧.

因为我们服务端调用代码的逻辑为异步，所以在请求的过程中是没有阻塞的。



```scala
def usersList(projectId: Int, ai: String, groupId: String, field: String, attrList: Seq[String], start: Int, end: Int): Future[Seq[UserInfo]] = {
  var index = start
  val requests = new ArrayBuffer[GroupUsersRequest]()
  // todo: 一个登陆用户对应多个设备的情况下 total 小于实际设备数
  while (index < end) {
    val request = GroupUsersRequest(
      .......
   )
  } 
  // 同时向qs请求
  Future.traverse(requests.toList) { request =>
    requestInsight(request)
  }.map(_.flatten)
}
```



18 w 个用户数据 会被切分成为 180 个 1000为单位的查询请求，由于没有阻塞 所以每台机器会瞬间发送 45 个请求到qs，也就是几毫秒发 180 连接到 QS，最终这些请求会变成查询压力打到数据库，将数据打挂。



目前的解决方案 



```scala
@scala.annotation.tailrec
private def requestInsightBatch(index: Int, contexts: Seq[GroupUserRequestContext], result: Future[Seq[UserInfo]]): Future[Seq[UserInfo]] = {
  index match {
    case end if end >= contexts.size => result
    case i =>
      val currentResult = for {
        userInfos <- result
        next <- requestInsight(contexts(i))
      } yield userInfos ++ next
      val delayMills = ThreadLocalRandom.current().nextInt(configParams.qsRequestDelayMinMillis, configParams.qsRequestDelayMaxMillis)
      TimeUnit.MILLISECONDS.sleep(delayMills)
      requestInsightBatch(i + 1, contexts, currentResult)
  }
}
```

采用尾递归的方式，因为要让异步请求一个接一个的请求显然比较麻烦，这里相当于一个flatMap 接着一个 flatMap，然后中间再伴随着 1～5 秒的睡眠。

可以判断每次基本的睡眠时间会在 2.5 s 左右，那么4 台机器将会是 0.7 秒一个请求打到 QS 上 一分钟能打 85个请求，也就是能查8w5的用户每分钟。查询的速率还是比较慢，并且没有利用好QS的性能。



我的解决方案:

采用类似guava的 RateLimiter :

基于令牌桶算法的限流器 

```java
public class Test {

    static class Runner implements Runnable{

        private RateLimiter rateLimiter;
        private String name;
        public Runner(RateLimiter rateLimiter, String name) {
            this.rateLimiter = rateLimiter;
            this.name = name;
        }

        public void run() {
            while (true){
                double acquire = rateLimiter.acquire();
                System.out.println(name+ " current "+ System.currentTimeMillis() + "  wait" + acquire);
            }
        }
    }
    public static void main(String[] args) {
        RateLimiter rateLimiter = RateLimiter.create(0.5);
        Runner runner2 = new Runner(rateLimiter,"2");
        Runner runner1 = new Runner(rateLimiter,"1");
        Runner runner4 = new Runner(rateLimiter,"4");
        Runner runner5 = new Runner(rateLimiter,"5");
        Runner runner3 = new Runner(rateLimiter,"3");

        new Thread(runner1).start();
        new Thread(runner2).start();
        new Thread(runner3).start();
        new Thread(runner5).start();
        new Thread(runner4).start();

    }
}

```

以上示例，创建一个RateLimiter，指定每秒放0.5个令牌（2秒放1个令牌），其输出见下
1 current 1577935707363  wait0.0
3 current 1577935709366  wait1.99697
2 current 1577935711365  wait3.996949
5 current 1577935713366  wait5.995537
1 current 1577935715362  wait7.995519
4 current 1577935717365  wait9.993848

但是有个缺点就是没办法在多进程（多机器）内共享这个 RateLimiter 

我的解决方案是采用 Redis 来存储令牌,同时借鉴了 guava RateLimiter 的内部实现:

不是采用传统的每隔两秒放入一次令牌，而是使用一种懒计算的方式,只有在要获取令牌的时候才进行令牌数目计算操作:

```scala
case class RedisPermits(
                    name:String,
                    maxPermits: Long,
                    storePermits: Long,
                    intervalMillis: Long,
                    nextFreeTicketMillis: Long
                  ) {

}
```



这个令牌有几个需要注意的字段
name 令牌的名字 分布式锁的名字也与他有关
maxPermits 最大存储的令牌数
storePermits  存储的令牌数目
intervalMillis 每次放入令牌的间隔
nextFreeTicketMillis 下一次可以获取令牌的时间



我们的懒计算分为两种可能 

1. 现在可以获取令牌
2. 现在不能获取令牌

第一种情况就是初始化的时候 `nextFreeTicketMillis` 为 0 ,但是当前的redis 时间已经为

![image-20200102115023086](/Users/xiantang/Library/Application Support/typora-user-images/image-20200102115023086.png)

```scala
val newPermits = (now - permits.nextFreeTicketMillis) / permits.intervalMillis
val storedPermits = math.min(permits.maxPermits, newPermits + permits.storePermits)
```



因为我们要匀速的请求所以会将最大的存储的数目设置为 1. 也就是当第一次请求的时候就存储了一个令牌。



第二种情况就是现在还没有到达 `nextFreeTicketMillis`

![image-20200102120043445](/Users/xiantang/Library/Application Support/typora-user-images/image-20200102120043445.png)

```scala
val tobeSpend = Math.min(permits.storePermits, requiredPermits)
val freshPermits = requiredPermits - tobeSpend
val waitTime = freshPermits * permits.intervalMillis
val storePermits = permits.storePermits - tobeSpend
val nextFreeTicketMillis = permits.nextFreeTicketMillis + waitTime
```

会将 `nextFreeTicketMillis` 向后推需要睡眠的时间。

然后计算出等待的时间，并且睡眠 需要等待的时间;

```scala 
val lockName = name + ":lock"
    lockManager.lock(lockName).flatMap {
      case Some(lock) =>
        for {
          _ <- checkPermits();
          waitLength <- reserveAndGetWaitLength(permits);
          _ <- lockManager.unLock(lock)
        } yield {
          waitLength
        }
      case None =>
        throw new Exception(s"can not  get the lock , name :${lockName}")
    }
```



```scala 
 def acquire(permits: Int): Future[Double] = {
    for {
      microsToWait <- reserve(permits);
      _ <- Future {
        TimeUnit.MILLISECONDS.sleep(microsToWait)
      }
    } yield {
      microsToWait
    }

  }
```

