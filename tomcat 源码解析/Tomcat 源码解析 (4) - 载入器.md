# 载入器

Tomcat 如果使用的系统的类加载器去加载某个servlet 中所有需要使用的类，那么servlet 就可以访问所有的类，比如 Java 虚拟机中环境变量中CLASSPATH 指明路径下的所有类和库。servlet 应该只允许再入WEB-INF/class 中的目录，以及它的子目录下的类。

并且Tomcat 需要实现自定义类加载器的原因是因为为了提供自动重载的功能。类载入器会开启一个线程不断检查文件的时间戳。如果要实现重载入的功能就必须实现Reload 接口。在Tomcat 7 中已经将Reloader 接口合并入Loader 接口中。

​                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               

## WebAppLoader

