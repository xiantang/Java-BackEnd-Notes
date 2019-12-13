接收器 阀 

Tomcat 自带线程池





# HTTP

Web 服务器也称为超文本传输协议服务器，因为他使用HTTP 与其客户端进行通讯。

HTTP 是应用层协议，由响应和请求组成，是一个标准的B/S 模型,同时也是一个无状态的协议，在同一个客户端中，此次请求和上次请求没有对应关系。

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

# Request & Response

在阅读Tomcat Request 源码的时候，我发现了一个比较有趣的东西:

```java
private MessageBytes schemeMB = MessageBytes.newInstance();
private MessageBytes methodMB = MessageBytes.newInstance();
private MessageBytes unparsedURIMB = MessageBytes.newInstance();
private MessageBytes uriMB = MessageBytes.newInstance();
private MessageBytes decodedUriMB = MessageBytes.newInstance();
private MessageBytes queryMB = MessageBytes.newInstance();
private MessageBytes protoMB = MessageBytes.newInstance();
// remote address/host
private MessageBytes remoteAddrMB = MessageBytes.newInstance();
private MessageBytes localNameMB = MessageBytes.newInstance();
private MessageBytes remoteHostMB = MessageBytes.newInstance();
private MessageBytes localAddrMB = MessageBytes.newInstance();
```



他的大多数成员变量都是`MessageBytes` 的实例，这让我产生了兴趣，这个`MessageBytes`到底是什么东西?

后来通过查阅资料发现Tomcat 为了提升性能，用了一些很有趣的 Tricks

Tomcat 对于读取来的字节流不会立马解析，而是将它进行打标＋延时提取的方式来实现 按需使用。

下面我来跑一个小 demo 来了解一下MessageBytes 是个什么样的东西?

```java
public class MessageBytesTest {
    public static void main(Str ing[] args) {
        MessageBytes mb = MessageBytes.newInstance();
        // 等待测试的byte 对象
        byte[] bytes = "abcdefg".getBytes(Charset.defaultCharset());
        // 调用`setBytes`对bytes 进行标记
        mb.setBytes(bytes, 2, 3);
        System.out.println(mb.toString());

    }
}
```

这个例子用来提取字节流中的子子节，并将它转换为String

下面我们继续来阅读这个 MessageBytes 到底是何方神圣? 

MessageByte 主要有四种类型:

```java
public static final int T_NULL = 0;
/** getType() is T_STR if the the object used to create the MessageBytes
        was a String */
// 表示消息为字符串
public static final int T_STR  = 1;
/** getType() is T_STR if the the object used to create the MessageBytes
        was a byte[] */
// 表示消息为字节数组类型
public static final int T_BYTES = 2;
/** getType() is T_STR if the the object used to create the MessageBytes
        was a char[] */
// 表示消息为字符数组
public static final int T_CHARS = 3;

```

1. `T_NULL`表示空消息，即消息为`null`
2. `T_STR`表示消息为字符串类型
3. `T_BYTES`表示消息为字节数组类型
4. `T_CHARS`表示消息为字符数组类型

 接着我们查看一下构造方法:

```java
/**
     * Creates a new, uninitialized MessageBytes object.
     * Use static newInstance() in order to allow
     *   future hooks.
     */
    // 使用工厂方法来创建实例
    private MessageBytes() {
    }
```

它的构造方法是私有的，我们只能通过工厂方法来获取实例

接着我们查看我们demo中使用的方法` setBytes ` 这个是一个关键方法，它负责对bytes 打标。

```java
    /**
     * Sets the content to the specified subarray of bytes.
     *
     * @param b the bytes
     * @param off the start offset of the bytes
     * @param len the length of the bytes
     */

    public void setBytes(byte[] b, int off, int len) {
        //private final ByteChunk byteC=new ByteChunk();
        //private final CharChunk charC=new CharChunk();
        byteC.setBytes( b, off, len );
        type=T_BYTES;
        hasStrValue=false;
        hasHashCode=false;
        hasIntValue=false;
        hasLongValue=false;
    }
```

它内部调用了 `ByteChunk` 的`setBytes`方法,同时设置了`type字段`。

我们继续向里面走！

发现内部十分简单只是对数组进行了标识。　

```java
    //非常简单，就是设置一下待标识的字节数组、开始位置、结束位置。
    public void setBytes(byte[] b, int off, int len) {
        buff = b;
        start = off;
        end = start+ len;
        isSet=true;
    }
```

