非严格求值



```scala
  def getOrElse[B >: A](default: => B): B = this match{
    case None => default
    case Some(x) => x
  }
```

可以看到如果为 None 的情况下计算 default 的值，否则返回内部的值

这样能提高新能