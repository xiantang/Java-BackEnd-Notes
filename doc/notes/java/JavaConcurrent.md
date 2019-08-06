# TODO
* 多线程的通信，同步方式
* volatile和synchronized的区别
* 乐观锁与悲观锁?
* 乐观锁它是怎么实现的?
* 悲观锁呢?

# Java并发

## 乐观锁 CAS

compare and swap(比较与交换)，是一种有名的无锁算法。不用锁的情况下实现多线程的变量同步，在没有线程阻塞
的情况下实现变量同步，也叫非阻塞同步。当多个线程尝试使用CAS同时更新同一个变量时，只有其中一个线程能更新变量的值，而其它线程都失败，失败的线程并不会被挂起，而是被告知这次竞争中失败，并可以再次尝试。适用于读较多的情况。    
三个操作数:

* 需要读写的内存值 V
* 进行比较的值（预期值） A
* 拟写入的新值 B
当且仅当预期值和内存值相等，将内存V修改为B，否则什么都不做。一般来说是一个自旋的操作，不断的重试。
* CAS, CPU指令，在大多数处理器架构，包括IA32、Space中采用的都是CAS指令，CAS的语义是“我认为V的值应该为A，如果是，那么将V的值更新为B，否则不修改并告诉V的值实际为多少”，



## 悲观锁
* 资源共享只给一个线程，其他线程阻塞，用完在给其他线程。
* 适用于写较多的情况。


## synchronized 使用场景

线程具有五大状态:
* 新建状态：新建线程对象，并没有调用start()方法之前。
* 就绪状态：调用start()方法之后线程就进入就绪状态，但是并不是说只要调用start()方法线程就马上变为当前线程。
* 运行状态：线程被设置为当前线程，开始执行run()方法。就是线程进入运行状态
* 阻塞状态：线程被暂停，比如说调用sleep()方法后线程就进入阻塞状态
* 死亡状态：线程执行结束