同时也印证了我们开头所说，打标记但是没有转码。

i

```java
// -------------------- MessageBytes --------------------
/** Compute the string value
     * 首先判断是否有缓存的字符串，有的话就直接返回，
     * 这也是提高性能的一种方式。其次是根据type来选择不同的*Chunk，
     * 然后调用其toString()方法。那么我们这儿选择ByteChunk.toString()来分析。
     */
@Override
public String toString() {
  // 先取缓存
  if( hasStrValue ) {
    return strValue;
  }
  // 判断缓存类型
  // 设置缓存
  switch (type) {
    case T_CHARS:
      strValue=charC.toString();
      hasStrValue=true;
      return strValue;
    case T_BYTES:
      strValue=byteC.toString();
      hasStrValue=true;
      return strValue;
  }
  return null;
}
// -------------------- ByteChunk --------------------
@Override
public String toString() {
  if (null == buff) {
    return null;
  } else if (end-start == 0) {
    return "";
  }
  return StringCache.toString(this);
}

public String toStringInternal() {
  if (charset == null) {
    charset = DEFAULT_CHARSET;
  }
  // 如果我们只有少部分要使用
  // 通过打标记＋延时提取的方式
  // new String(byte[], int, int, Charset) takes a defensive copy of the
  // entire byte array. This is expensive if only a small subset of the
  // bytes will be used. The code below is from Apache Harmony.
  CharBuffer cb;
  cb = charset.decode(ByteBuffer.wrap(buff, start, end-start));
  // reuturn new String(buff, start, end - start, charset);
  return new String(cb.array(), cb.arrayOffset(), cb.length());
}
```

需要关注的主要是这三个方法

MB 调用 toString 方法的时候首先会从当前实例中取出缓存，如果没有缓存就调用 ByteChunk 的 toString 方法,设置缓存并且返回。

ByteChunk 的 toString 方法是使用StringCache 的toString 方法 但是其中的主要调用仍然是 StringCache.toStringInternal() 

我们来讲解一下这个方法吧!

他使用的是NIO 的 ByteBuffer 根据`偏移量`和`待提取长度`进行`编码提取转换`。

需要注意的是该注释已经给出了使用`java.nio.charset.CharSet.decode()`代替直接使用`new String(byte[], int, int, Charset)`的原因。

如果是用默认的 `new String(byte[], int, int, Charset)` 会对整个byte 进行拷贝，对于一个巨大的byte[] 中我们只需要提取一些些数据，就会带来严重的性能损耗。

### Request 是如何被解析的

他是如何判断打标的位置的？

下面为以给请求行中的 URI 打标为大家解释

我们要探寻的是:

```java
/**
 * Implementation of InputBuffer which provides HTTP request header parsing as
 * well as transfer decoding.
 *
 * @author <a href="mailto:remm@apache.org">Remy Maucherat</a>
 * @author Filip Hanik
 */
public class InternalNioInputBuffer extends AbstractInputBuffer<NioChannel> {
   @Override
    public boolean parseRequestLine(boolean useAvailableDataOnly)
        throws IOException {
    		//-----省略前面的解析步骤
      	if (parsingRequestLinePhase == 4) {
            // Mark the current buffer position
            
            int end = 0;
            //
            // Reading the URI
            //
            boolean space = false;
            while (!space) {
                // Read new bytes if needed
                if (pos >= lastValid) {
                    if (!fill(true, false)) //request line parsing
                        return false;
                }
                if (buf[pos] == Constants.SP || buf[pos] == Constants.HT) {
                    space = true;
                    end = pos;
                } else if ((buf[pos] == Constants.CR)
                        || (buf[pos] == Constants.LF)) {
                    // HTTP/0.9 style request
                    parsingRequestLineEol = true;
                    space = true;
                    end = pos;
                } else if ((buf[pos] == Constants.QUESTION)
                        && (parsingRequestLineQPos == -1)) {
                    parsingRequestLineQPos = pos;
                }
                pos++;
            }
            request.unparsedURI().setBytes(buf, parsingRequestLineStart, end - parsingRequestLineStart);
            if (parsingRequestLineQPos >= 0) {
                request.queryString().setBytes(buf, parsingRequestLineQPos + 1, 
                                               end - parsingRequestLineQPos - 1);
                request.requestURI().setBytes(buf, parsingRequestLineStart, parsingRequestLineQPos - parsingRequestLineStart);
            } else {
                // URL 当解析的时候之前个请求方法执行完之后会找到对应的空格
                // 请求行的开始就就是parseRequestLineStart 开始位置
                //  之后向下寻找空格 并将他标记为end
                // setBytes 的时候只要把开始的位置和长度设置进去就行了
                request.requestURI().setBytes(buf, parsingRequestLineStart, end - parsingRequestLineStart);
            }
            System.out.println("解析出来的URI为: " +request.requestURI().toString());
            parsingRequestLinePhase = 5;
        }
    }
}
```

