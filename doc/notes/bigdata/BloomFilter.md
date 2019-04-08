## 算法描述

一个empty bloom filter是一个有m bits的bit array，每一个bit位都初始化为0。并且定义有k个不同的hash function，每个都以uniform random distribution将元素hash到m个不同位置中的一个。在下面的介绍中n为元素数，m为布隆过滤器或哈希表的slot数，k为布隆过滤器重hash function数。

## 添加一个元素

用k个hash function 将hash得到的bloom filter中的k个bit位 置为1。

## 查询元素是否存在

用k个hash function 将他的hash得到k个bit位，如果任意一位为0，则这个元素必不存在。

## 误判

当add 的元素过多，n/m（n元素数目 m 是bloom filter的bit数目） 过大，会导致false positive 此时就需要重新组建filter，但这种情况相对少见。

## 优势

### 时间
add 和 query 时间复杂度只有 O(k)
### 空间
对于一个有1%误报率和一个最优k值的布隆过滤器来说，无论元素的类型及大小，每个元素只需要9.6 bits来存储。

![](http://ww1.sinaimg.cn/large/006d4JA0ly1g1pebftymgj30lh0lkjs6.jpg)

当 -1/m 很大 并且趋于0的时候误判率会降低，n降低也会使误判率降低。


![](http://ww1.sinaimg.cn/large/006d4JA0ly1g1pfb746nkj30lp0q5ab3.jpg)


输入 1000w 误判率1% 
计算占用空间9000w bit 100M 这样 并且空间占用率50%
m = 9000w 
n = 1000w

hashfunction 0.7*9 = 7