![](http://www.blogjava.net/images/blogjava_net/santicom/360%E6%88%AA%E5%9B%BE20110901211600850.jpg)

锁类型:
* 可重入锁（synchronized和ReentrantLock）：在执行对象中所有同步方法不用再次获得锁
* 可中断锁（synchronized就不是可中断锁，而Lock是可中断锁）：在等待获取锁过程中可中断
* 公平锁（ReentrantLock和ReentrantReadWriteLock）： 按等待获取锁的线程的等待时间进行获取，等待时间长的具有优先获取锁权利
* 读写锁（ReadWriteLock和ReentrantReadWriteLock）：对资源读取和写入的时候拆分为2部分处理，读的时候可以多线程一起读，写的时候必须同步地写


## Synchronized与Lock的区别

* synchronized关键字 Lock是接口
* Synchronized获取锁的线程执行完同步代码，释放锁，线程执行发生异常，jvm会让线程释放锁。Lock 在finally中必须释放锁，不然容易造成死锁。
* Synchronized无法判断锁状态，Lock可以判断。
* synchronized 少量同步，Lock可以提高线程进行读操作的效率（读写分离）

| 类型 | synchronized  | Lock |
|---| ----- | -------- |
|存在层次| Java的关键字，在jvm层次 | 一个类 |
|锁的释放| 获取锁执行完成同步代码，执行发生异常，会有一个monitorexit 来退出 | 必须在finally释放锁  |
|锁的获取|假设A线程获得锁，B线程等待。如果A线程阻塞，B线程会一直等待|分情况而定，Lock有多个锁获取的方式，具体下面会说道，大致就是可以尝试获得锁，线程可以不用一直等待|
| 锁状态 | 无法判断 |可以判断 |
| 锁类型 | 可重入 不可中断 非公平  |  可重入 可判断 可公平（两者皆可）   |


## synchronized 的锁优化

锁的升级策略:    
偏向锁->轻量级锁->重量级锁
![](https://images2015.cnblogs.com/blog/820406/201604/820406-20160424163618101-624122079.png)
    偏向锁、轻量锁的状态转换以及对象MarkWord的关系
### 偏向锁

无竞争的情况下的同步原语，在无竞争的情况下吧整个同步操作消除。如果一个线程获得了锁，那么锁就会进入偏向模式Mark Word结构就会变成偏向锁结构，当线程再次请求的时候，就不需要任何同步操作。

### 轻量级锁
轻量级锁能够提升程序性能的依据是“对绝大部分的锁，在整个同步周期内都不存在竞争”,轻量级锁所适应的场景是线程交替执行同步块的场合。


对象实例由对象头，实例数组组成，其中对象头包括markword和类型指针，如果是数组，还包括数组的长度。

HotSpot 虚拟机的对象头
| 类型 | 32位JVM  | 64位JVM |
|---| ----- | -------- |
|markword| 32bit | 64bit |
|类型指针| 32bit | 64bit，开启指针压缩时为32bit  |
|数组长度(可选)| 32bit |32bit |

对象头的markword:
![](https://img-blog.csdnimg.cn/20190115142040348.png)

轻量锁操作之前的堆栈与对象的状态:
![](https://images2015.cnblogs.com/blog/820406/201604/820406-20160424105442866-2111954866.png)

当代码进入同步块的时候，如果同步没有被锁定(标志位为01)首先迅即会将当前栈帧中建立一个名为锁记录的空间LockRecord，拷贝指定对象的markword。
![](https://images2015.cnblogs.com/blog/820406/201604/820406-20160424105540163-1019388398.png)
虚拟机将使用CAS操作尝试将对象的markword 更新指向
当前线程的栈。如果更新失败就说明这个对象已经被其他线程占用。
如果有两个线程同时抢夺一个锁，就会将锁的标识变为"10",MarkWord 中存储的就是重量锁(互斥量)的指针，后面等待的线程也要进入阻塞状态。

### 锁的消除

```java
public String concatString(String s1, String s2, String s3) {
        return s1 + s2 + s3;
       
    }
```
在JDK1.5 之后的版本会被优化成为StringBuilder的连续append()

因为对象不会被发布都这个方法之外的区域

```java
public java.lang.String concatString(java.lang.String, java.lang.String, java.lang.String);
    Code:
       0: new           #2                  // class java/lang/StringBuilder
       3: dup
       4: invokespecial #3                  // Method java/lang/StringBuilder."<init>":()V
       7: aload_1
       8: invokevirtual #4                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      11: aload_2
      12: invokevirtual #4                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      15: aload_3
      16: invokevirtual #4                  // Method java/lang/StringBuilder.append:(Ljava/lang/String;)Ljava/lang/StringBuilder;
      19: invokevirtual #5                  // Method java/lang/StringBuilder.toString:()Ljava/lang/String;
```
也就是所谓的栈封闭，编译器观察sb对象发现这个作用域在方法内部，就是说sb对象的引用是不会`逃逸`到concatString()方法外部。

## 什么是线程不安全
线程安全：当多线程访问某个类的时候，这个类始终能表现出正确的行为，就叫做线程安全。
非线程安全是指多线程操作同一个对象可能会出现问题。

## 对象的共享
 volatile 变量不会被缓存存在寄存器或者其他处理器不可见的地方，在读取volatile变量的时候总会返回最新写入的值。
注意:volatile 语义不能保证递增操作的原子性。

发布对象(publish):
* 对象引用保存到一个公有的静态变量中。
* 用非私有方法返回一个引用。
* 当把一个对象传入给一个外部方法的时候，相当于发布这个对象。
* 发布一个内部类的实例。

### final域

final域可以确保初始化过程的安全性



## 线程池

### 管理队列任务

ThreadPoolExecutor 允许提供一个BlockingQueue 来保存等待执行的任务

主要有3中不同的队列

* 有界队列
    有助于避免资源耗尽的情况发生：
    * ArrayBlockingQueue
    * LinkedBlockingQueue
    * PriorityBlockingQueue   
    但是队列填满怎么办？
    使用**饱和策略**

* 无界队列
* 同步移交(Synchronous Handoff)队列
    对于非常大的或者无界的线程池，使用SynchronousQueue来避免任务排队,SynchronousQueue不是一个真正的队列，而是一种线程之间的移交机制。

## 条件谓词

* 通常都有一个条件谓词
* 在调用wait之前先测试条件谓词
* 调用wait的之前测试条件谓词，并且wait中返回时再次进行测试
* 调用wait notify notifyall 等方法的时候，一定要持有与条件队列相关的锁



### volatile 

Java编程语言允许线程访问共享变量，为了确保共享变量能被准确和一致地更新，线程应该确保通过排他锁单独获得这个变量。Java语言提供了volatile，在某些情况下比锁要更加方便。如果一个字段被声明成volatile，Java线程内存模型确保所有线程看到这个变量的值是一致的.

内存屏障：memory barriers  是一组处理器指令，实现对内存操作的顺序限制。

- 将当前处理器缓存行的数据写回系统内存
- 这个写回内存的操作会使其他CPU里缓存了该内存的数据无效

就是一个cpu向内存写入数据的时候，会让其他处理器通过嗅探的方式检查自己的数据是否过期了，如果过期就使他无效，如果存在修改这条缓存行的数据的时候，就重新从系统内存中把数据读到处理器缓存中。

实现原则:

- Lock前缀指令会引起处理器缓存回写到内存.
- 一个处理器的缓存回写到内存会导致其他处理器的缓存无效.

happens-before 原则

在JMM中，如果一个操作执行的结果需要对另一个操作可见，那么这两个操作之间必须要存在happens-before关
系。这里提到的两个操作既可以是在一个线程之内，也可以是在不同线程之间。

如果A线程的写操作a与B线程的读操作b之间存在happens-before关系，尽管a操作和b操作在不同的线程中执行，但JMM向程序员保证a操作将对b操作可见

程序员对于这两个操作是否真的被重排序并不关心，程序员关心的是程序执行时的语义不能被改变

![1562855661632](../../images/1562855661632.png)

as-if-serial语义把单线程程序保护了起来，遵守as-if-serial语义的编译器、runtime和处理器
共同为编写单线程程序的程序员创建了一个幻觉：单线程程序是按程序的顺序来执行的。as-
if-serial语义使单线程程序员无需担心重排序会干扰他们，也无需担心内存可见性问题。