# 计算机网络

## 网络分层
* 应用层:网络进程到应用程序。针对也定的应用规定各层协议。端系统用软件实现。
* 表示层:负责数据的加密解密，把数据转换成独立于机器的数据。
* 会话层:主机间通讯，管理应用程序之间的会话。
* 传输层:在网络的各个节点之前可靠的分发数据包。
* 网络层:进行地址分配和路由。
* 数据链路层:可靠的点对点数据直链。
* 物理层:不一定可靠的点对点数据直链。

## 底层网络协议

### ARP
基本功能为透过目标设备的IP地址，查询目标设备的MAC地址，以保证通信的顺利进行。在每台安装有TCP/IP协议的电脑或路由器里都有一个ARP缓存表，表里的IP地址与MAC地址是一对应的。

### NAT
基本功能为透过目标设备的IP地址，查询目标设备的MAC地址，以保证通信的顺利进行。在每台安装有TCP/IP协议的电脑或路由器里都有一个ARP缓存表，表里的IP地址与MAC地址是一对应的。


# HTTP 协议
* 构建在TCP/IP协议之上 默认端口号80
* 无连接无状态

## 状态码含义
* 1** 服务器收到请求，需要请求者继续执行操作。
* 2** 成功,操作被成功接收并处理。
* 3** 重定向，需要进一步的操作以完成请求。
    * 301 Moved Permanently。请求的资源已被永久的移动到新URI，返回信息会包括新的URI，浏览器会自动定向到新URI。今后任何新的请求都应使用新的URI代替
    * 302 Moved Temporarily。与301类似。但资源只是临时被移动。客户端应继续使用原有URI
    * 304 Not Modified。所请求的资源未修改，服务器返回此状态码时，不会返回任何资源。客户端通常会缓存访问过的资源，通过提供一个头信息指出客户端希望只返回在指定日期之后修改的资源。
* 4**	客户端错误，请求包含语法错误或无法完成请求
    * 400 Bad Request 由于客户端请求有语法错误，不能被服务器所理解。
    * 401 Unauthorized 请求未经授权。这个状态代码必须和WWW-Authenticate报头域一起使用
    * 403 Forbidden 服务器收到请求，但是拒绝提供服务。服务器通常会在响应正文中给出不提供服务的原因
    * 404 Not Found 请求的资源不存在，例如，输入了错误的UR
* 5**	服务器错误，服务器在处理请求的过程中发生了错误
    * 500 Internal Server Error 服务器发生不可预期的错误，导致无法完成客户端的请求。
    * 503 Service Unavailable 服务器当前不能够处理客户端的请求，在一段时间之后，服务器可能会恢复正常。

## GET 和 POST 的区别

GET可提交的数据量受到URL长度的限制，HTTP协议规范没有对URL长度进行限制。这个限制是特定的浏览器及服务器对它的限制。
理论上讲，POST是没有大小限制的，HTTP协议规范也没有进行大小限制，出于安全考虑，服务器软件在实现时会做一定限制。

## Http会话的过程
* 建立tcp连接
* 发出请求文档
* 发出响应文档
* 释放tcp连接



### IPV6 缩写

1. 连续段的0可以用::来省略（单个的也可以） 但是最多只能出现一次
2. 单个0000可以简化成0 例如： FE80:0000:0000:0000:AAAA:0000:00C2:0002 等价于 FE80:0:0:0:AAAA:0000:00C2:0002
3. 前导的0可以被省略

