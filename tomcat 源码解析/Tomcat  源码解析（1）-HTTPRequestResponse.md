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



参考:

[深入理解Tomcat（12）拾遗-MessageBytes](https://www.jianshu.com/p/cb27c8da1543)

[消息字节——MessageBytes](https://blog.csdn.net/wangyangzhizhou/article/details/44004501)