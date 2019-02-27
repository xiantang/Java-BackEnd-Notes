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


# Jvm

## 堆和栈的区别

* 功能不同
    * 堆存储Java中的对象（成员变量，局部变量，类变量）。
    * 栈用来存储局部变量（方法内部的变量）和方法。
* 共享性不同
    * 栈的内存是线程私有的。(方法相关的当然私有啊！！)
    * 堆的内存是线程共有的。
* 异常错误不同
    * 栈空间不足：java.lang.StackOverFlowError。 经典！
    * 堆空间不足：java.lang.OutOfMemoryError。对象存满了

### 栈的组成

栈三部分:
* 局部变量区
    * 结构:以一个字长为单位，从0开始计数的数组。
    * 类型为short、byte和char会被转换成为int
        long和double占据两个连续的元素。
    * 实例方法只是多了一个隐藏的this。
    * 获取数据直接取索引。
* 操作数栈
    * 和局部变量一样，也是字长为1的数组，不是通过索引是用出栈和入栈来决定的。还记得迪杰斯特拉吗？！
    ![](https://iamjohnnyzhuang.github.io/public/upload/4.png)
* 帧数据区
    * Java栈帧还需要一些数据来支持常量池的解析，正常方法的返回。
    * 处理方法的正常结束和异常终止。通过return来正常结束的话，就弹出当前的栈帧，恢复发起调用方法的栈。如果方法有返回值JVM就会将返回值压入调用方法的操作数栈中。
    * 处理异常:保存了一个对此方法异常引用表的引用。
* 栈的整个结构

    ```java
    public class Main {
    public static void addAndPrint(){
        double result = addTwoTypes(1, 88.88);
        System.out.println(result);
    }

    public static double addTwoTypes(int i, double d) {
        return i + d;
        }
    }
    ```
    
    
    过程快照：
    ![](https://iamjohnnyzhuang.github.io/public/upload/5.png)


如果是方法中的局部变量就存储在堆中。

### 堆
当一颗二叉树的每个节点都大于等于它的两个子节点时，称作堆有序。
用执政表示一个二叉树的话就是一个完全二叉树。

* 由上到下的堆有序:
    * 上浮:只要记住位置k节点的父亲节点是位置k/2
        * 插入元素：将新元素上浮到适合位置
    * 下沉:
        * 删除最大元素：从数组顶端删除最大元素，选择数组最后节点。


## GC

## 反射
**Java 反射机制**：在程序运行的时候，对于任意的一个类，都能够知道这个类的所有属性和方法，对于任意一个对象可以调用它的任意属性和方法这种动态获取信息以及动态调用对象的方法的功能叫做Java反射(reflect)。

# 数据库


# Java并发

## CAS
* CAS, CPU指令，在大多数处理器架构，包括IA32、Space中采用的都是CAS指令，CAS的语义是“我认为V的值应该为A，如果是，那么将V的值更新为B，否则不修改并告诉V的值实际为多少”，
* CAS是项乐观锁技术，当多个线程尝试使用CAS同时更新同一个变量时，只有其中一个线程能更新变量的值，而其它线程都失败，失败的线程并不会被挂起，而是被告知这次竞争中失败，并可以再次尝试。
* CAS有3个操作数，内存值V，旧的预期值A，要修改的新值B。当且仅当预期值A和内存值V相同时，将内存值V修改为B，否则什么都不做。
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


引用
* [ConcurrentHashMap实现原理-源码调试](https://blog.csdn.net/xuxu120/article/details/52326772)
* [HashMap和Hashtable的区别](http://www.importnew.com/7010.html)
* [Java关键字transient和volatile](https://dongruan00.iteye.com/blog/2090116)
* [String,StringBuffer与StringBuilder的区别??](https://blog.csdn.net/rmn190/article/details/1492013)
