![8647D9F7-BE84-40EC-B4E1-D3773F741FA7.png](blob:file:///9340b11f-01ca-471a-8284-16374d0413f2)

## 安装redis

创建redis目录
`mkdir redis`

安装wget 
`yum install -y wget`



## 设置登陆密码

这是修改redis的配置文件
`vim /etc/redis/redis.conf`

找到`requirepass`   
修改密码。  

重启`redis`

`/etc/init.d/redis-server restart`







## scrapy爬虫报错 

```python
2018-12-23 14:03:12 [twisted] CRITICAL: Unhandled Error
Traceback (most recent call last):
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy/commands/crawl.py", line 58, in run
    self.crawler_process.start()
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy/crawler.py", line 291, in start
    reactor.run(installSignalHandlers=False)  # blocking call
  File "/home/ubuntu/.local/lib/python3.5/site-packages/twisted/internet/base.py", line 1267, in run
    self.mainLoop()
  File "/home/ubuntu/.local/lib/python3.5/site-packages/twisted/internet/base.py", line 1276, in mainLoop
    self.runUntilCurrent()
--- <exception caught here> ---
  File "/home/ubuntu/.local/lib/python3.5/site-packages/twisted/internet/base.py", line 902, in runUntilCurrent
    call.func(*call.args, **call.kw)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy/utils/reactor.py", line 41, in __call__
    return self._func(*self._a, **self._kw)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy/core/engine.py", line 122, in _next_request
    if not self._next_request_from_scheduler(spider):
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy/core/engine.py", line 149, in _next_request_from_scheduler
    request = slot.scheduler.next_request()
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy_redis/scheduler.py", line 172, in next_request
    request = self.queue.pop(block_pop_timeout)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/scrapy_redis/queue.py", line 115, in pop
    results, count = pipe.execute()
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/client.py", line 3443, in execute
    return execute(conn, stack, raise_on_error)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/client.py", line 3339, in _execute_transaction
    self.immediate_execute_command('DISCARD')
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/client.py", line 3275, in immediate_execute_command
    return self.parse_response(conn, command_name, **options)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/client.py", line 3402, in parse_response
    self, connection, command_name, **options)
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/client.py", line 768, in parse_response
    response = connection.read_response()
  File "/home/ubuntu/.local/lib/python3.5/site-packages/redis/connection.py", line 638, in read_response
    raise response
redis.exceptions.ResponseError: DISCARD without MULTI

```

查看redis的log

`cat /etc/redis/redis.conf`

找到日志的位置

`tail -100 /var/log/redis/redis-server.log`


```log
3655:M 23 Dec 14:22:04.093 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:04.093 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:10.005 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:10.005 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:16.018 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:16.018 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:22.030 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:22.031 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:28.041 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:28.041 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:34.059 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:34.059 # Can't save in background: fork: Cannot allocate memory
3655:M 23 Dec 14:22:40.072 * 1 changes in 900 seconds. Saving...
3655:M 23 Dec 14:22:40.073 # Can't save in background: fork: Cannot allocate memory

```

原因：

* 在小内存进程上做fork 不需要太多资源，当进程的内存以G为单位
fork 就很奢侈了 
* 所以一直cannot allocate memory

解决方案: 

直接修改内核参数 `vm.overcommit_memory = 1`      
linux 会根据参数来决定是否放行 


```bash
sudo echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf sudo sysctl -p
```

内核分配参数 

0 表示检查是否有足够的可用内存供应用进程使用；
1 表示内核允许分配所有的物理内存，而不管当前的内存状态如何



Redis 简单动态字符串实现



不仅仅需要字面量，需要可以修改的字符串的值

在底层是SDS 实现

执行 SET msg "hello world"

键值都是SDS



![屏幕快照 2019-11-29 下午2.03.09](/Users/xiantang/Desktop/屏幕快照 2019-11-29 下午2.03.09.png)

![屏幕快照 2019-11-29 下午2.14.03](/Users/xiantang/Desktop/屏幕快照 2019-11-29 下午2.14.03.png)

 

简单看了下 set的底层实现 set 其实是value 为空的hashtable  

之前set比 string占用小应该是 string 设置进去的时候我将值设置为了 1 所以测出来set 比 string 小 4M 其实在这种情况下两者的差异并不大  然后还有一点 set 如果全是数字的话 采用的会是 inset ，并且会根据插入的元素进行升级 升级为32 位或者 64位，可以达到解决空间的效果。

用的拉链法 + 　头插

load_factor = ht[0].used / ht[0].size



当负载因子小于0.1的时候程序自动对hash表进行收缩



渐进式rehash:

rehash不是一次性的和集中性的，如果键值对有很大的量，一瞬间rehash的话会导致服务器宕机

采用一种分而治之的方式进行操作，每次增删改查在完成对应工作后，都会对一个dictEntry的所有键值对进行rehash。将集中式的操作转换为了独立的可拆分的操作，并且在rehash的过程中，会从两个dict中进行查询。