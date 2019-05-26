

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