

* 第一公民 函数
* 闭包 
  *  lexical scope
* 高阶函数
* 柯里化





random (1,10)



![image-20191129190758229](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129190758229.png)



![image-20191129190236925](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129190236925.png)

闭包有一些前置知识需要知道

 lexical scope

![image-20191129191234476](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129191234476.png)

为什么要有 lexical scope？

![image-20191129191724741](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129191724741.png)

因为你想啊 如果变量是动态的 内部的x 会被外边定义的x 影响的话，那filter 函数将会失效

![image-20191129192023173](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129192023173.png)

当你用fold来实现一些更加具象的东西的时候

![image-20191129193025588](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129193025588.png)

你可以看到上面两个函数都是使用了私有数据 以f3 为例 hi, lo 的值在函数定义时候已经被设置好了，当传入的时候，以及运算的时候都不会被外部变量影响。

因为这个所以能够让这些 fold map filter 更有力量。



![image-20191129190608208](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129190608208.png)

![image-20191129190638068](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129190638068.png)

柯里化



![image-20191129194251416](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129194251416.png)

![image-20191129194526611](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129194526611.png)

![image-20191129194814552](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129194814552.png)

currying 的好处是

你可以缺省这些参数

采用 `sorted 3` 

他返回的是一个   `fn y=> fn z=> z>=y andalso y>=3` 的函数  

下面你也可以通过柯里化来实现 fold map filter 这些函数

![image-20191129195217784](/Users/xiantang/Library/Application Support/typora-user-images/image-20191129195217784.png)