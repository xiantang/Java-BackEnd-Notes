# TODO
* 集合类的各个使用环境

# Java容器
## 集合体系结构

集合作为一个容器，可以存储多个元素,java提供了多种集合类。将集合类中共性的内容，不断向上抽取，最终形成了集合的体系结构。 
 ![](https://img-blog.csdn.net/20150501232236784)
 
 Map和Set接口继承Collection
 List继承ListIterator和Collection
 Collection和ListIterator继承Iterator
 
 ## List和队列的区别
 
 Queue接口与List、Set同一级别，都是继承了Collection接口。
 LinkedList实现了Queue接口，Queue接口窄化了LinkedList其他方法的访问，就是如果接口参数是Queue的话，只能访问Queue定义的方法。
 
 ### 阻塞队列
试图向一个满的队列或者一个空的阻塞队列存入一个值的时候会阻塞线程。在多线程合作的时候阻塞线程是一个很好的工具。

### HashMap 和 HashTable 还有ConcurrentHashMap的区别 以及扩容机制
HashTable 是传统的集合类 已经过时了，在Java4时候被重写了实现了Map接口。

* 相同:
    * 都实现了Map接口
* 不同:
    * 线程的安全性:HashMap不是synchronized的，HashTable是线程安全的。
    多个线程可以共享HashTable,没有正确同步的话，多个线程是无法贡献HashMap的。Java5 提出的`ConcurrentHashMap`是`HashTable`的替代，共享性更好。
    * HashMap可以接受`null`的key和value,HashTable不行。
    * HashMap的迭代器是fail-fast的迭代器，但是Hashtable的enumerator迭代器不是fail-fast的。当有其他线程更改了HashMap的结构，就会抛出`ConcurrentModificationException`。由于在同一时刻只有一个线程修改`ConcurrentHashMap`所以不需要抛出这个异常。
    * Hashtable 线程安全使用的是synchronized，因为这个是JVM关键字，是重型操作，所以在单线程下还是HashMap效率高。`ConcurrentHashMap`使用的是CAS技术，也就是乐观锁。当多个线程需要修改同一个变量时候只有其中一个线程能更新，其他线程都失败，失败的线程不会挂起，而是告知这次竞赛失败。先获取key的hashCode,如果是空的就初始化，初始化的时候如果`sizeCtl`被修改就直接yield当前线程。![](https://img-blog.csdn.net/20160318105849333) 如果CAS竞赛成功就创建新的table。

### 重写equals() 传什么参


1. 自反性：对于任意的引用值x，x.equals(x)一定为true。 
2.  对称性：对于任意的引用值x 和 y，当x.equals(y)返回true时， 　　y.equals(x)也一定返回true。 
3. 传递性：对于任意的引用值x、y和ｚ，如果x.equals(y)返回true， 　　并且y.equals(z)也返回true，那么x.equals(z)也一定返回true。 
4.  一致性：对于任意的引用值x 和 y，如果用于equals比较的对象信息没有被修 　　改，多次调用x.equals(y)要么一致地返回true，要么一致地返回false。 
5.  非空性：对于任意的非空引用值x，x.equals(null)一定返回false。 


### HashMap源码解析
 HashMap 主要用来存放键值对，它基于哈希表的Map接口实现，是常用的Java集合之一。
 * JDK1.8 之前由数组和链表组成，链表主要为了解决冲突
 * JDK1.8 之后在解决hash冲突的时候采取了较大变化，链表长度大于8链表转换为红黑树（log n）。
 * 初始容量16，尽量先预估自己的数据量来设置初始值。

 JDK1.8转换红黑树
 ![](https://camo.githubusercontent.com/20de7e465cac279842851258ec4d1ec1c4d3d7d1/687474703a2f2f6d792d626c6f672d746f2d7573652e6f73732d636e2d6265696a696e672e616c6979756e63732e636f6d2f31382d382d32322f36373233333736342e6a7067)

 当链表数组的容量大于初始容量的0.75的时候，散列将链表扩大为2倍，把原来的数组搬移到新的数组中。

 为什么0.75 

 * node 在 bin 中 遵循泊松分布
 *  用0.75 作为加载因子的时候
    * 0:    0.60653066
    * 1:    0.30326533
    * 2:    0.07581633
    * 3:    0.01263606
    * 4:    0.00157952
    * 5:    0.00015795
    * 6:    0.00001316
    * 7:    0.00000094
    * 8:    0.00000006

树化主要是为了避免hash攻击 并且hashmap 在扩容因子为0.75的情况下 
他的转换为树的概率是0.000006% 所以基本是不会转换为树的 
除非是刻意的将不同的对象设置为相同hashcode 的 hash碰撞攻击
