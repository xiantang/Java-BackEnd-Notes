# Java IO
## StringBulider 和StringBuffer区别

* String ：字符串常量
* StringBuffer 字符串变量(线程安全)
* StringBuilder 字符串变量(非线程安全)

**StringBuilder 和 StringBuffer 还有 String 的区别**
* String是不可变对象 `public final class String`,每次改变等于生成了一个新的String对象。               
* StringBuffer是可变对象，每次改动都会对StringBuffer 对象本身进行改动。在某些情况下String 的改动被JVM解释称StringBuffer的拼接。
* StringBuffer是线程安全的，一个类似String的字符串缓存区，不能修改。
因为可以安全的用于多个线程，所以在实例上的操作就想是串行的。
    * append():加入到字符缓冲区的末尾。
    * insert():替换指定位置
* StringBuilder是StringBuffer的替换，在字符串缓冲区被单个线程使用的时候，优先使用该类。


# NIO

## 多路复用模型

一个线程去轮询多个socket的状态，只有当socket真正有读写事件的时候，才会真正调用实际的IO操作。   
另外多路复用 IO 为何比非阻塞 IO 模型的效率高是因为在非阻塞 IO 中，不断地询问 socket 状态
时通过用户线程去进行的，而在多路复用 IO 中，轮询每个 socket 状态是内核在进行的，这个效
率要比用户线程要高的多。

## Selector
Selector 类是 NIO 的核心类，Selector 能够检测多个注册的通道上是否有事件发生，如果有事
件发生，便获取事件然后针对每个事件进行相应的响应处理。

## 流与块的比较
面向块的IO系统以块的形式处理数据。每一个操作都在一步中产生或消费一个数据块。按块要比按流快的多，但面向块的IO缺少了面向流IO所具有的有雅兴和简单性。



Channel 是对于原IO流的模拟，来源和目的对象都必须通过Channel。Buffer实质是一个容器对象，发送给Channel 的所有对象都必须放到Buffer中。


## 同步、异步、阻塞与非阻塞


* 同步:就是一个任务的完成需要依赖另外一个任务时，只有等待被依赖的任务完成后，依赖的任务才能算完成，这是一种可靠的任务序列。
* 异步:是不需要等待被依赖的任务完成，只是通知被依赖的任务要完成什么工作，依赖的任务也立即执行，只要自己完成了整个任务就算完成了。

##  Linux IO 模型

![](https://static.oschina.net/uploads/img/201604/20144245_Wtld.png)

## 同步阻塞 IO（blocking IO）
用户空间的应用程序执行一个系统调用，会导致程序阻塞，什么都不干，直到数据准备好。
![](https://static.oschina.net/uploads/img/201604/20150405_VKYH.png)

## 同步非阻塞 IO（nonblocking IO）

 同步非阻塞就是 “每隔一会儿瞄一眼进度条” 的轮询（polling）方式。
 ![](https://static.oschina.net/uploads/img/201604/20152818_DXcj.png)

缺点:任务完成的响应延迟增大了，每隔一段时间才会轮询义词 read 操作，可能任务在两次轮询之间的任意时间完成。

## IO 多路复用（ IO multiplexing）

由于同步非阻塞方式需要不断主动轮询，轮询占据了很大一部分过程，轮询会消耗大量的CPU时间，而 “后台” 可能有多个任务在同时进行，人们就想到了循环查询多个任务的完成状态，只要有任何一个任务完成，就去处理它。如果轮询不是进程的用户态，而是有人帮忙就好了,就是所谓的 “IO 多路复用”

select 调用是内核级别的，select 轮询相对于非阻塞轮询的区别在于前者可以等待多个socket，能够实现对于过个IO端口的监控。
并且和阻塞IO的区别在于，select不是等到socket数据全部到达了再处理，而是有一部分数据就会调用用户线程处理。

当用户线程调用select,那么整个进程都会被block，内核会监控所有select负责的socket，如果任何一个socket准备好了，select返回，用户线程再调用read操作将数据从内核拷贝到用户线程。