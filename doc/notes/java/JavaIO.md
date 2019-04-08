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