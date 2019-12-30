什么是函数式编程?

函数式编程：只用纯函数来构造程序。

什么是纯函数?

没有副作用的函数。

什么是副作用?

一个带有副作用的函数，不仅会简单的返回一个值，而且会干一些其他的事情。





非严格求值



```scala
  def getOrElse[B >: A](default: => B): B = this match{
    case None => default
    case Some(x) => x
  }
```

可以看到如果为 None 的情况下计算 default 的值，否则返回内部的值

这样能提高性能

