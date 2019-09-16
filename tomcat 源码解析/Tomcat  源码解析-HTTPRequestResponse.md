# HTTP

Web 服务器也称为超文本传输协议服务器，因为他使用HTTP 与其客户端进行通讯。



HTTP 允许Web服务器和浏览器通过Internet 发送请求，他是一种基于“请求－响应”的协议。客户端请求一个文件，服务端对于该请求进行响应。



## HTTP 请求

一个HTTP 请求包括三部分:

* 请求方法－－－统一资源标识符 URI  协议／版本
* 请求头
* 实体

```
POST /ajax/ShowCaptcha HTTP/1.1\r\n
Content-Type: application/x-www-form-urlencoded\r\n
Host: www.renren.com\r\n
Content-Length: 36\r\n
\r\n
email=%E5%B7%A5&password=asdasdsadas
```

请求方法 －－ URI －－ 协议／版本

POST /ajax/ShowCaptcha HTTP/1.1\r\n

会出现在第一行

每个请求头之前都会用回车／换行符隔开 (CRLF)

并且请求头和请求实体之间会有一个空行，空行只有 CRLF 符号。CRLF告诉HTTP服务器请求的正文从哪里开始。

## HTTP 响应

与HTTP 请求相似，HTTP 响应也分三部分:

* 协议－－ 状态码
* 响应头
* 响应实体段

```
HTTP/1.1 200 OK\r\n
Date: Sat, 31 Dec 2005 23:59:59 GMT\r\n
Content-Type: text/html;charset=ISO-8859-1\r\n
Content-Length: 122\r\n
\r\n
<html>

<head>
<title>Wrox Homepage</title>
</head>

<body>
<!-- body goes here -->
</body>
</html>
```

HTTP/1.1 200 OK
Date: Sat, 31 Dec 2005 23:59:59 GMT
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 122

<html>
<head>
<title>Wrox Homepage</title>
</head>
<body>
<!-- body goes here -->
</body>
</html>

第一行类似使用的协议以及状态码（200 表示请求成功



## StandardServer

此类是Server 标准实现类，Server 仅此一个实现类。是Tomcat 顶级容器。Server是Tomcat中最顶层的组件，它可以包含多个Service组件。这一节主要给大家讲解Tomcat 是如何关闭的。之后的章节会给大家带来addService() 和findService（String) 方法的解析。

这个`StandardServer` 继承了 `Server`

并且实现了其中比较关键的一个方法:



```java
 /**
     * Wait until a proper shutdown command is received, then return.
     */
    public void await();
```

z

```java
try {
      InputStream stream;
      try {
        socket = serverSocket.accept();
        socket.setSoTimeout(10 * 1000);  // Ten seconds
        stream = socket.getInputStream();
      } catch (AccessControlException ace) {
        log.warn("StandardServer.accept security exception: "
                 + ace.getMessage(), ace);
        continue;
      } catch (IOException e) {
        if (stopAwait) {
          // Wait was aborted with socket.close()
          break;
        }
        log.error("StandardServer.await: accept: ", e);
        break;
      }
      while (expected > 0) {
        int ch = -1;
        try {
          ch = stream.read();
        } catch (IOException e) {
          log.warn("StandardServer.await: read: ", e);
          ch = -1;
        }
        if (ch < 32)  // Control character or EOF terminates loop
          break;
        command.append((char) ch);
        expected--;
      }finally {
        // Close the socket now that we are done with it
        try {
          if (socket != null) {
            socket.close();
          }
        } catch (IOException e) {
          // Ignore
        }
      }
  		 // Match against our command string
      boolean match = command.toString().equals(shutdown);
      if (match) {
        log.info(sm.getString("standardServer.shutdownViaPort"));
        break;
      } else
        log.warn("StandardServer.await: Invalid command '"
                 + command.toString() + "' received");
  
```

根据源码上的注释 我们可以大致了解，在启动Tomcat 的时候，会开启一个8005的端口，这个服务负责监听到来的 telnet 连接，当受到 为SHUTDOWN  的命令时候，销毁Tomcat 的所有服务并且关闭Tomcat。



## Request & Response

// TODO 去做笔试尽快更新

参考:

[深入理解Tomcat（12）拾遗-MessageBytes](https://www.jianshu.com/p/cb27c8da1543)

[消息字节——MessageBytes](https://blog.csdn.net/wangyangzhizhou/article/details/44004501)

