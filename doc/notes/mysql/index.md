## 索引的类型:

### B-Tree 索引 
InnoDB 使用的是B+Tree   
![](btree.png)
 
根节点的槽中存放了指向子节点的指针，存储引擎根据这些指针向下查找。通过要查找的值来找到合适的指针进入下层节点。

假设有如下数据表

```sql
create table people(
    last_name varchar(50) not null,
    first_name varchar(50) not null,
    dob date not null,
    gender enum('m','f') not null,
    key(last_name,first_name,dob)
);
```

对于表中的每一行数据，索引中包含了last_name,first_name 和 dob 列的值。 显示了该索引是如何组织数据存储的。

![](muti.png)

有效使用索引：
* 全值匹配
* 匹配最左前缀
* 匹配列前缀 
* 匹配范围值 
* 精确匹配某一列并范围匹配另外一列 
* 值访问索引

B-Tree 索引的限制：

* 如果不是按照索引的最左侧开始查找，就无法使用索引。
* 不能跳过索引中的列，如果要查找姓名为 A 生日在 B 的人是只能使用索引的第一列。


### B-树   

* 内部节点:含有与页相关联的页的副本   
* 外部节点:含有指向实际数据的引用   
* 哨兵键:小于其他所有键，一开始B-树只含有   
一个根节点，节点初始化出的就是哨兵节点   

#### 查找和插入    

查找:在可能含有被查找键的唯一子树中进行一次递归的  
搜索   
![](https://img-blog.csdn.net/20170910224108969?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdTAxMjEyNDQzOA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
插入:    
如果被插入的节点变成一个溢出的节点   
递归调用不断向上调用分裂溢出的节点   
![](https://img-blog.csdn.net/20170910224922359?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdTAxMjEyNDQzOA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)