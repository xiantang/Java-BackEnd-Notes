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
