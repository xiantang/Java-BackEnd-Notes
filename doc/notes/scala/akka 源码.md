

```scala
object Main1 extends App {
  val system = ActorSystem("HelloSystem")
  val jazzListener = system.actorOf(Props[Listener])
  val musicListener = system.actorOf(Props[Listener])
  system.eventStream.subscribe(jazzListener, classOf[Jazz]) // jazzListener 订阅 Jazz 事件
  system.eventStream.subscribe(musicListener, classOf[AllKindsOfMusic]) // musicListener 订阅 AllKindsOfMusic 以及它的子类 事件

  // 只有 musicListener 接收到这个事件
  system.eventStream.publish(Electronic("Parov Stelar"))

  // jazzListener 和 musicListener 都会收到这个事件
  system.eventStream.publish(Jazz("Sonny Rollins"))
}

```

## subscribe 逻辑

同步地将 subcriber 和 to 加入到 subscriptions 中，diff 应该是和之前的一次比较保证不会重复发送?

```scala
def subscribe(subscriber: Subscriber, to: Classifier): Boolean = subscriptions.synchronized {
  val diff = subscriptions.addValue(to, subscriber)
  addToCache(diff)
  diff.nonEmpty
}
```

![image-20200109114040999](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109114040999.png)

![image-20200109131215939](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109131215939.png)

addValue 中有个比较重要的方法，就是从 `subkeys` 也就是 subscribe 中到找对应的类。

可以将`subkeys` 想象为一个多叉树中的一个节点，节点的key为订阅源类型，value为所对应的订阅者 Actor

然后这个节点也有自己的`subkeys` 这些subkeys 为的key为上层类型的子类，同时订阅者是与是上层订阅者的拓展

![image-20200109140449787](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109140449787.png)

对于重复的订阅，他会做一次去重，类似于arc diff

对于 ` system.eventStream.subscribe(jazzListener, classOf[Jazz])`

![image-20200109120145086](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109120145086.png)

会产生一个这样的diff 然后加入到cache 中

cache 的数据结构是一个 `private var cache = Map.empty[Classifier, Set[Subscriber]]` Map 分别是订阅源和订阅者

对于 `system.eventStream.subscribe(musicListener, classOf[AllKindsOfMusic]) ` 

![image-20200109120406852](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109120406852.png)





## publish 逻辑

```scala
def publish(event: Event): Unit = {
    val c = classify(event)
    val recv =
      if (cache contains c) cache(c) // c will never be removed from cache
      else
        subscriptions.synchronized {
          if (cache contains c) cache(c)
          else {
            addToCache(subscriptions.addKey(c))
            cache(c)
          }
        }
    recv.foreach(publish(event, _))
  }
```

publish 逻辑较为简单，首先会从event中找出对应 className 

然后走缓存逻辑，如果不在缓存中存在，就将对应的 key 更新到subkeys 多叉树中，找到对应的订阅者，并且更新到cache 中。 

最后遍历 recv 调用publish函数 。

```scala
  protected def publish(event: Any, subscriber: ActorRef) = {
    if (sys == null && subscriber.isTerminated) unsubscribe(subscriber)
    else subscriber ! event
  }
```





# Actor 初始化

```scala
val pinger = system.actorOf(Props[Pinger], "pinger")
val ponger = system.actorOf(Props(classOf[Ponger], pinger), "ponger")
```

 会调用 ActorSystem 中的actorOf方法

```scala
def actorOf(props: Props): ActorRef =
if (guardianProps.isEmpty) guardian.underlying.attachChild(props, systemService = false)
else
throw new UnsupportedOperationException(
  "cannot create top-level actor from the outside on ActorSystem with custom user guardian")
```

会从守卫Actor 下面创建一个新的Child Actor

会调用下边的makeChild 方法:

Children.scala

```scala
val actor =
        try {
          val childPath = new ChildActorPath(cell.self.path, name, ActorCell.newUid())
          cell.provider.actorOf(
            cell.systemImpl,
            props,
            cell.self,
            childPath,
            systemService = systemService,
            deploy = None,
            lookupDeploy = true,
            async = async)
        } 

initChild(actor)
actor.start() // 绑定 actor 到 dispatcher 
actor  // 返回 actor ref
```



## Tell 实现

```scala
final def sendMessage(message: Any, sender: ActorRef): Unit =
  sendMessage(Envelope(message, sender, system))
```

将message 包装为信封，调用Cell 的 sendMessage 方法

是因为 Cell 实现了

![image-20200109195143660](/Users/xiantang/Library/Application Support/typora-user-images/image-20200109195143660.png)

Dispatch 特质

其实是执行的 Dispatch 特质中的 sendMessage 方法

```scala
def sendMessage(msg: Envelope): Unit =
    try {
      val msgToDispatch =
        if (system.settings.SerializeAllMessages) serializeAndDeserialize(msg)
        else msg

      dispatcher.dispatch(this, msgToDispatch)
    } catch handleException
```

但是我仍然有个问题，dispatcher 是我自己规定的dispather ？

再调用这个Actor 所对应的 dispatcher 的 dispatch 函数

```scala
protected[akka] def dispatch(receiver: ActorCell, invocation: Envelope): Unit = {
    val mbox = receiver.mailbox
    mbox.enqueue(receiver.self, invocation)
    registerForExecution(mbox, true, false)
  }
```

将信封丢入对应接收者的 mailbox 中，然后将 mbox 作为参数传入 registerForExecution 注册到线程池中。

而这个线程池就是我预设的线程池， dispacher 只是对这个线程池做一层封装。

```scala
protected[akka] override def registerForExecution(
      mbox: Mailbox,
      hasMessageHint: Boolean,
      hasSystemMessageHint: Boolean): Boolean = {
    if (mbox.canBeScheduledForExecution(hasMessageHint, hasSystemMessageHint)) { //This needs to be here to ensure thread safety and no races
      if (mbox.setAsScheduled()) {
        try {
          //!!!!
          executorService.execute(mbox)
          true
        } catch {
       		...
        }
      } else false
    } else false
  }
```

使用内部的线程池来执行这个 MailBox 对象

既然 MailBox 可以被执行 它一定实现了 Runnable 方法 来看看他的实现:

```scala 
override final def run(): Unit = {
    try {
      if (!isClosed) { //Volatile read, needed here
        processAllSystemMessages() //First, deal with any system messages
        processMailbox() //Then deal with messages
      }
    } finally {
      setAsIdle() //Volatile write, needed here
      dispatcher.registerForExecution(this, false, false)
    }
  }
```

来主要看一下 processMailbox 方法的实现吧