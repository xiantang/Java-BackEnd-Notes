## 背景:

刚来到以scala为技术栈的公司的时候，配置了半天环境，然后终于将项目起了起来，发现里面的代码很奇怪，没有任何循环，数据的操作是一个函数套着一个函数，十分令人疑惑，于是借着业务需求和这股好奇劲开始学习关于scala的内容。

## 目标:

1. 熟练运用项目中的异步操作 Future 变换 (同步思维转异步)
2. 熟悉 Play 框架能够熟练的翻文档解决问题
3. 熟练运用高阶函数 map flatMap 等操作

### 阶段 1:能写 Scala

这个阶段比较容易达到，就是首先需要阅读 《[Scala编程](https://www.douban.com/link2/?url=https%3A%2F%2Fbook.douban.com%2Fsubject%2F5377415%2F&query=scala+编程&cat_id=1001&type=search&pos=1)》前几章 或者 [推特scala课堂](https://twitter.github.io/scala_school/zh_cn/index.html) ，来了解scala的基本语法。但是在这个阶段仍然会有很多的坑，基本是在 IDEA 的提示 与 爆红下才能勉强的写代码。

### 阶段2: 知道函数式编程是什么东西

当你差不多写了半个月 Scala 之后，仍然好奇函数式编程是什么东西，这个时候你就可以去学习一些关于函数式编程的知识了，我的线路是先学习了 [programming-languages](https://www.coursera.org/learn/programming-languages/home/welcome) 这门入门课程，主要讲了一些关于函数式编程的基础知识,包括但不限于 闭包 高阶函数 尾递归 代数类型。 虽然语言不是Scala 但是这门课为我之后的函数式编程打下了一定的基础。 如果你在这门课上认真的完成了作业，后面的路会通畅很多。

### 阶段3:再深入的了解

到这个时候，你一定会听到一本十分有名的书《Scala 函数式编程》 这本书，很有可能在你没经历前几个阶段的时候，你就看了，但是发觉里面的内容十分抽象，便放弃了。现在你就可以大胆的去看它了，可以无痛的看到第六章。

再在下面，就会被更抽象的 Monad Factor 等概念所迷惑。

### 阶段4:持续学习基础

上面的阻塞其实还是因为对基础知识不够扎实，所以还是需要进一步的学习，这里推荐 Scala 语言作者的课程 [Functional Programming Principles in Scala](https://www.coursera.org/learn/progfun1/home/welcome) . 因为不是免费的，所以需要付费或者采用奖学金（咸鱼）来免费学习。这门课程虽然不及上面的 programming-languages 课程，但是比较困难的习题还是能提升FP的水平的。

### 阶段5:参与社区

这个时候你就可以继续去看 《Scala 函数式编程》 这本书了，因为你看完了上面的两门全英文课程所以英文也不会再惧怕就可以参与社区了，这里推荐几个比较好的社区，曾经给我过帮助的社区 https://gitter.im/scala/scala.   https://gitter.im/akka/akka , 如果对开源有兴趣，就可以给 akka 或者 Play 修复BUG了。

最后推荐一些给我过帮助的网站

[coursera.org](http://coursera.org/)  网课平台

https://www.playframework.com/ play 官网

https://stackoverflow.com/ scala 模块 基本99%的scala 问题都能在上面找到，前提是会搜索

https://github.com/ 找轮子