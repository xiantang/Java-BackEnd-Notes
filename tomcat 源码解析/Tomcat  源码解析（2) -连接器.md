在解释Tomcat 的NIO 连接器之前我们可以来聊一个Tomcat 的StringManage 类

# StringManage

StringManage 其实是Tomcat用来处理消息的公用类。

**其实思路就是每个包名对应一个Stringmanager对象，而非所有公用一个Stringmanager对象**！

Tomcat为每一个包提供一个StringManager实例，**相当于一个包一个单例的效果**

我们来康康这个一个包一个单例是如何实现的呢？

```java
    /**
     * Get the StringManager for a particular package and Locale. If a manager
     * for a package/Locale combination already exists, it will be reused, else
     * a new StringManager will be created and returned.
     *
     * @param packageName The package name
     * @param locale      The Locale
     */
    public static final synchronized StringManager getManager(
            String packageName, Locale locale) {

        Map<Locale,StringManager> map = managers.get(packageName);
        if (map == null) {
            map = new Hashtable<Locale, StringManager>();
            managers.put(packageName, map);
        }

        StringManager mgr = map.get(locale);
        if (mgr == null) {
            mgr = new StringManager(packageName, locale);
            map.put(locale, mgr);
        }
        return mgr;
    }
```

我简单的翻译一下注释，获取一个StringManage 实例根据包名和国际化的local对象,如果查找到就复用，如果未查找到，就创建一个并且返回。

Local 对象我们简要的说明一下，每一个Locale对象都代表了一个特定的地理、政治和文化地区。

Tomcat 是采用的获取默认的Local  `Locale.getDefault()`

这个单例是如何实现的呢？

StringManage 有一个静态的变量:

```java
private static final Map<String, Map<Locale,StringManager>> managers =
        new Hashtable<String, Map<Locale,StringManager>>();
```

他存储着Tomcat 所有包的 StringManage，用包名去作为key，value 是每个地区这个包的StringManage，可以根据Local 对象来获取，并且初始化的时候是空的，需要使用的时候才开始创建。

这就是每个包一个单例的实现。

下面我们来看看这个他是如何获取每个包的属性资源的：

```java
/**
    Get a string from the underlying resource bundle or return
    null if the String is not found.

    @param key to desired resource String
    @return resource String matching <i>key</i> from underlying
            bundle or null if not found.
    @throws IllegalArgumentException if <i>key</i> is null.
 */
public String getString(String key) {
    if(key == null){
        String msg = "key may not have a null value";

        throw new IllegalArgumentException(msg);
    }

    String str = null;

    try {
        // Avoid NPE if bundle is null and treat it like an MRE
        if (bundle != null) {
            str = bundle.getString(key);
        }
    } catch(MissingResourceException mre) {
        //bad: shouldn't mask an exception the following way:
        //   str = "[cannot find message associated with key '" + key +
        //         "' due to " + mre + "]";
        //     because it hides the fact that the String was missing
        //     from the calling code.
        //good: could just throw the exception (or wrap it in another)
        //      but that would probably cause much havoc on existing
        //      code.
        //better: consistent with container pattern to
        //      simply return null.  Calling code can then do
        //      a null check.
       // 这个注释好像有很棒的设计理念在里面
       // 如果你在设计底层的代码的时候
       // 需要去做一个异常处理 
       // 但是如果你的异常只是简单的像赋值一样覆盖掉
       // 其他开发者是不会知道这个问题的(没有注释)
       // 如果你向上抛出异常，是一个很不错的方式 
       // 但是会影响到一大片存在的代码 
       // 如果你返回一个空值会更好，
       // 调用的代码只需要添加一个空值检验就可以了
        str = null;
    }

    return str;
}
```

他内部调用了 bundle 对象的方法

bundle 是通过 `ResourceBundle.getBundle(bundleName, locale);` 来的来的

对于这个方法是这样的：

ResourceBundle支持多国语言：先把文件名取成类似这样myres_zh_CN.properties

然后：

```java
Locale locale1 = new Locale("zh", "CN");
ResourceBundle resb1 = ResourceBundle.getBundle("myres", locale1);
resb1.getString("aaa");
```

有了bundle 对象之后我们就能够通过getString()来获得对应的异常消息了。



# 请求处理的流程

Tomcat 对于Poller 感知到的触发了感兴趣的事件的 socketChannel 会调用Poller的 processKey 方法