这里主要要了解的是几个变量

* buf 整条请求头的byte[]
* parsingRequestLineStart URI 开始位置
* end URI 结束位置

上面代码的大致意识是 将parsingRequestLineStart的位置设置为上次解析（解析请求方法）的位置＋1

然后通过遍历buf 寻找从 parsingRequestLineStart 开始的第一个空格。

并且为了避免多余的编码，tomcat 将 `空格` `CR` `LF` 也转换为字节，只要比较字节就能判断是否相同，期间没有任何编码。 

```java
/**
* CR.
*/
public static final byte CR = (byte) '\r';
/**
* LF.
*/
public static final byte LF = (byte) '\n';
/**
* SP.
*/
public static final byte SP = (byte) ' ';
```



将这些字节流通过setBytes 打标，记住是offset/offset+长度。

### 总结

还是开头那句话:

Tomcat 采用延时编码的方式来提升性能，解析完一个Request后，如果没有被利用，变量存储的只是这个字节流的打标，只有在使用的时候才会去编码或者去取缓存。这样有个好处，就是Request 中的信息不是全部要使用的，有时候我们只需要取一部分就行了，所以就可以降低编码的性能消耗。



# RequestFacade

阅读Request 源码的时候我发现他是拥有一个这样的奇怪方法:

```java
/**
     * Return the <code>ServletRequest</code> for which this object
     * is the facade.  This method must be implemented by a subclass.
     */
    public HttpServletRequest getRequest() {
        if (facade == null) {
            facade = new RequestFacade(this);
        }
        return facade;
    }

```

其实这个是一种设计模式，叫做门面模式。

因为servlet 执行service() 方法的时候可以看到他传入的静态类型是ServletRequest 也就是说所有继承了ServeltRequest 的子类对象可以被传入service() 方法。

```java
public void service(ServletRequest req, ServletResponse res)
            throws ServletException, IOException;
```

那么Reqeust 作为Servlet 的子类自然可以传入这个方法，并且向上转型成为ServletReqeust。

但是会遇到一个安全性的问题，如果一个熟悉Tomcat原理的用户，可以将ServletReqeust 转型成为Reqeust

就可以调用他的公共方法了。

所以我们为Request 添加了一个外观类:

![img](data:image/png;base64,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)

RequestFacade 和 Request 共同继承了 ServletRequest 这表示他能代替Request 传入Service 方法,并且他的构造方法就是传入一个 Request

 ```java
/**
     * Construct a wrapper for the specified request.
     *
     * @param request The request to be wrapped
     */
    public RequestFacade(Request request) {

        this.request = request;

    }

/**
     * The wrapped request.
     */
    protected Request request = null;

 ```

也就是说我们可以将他理解为一个Request 的包装,将其中的request 成员私有，他实现的所有HttpServletRequest的方法都是调用Request的对应方法。

```java
 @Override
    public int getContentLength() {

        if (request == null) {
            throw new IllegalStateException(
                            sm.getString("requestFacade.nullRequest"));
        }

        return request.getContentLength();
    }


    @Override
    public String getContentType() {

        if (request == null) {
            throw new IllegalStateException(
                            sm.getString("requestFacade.nullRequest"));
        }

        return request.getContentType();
    }

```

这时，servlet 程序员仍然可以对Service() 中的ServletRequest 转型成为 RequestFacade 但是只能调用Request 对于HttpServletRequest 的实现。



参考:

[深入理解Tomcat（12）拾遗-MessageBytes](https://www.jianshu.com/p/cb27c8da1543)

[消息字节——MessageBytes](https://blog.csdn.net/wangyangzhizhou/article/details/44004501)