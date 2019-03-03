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




