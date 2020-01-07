### 创建本地分支推到服务器
创建新的本地分支 
`git checkout -b dd `

从远程拉取分支 
`git checkout -b dd remote/origin/dd`

创建远程分支
`git push origin dd:dd`   

### 切换远程服务地址 

删除远程服务器地址
`git remote rm origin`   

添加新的 
`git remote add  origin  https://github.com/xiantang/jdcrawler`

### 添加多个远程源

查看远程源  `git remote -v`

```
origin  ssh://a.git (fetch)
origin  ssh://a.git (push)
```

添加一个名为 us 远程源

`git remote add us ssh://c.git`

查看远程源 `git remote -v`

```
origin  ssh://a.git (fetch)
origin  ssh://a.git (push)
us      ssh://b.git (fetch)
us      ssh://b.git (push)

```

获取所有远程分支到本地 `git fetch --all`



复原submodule

`git submodule foreach --recursive git reset --hard`
`git submodule update --init --recursive`









背景:

刚来到growingio的时候，配置了半天环境，然后终于将项目起了起来，发现里面的代码很奇怪，没有任何循环，数据的操作是一个函数套着一个函数，十分令人疑惑，于是借着业务需求和这股好奇劲开始学习关于scala的内容。



目标:

1.  熟练运用项目中的异步操作 Future 变换 (同步思维转异步)
2.  熟悉 Play 框架能够熟练的翻文档解决问题
3. 熟练运用高阶函数 map flatMap 等操作



阶段 1:能写 Scala

这个阶段比较容易达到，就是首先需要阅读 《[Scala编程](https://www.douban.com/link2/?url=https%3A%2F%2Fbook.douban.com%2Fsubject%2F5377415%2F&query=scala+编程&cat_id=1001&type=search&pos=1)》前几章 或者 https://twitter.github.io/scala_school/zh_cn/index.html scala 课堂，来了解scala的基本语法。但是在这个阶段仍然会有很多的坑，基本是在 IDEA 的提示 与 爆红下才能勉强的写代码。

阶段2: 知道函数式编程是什么东西

当你差不多写了半个月 Scala 之后，仍然好奇函数式编程是什么东西，这个时候你就可以去学习一些关于函数式编程的知识了，我的线路是先学习了 https://www.coursera.org/learn/programming-languages/home/welcome 这门入门课程，主要讲了一些关于函数式编程的基础知识,包括但不限于 闭包 高阶函数 尾递归 代数类型。 虽然语言不是Scala 但是这门课为我之后的函数式编程打下了一定的基础。 如果你在这门课上认真的完成了作业，后面的路会通畅很多。

阶段3:再深入的了解

到这个时候，你一定会听到一本十分有名的书《Scala 函数式编程》 这本书，很有可能在你没经历前几个阶段的时候，你就看了，但是发觉里面的内容十分抽象，便放弃了。现在你就可以大胆的去看它了，可以无痛的看到第六章。

再在下面，就会被更抽象的 Monad Factor 等概念所迷惑。

阶段4:持续学习基础

上面的阻塞其实还是因为对基础知识不够扎实，所以还是需要进一步的学习，这里推荐 Scala 语言作者的课程

