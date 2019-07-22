### 实现容器热加载机制

#### 什么是双亲委任模型？ 
双亲委派模型的工作过程是：如果一个类加载器收到了类加载的请求，他首先不会自己去尝试加载这个类，而是把这个请求委派父类加载器去完成。每一个层次的类加载器都是如此，因此所有的加载请求最终都应该传送到顶层的启动类加载器中，只有当父加载器反馈自己无法完成这个请求（他的搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载。

从Java 开发人员的角度来看，类加载还可以再细致一些，绝大部分Java 程序员都会使用以下 3 种系统提供的类加载器:

* 启动类加载器（Bootstrap ClassLoader）：这个类加载器复杂将存放在 JAVA_HOME/lib 目录中的，或者被-Xbootclasspath 参数所指定的路径种的，并且是虚拟机识别的（仅按照文件名识别，如rt.jar，名字不符合的类库即使放在lib目录下也不会重载）。
* 扩展类加载器（Extension ClassLoader）：这个类加载器由sun.misc.Launcher$ExtClassLoader实现，它负责夹杂JAVA_HOME/lib/ext 目录下的，或者被java.ext.dirs 系统变量所指定的路径种的所有类库。开发者可以直接使用扩展类加载器。
* 应用程序类加载器（Application ClassLoader）：这个类加载器由sun.misc.Launcher$AppClassLoader 实现。由于这个类加载器是ClassLoader 种的getSystemClassLoader方法的返回值，所以也成为系统类加载器。它负责加载用户类路径（ClassPath）上所指定的类库。开发者可以直接使用这个类加载器，如果应用中没有定义过自己的类加载器，一般情况下这个就是程序中默认的类加载器。



#### 双亲委派模型的好处

![](https://img-blog.csdn.net/20180508201301409?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2Rhbmd3YW5tYTY0ODk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

双亲委派模型的工作过程是：如果一个类加载器收到了类加载的请求，他首先不会自己去尝试加载这个类，而是把这个请求委派父类加载器去完成。每一个层次的类加载器都是如此，因此所有的加载请求最终都应该传送到顶层的启动类加载器中，只有当父加载器反馈自己无法完成这个请求（他的搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载。



#### 双亲委派是如何实现的呢？

```java

protected synchronized Class<?> loadClass(String name, boolean resolve)   throws ClassNotFoundException{  
    // First, check if the class has already been loaded  
    Class c = findLoadedClass(name);  
    if (c == null) {  
        try {  
            if (parent != null) {  
                c = parent.loadClass(name, false);  
            } else {  
                c = findBootstrapClassOrNull(name);  
            }  
        } catch (ClassNotFoundException e) {  
            // ClassNotFoundException thrown if class not found  
            // from the non-null parent class loader  
        }  
        if (c == null) {  
            // If still not found, then invoke findClass in order  
            // to find the class.  
            c = findClass(name);  
        }  
    }  
    if (resolve) {  
        resolveClass(c);  
    }  
    return c;  
}
```
先检查是否被加载过，如果没有加载就调用父加载器的 loadClass 方法,如果父加载为空就默认使用启动类加载器作为父加载器。如果父类加载器加载失败，就抛出ClassNotFoundException 异常，再调用自己的findClass方法进行加载。


#### 为什么要破坏双亲委派模型？





### ClassLoader.loadClass()与Class.forName()的区别

```java
// 如果单纯使用new和用forName 其实没有特别大的区别
        // 都会去调用静态代码块，不过用forName 可以对代码进行解耦
        // jdk 现在主要实现了一个 driver接口 但是由于数据库的差异
        // jdk 会将这个driver的接口的子类交给厂商去实现
        // 实际上new Driver new出来的是com.mysql.什么什么的Driver
        // 数据库的信息你写在配置文件里面
        // 运行时的实例就是数据库产商实现的东西
        new com.mysql.jdbc.Driver();
        String url = "jdbc:mysql://111.231.255.225:3306/db_example";
        Connection connection = DriverManager.getConnection(url, "root", "123456zjd");

        java.util.Enumeration<java.sql.Driver> driverEnumeration = DriverManager.getDrivers();
        java.sql.Driver driver1 = driverEnumeration.nextElement();

        System.out.println(driver1.getMajorVersion());
```

