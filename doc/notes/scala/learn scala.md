声明隐式转换

这里的问题是 2*r 等价于 2. 叫 r)，因此这是一个对 2 这个整数的方法调 用。 但Int类并没有一个接收Rational参数的乘法方法一一它没法有这样一 个方法，因为 Rational 类并不是 Scala类库中的标准类 

不过， Scala有另外一种方式来解决这个问题 :可以创建一个隐式转换( implicit conversion )，在需要时自动将整数转换成有理数 。 可以往解释器里添加行: 

```scala
implicit def inToRational(x :Int) = new Rational(x)
val r = new Rational(2,3)
println(2*r)
```



生成器

```scala
def scalaFiles =
  for {
    file <- fileHere
    if file.getName.endsWith(".sh")
  } yield file

scalaFiles
```

每次迭代生成一个可以被记住的值



# 函数和闭包



## 局部函数

既然现在 processLine 定义在 processFile 内部，我们还可以做另一项 改进 。 注意到 filename 和 width 被直接透传给助手函数，完全没有变吗?这 里的传递不是必须的，因为局部函数可以访问包含它们的函数的参数 。 可以直 接使用外部的 processFile 函数的参数.

```scala
object LongLines {
  def processFile(fileName :String, width:Int): Unit ={
    // 在函数内部定义函数 这样局部函数只在包含它的代码块中可见
    def processLine(line :String): Unit ={
      if (line.length > width) {
        print(fileName+": "+line.trim)
      }
    }
    val source = Source.fromFile(fileName)
    for(line <- source.getLines()){
      processLine(line)
    }
  }
}
```



## 一等函数

函数字面量: 存在于源码.

函数值:以对象的形式存在于运行时.

```scala
var increase = (x :Int) => x+1
```

=> 表示该函数将左侧的内容(任何整数X) 转换为右侧的内容(x +1)。 将任何整数x 映射成为x+1 的函数.





-J-javaagent:agent/skywalking-agent.jar=agent.service_name=growing-marketing

-javaagent:./agent/skywalking-agent.jar=agent.service_name=growing-marketing