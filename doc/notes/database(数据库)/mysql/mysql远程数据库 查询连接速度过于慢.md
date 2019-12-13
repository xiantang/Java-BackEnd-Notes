如果是ubuntu 16 就修改 

`/etc/mysql/mysql.conf.d/mysqld.cnf`     
在`[mysqld]`中添加` skip-name-resolve`    

```
[mysqld]
port = 3306
socket = /tmp/mysql.sock
skip-external-locking
skip-name-resolve
```

然后重启mysql服务器

`sudo /etc/init.d/mysql start`    

这个方法的弊端就是在mysql的授权表中不能使用主机名，只能使用ip    

流程是这样的mysql接受到连接请求的时候，获取到了客户端的ip，为了更好的匹配这个授权记录，如果mysql服务器设置了dns服务器，但是客户端ip并没有dns上有响应的域名，就会很慢。

`skip-name-resolve` 就是跳过了这个过程