```java
while (iterator != null && iterator.hasNext()) {
  SelectionKey sk = iterator.next();
  KeyAttachment attachment = (KeyAttachment)sk.attachment();
  // Attachment may be null if another thread has called
  // cancelledKey()
  if (attachment == null) {
    iterator.remove();
  } else {
    attachment.access();
    iterator.remove();
    processKey(sk, attachment);
  }
}//while
```

紧接着会通过processKey 调用processSocket 方法调用线程池来执行对应的任务

```java
SocketProcessor sc = processorCache.poll();
if ( sc == null ) sc = new SocketProcessor(socket,status);
else sc.reset(socket,status);
if ( dispatch && getExecutor()!=null ){
  getExecutor().execute(sc);
}
```

并且我们可以发现Tomcat 为了提升效率为 SocketProcessor 也设置了缓存

```java
/**
     * Cache for SocketProcessor objects
     */
    protected ConcurrentLinkedQueue<SocketProcessor> processorCache = new ConcurrentLinkedQueue<SocketProcessor>() {}
```

SocketProcessor 线程也设置了复用的方法并且在任务执行完成之后清除引用并且压入队列：

```java
protected NioChannel socket = null;
protected SocketStatus status = null;

public SocketProcessor(NioChannel socket, SocketStatus status) {
  reset(socket,status);
}

public void reset(NioChannel socket, SocketStatus status) {
  this.socket = socket;
  this.status = status;
}

@Override
public void run() {
  boolean launch = false;
  synchronized (socket) {
    
    // Process the request from this socket
    if (status == null) {
      state = handler.process(
        (KeyAttachment) key.attachment(),
        SocketStatus.OPEN);
    } else {
      state = handler.process(
        (KeyAttachment) key.attachment(),
        status);
    }

      // 略
      socket = null;
      status = null;
      //return to cache
      processorCache.offer(this);
    }
  }

```

  这个 run 方法中就有我们最重要的一个调用，handler.process() 负责将Request 从SocketChannel 解析出来。

接着process 会调用 `state = processor.process(socket);`

并且这个 processor 对象也是用一个对象持来维护的，可以用来复用processor

```java
protected RecycledProcessors<P,S> recycledProcessors =
            new RecycledProcessors<P,S>(this);
protected static class RecycledProcessors<P extends Processor<S>, S>
  extends ConcurrentLinkedQueue<Processor<S>> {

  private static final long serialVersionUID = 1L;
  private transient AbstractConnectionHandler<S,P> handler;
  protected AtomicInteger size = new AtomicInteger(0);

  public RecycledProcessors(AbstractConnectionHandler<S,P> handler) {
    this.handler = handler;
  }

  @Override
  public boolean offer(Processor<S> processor) {
    int cacheSize = handler.getProtocol().getProcessorCache();
    boolean offer = cacheSize == -1 ? true : size.get() < cacheSize;
    //avoid over growing our cache or add after we have stopped
    boolean result = false;
    if (offer) {
      result = super.offer(processor);
      if (result) {
        size.incrementAndGet();
      }
    }
    if (!result) handler.unregister(processor);
    return result;
  }

  @Override
  public Processor<S> poll() {
    Processor<S> result = super.poll();
    if (result != null) {
      size.decrementAndGet();
    }
    return result;
  }

  @Override
  public void clear() {
    Processor<S> next = poll();
    while (next != null) {
      handler.unregister(next);
      next = poll();
    }
    super.clear();
    size.set(0);
  }
}
```

主要的方法也和之前的做法大同小异，使用一个队列来维护 processor 如果没有元素就新建元素放入队列，对于完成任务的process 对他进行reset() 然后重新入队，这样大大降低了空间，与 GC 的压力。

我们再来看看这个 AbstactHttp11Processor 的process 方法的实现吧:

代码十分的长，整个方法有200多行代码，看来Tomcat 也不是守开发规范的啊！

主要分为三段:

```java
 @Override
    public SocketState process(SocketWrapper<S> socketWrapper){
      // 1.解析请求行
      if (!getInputBuffer().parseRequestLine(keptAlive)) {
        if (handleIncompleteRequestLineRead()) {
          break;
        }
      } 
      // 略
      // 2.解析header
      if (!getInputBuffer().parseHeaders()) {
        // We've read part of the request, don't recycle it
        // instead associate it with the socket
        openSocket = true;
        readComplete = false;
        break;
      }
      
      if (!error) {
        try {
          rp.setStage(org.apache.coyote.Constants.STAGE_SERVICE);
          adapter.service(request, response); // 3.真正处理的方法 CoyoteAdapter
        }
      }
    }
```



