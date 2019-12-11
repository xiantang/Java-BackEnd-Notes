# GrowingIO Marketing API Java Library

## 概述

GrowingIO Marketing API 的 Java 版本封装库。

对应的 REST API 文档：[REST API - 推送](https://shimo.im/docs/rvKhdc3wDkhxRt8Y/read)，[REST API - 弹窗](https://shimo.im/docs/hPTwQ8cTKGX3hWC6/read)

## 安装

### maven 方式

将下边的依赖条件放到你项目的 maven pom.xml 文件里。

```xml
<dependency>
    <groupId>com.growingio</groupId>
    <artifactId>marketing-api-java-client</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```

### 样例


#### 推送 API

* 构建推送对象：所有平台，推送目标是别名为 "alias1"，通知内容为 ALERT。
  构建 `PushMessage`:

```java
// 需要替换成使用者的自己的变量
String clientId = "clientId";
String secret = "secret";
String projectUid = "projectUid";
String ai = "ai";

PushMessageClient client = PushMessageClient.getInstance(clientId, secret, projectUid, ai);

// 设置推送的推送消息体与自选项
Options options = Options.newBuilder()
  //	true 表示推送生产环境，false 表示要推送开发环境；如果不指定则为推送生产环境。
  .setApnsProduction(true).build();
PushNotification notification =
  PushNotification.newBuilder()
  .setTitle("推送标题")
  .setAlert("推送内容")
  // 设置点击跳转链接类型
  // 打开网页："openH5"
  // 打开APP内具体某个页面："openUrl"
  // 自定义参数："custom"
  .setActionType("openApp")
  // 设置点击跳转路径。
  .setActionTarget("com.hello.world")
  .build();

// 构建推送消息
PushMessage message =
  PushMessage.newBuilder()
  .setCid(UUID.randomUUID().toString())
  // 设置推送应用包名。可以在应用管理后台获取，注意 sdk 上传的包名需要和后台配置的一致！
  .setName("测试名字"+System.currentTimeMillis())
  .setPackageName("com.xxxxx.xxxdemo")
  // 设置推送目标列表
  .addAllAudience(Arrays.asList("alias1"))
  .setNotification(notification)
  .setOptions(options)
  .build();

```

推送 `PushMessage`:

```java
try {
  HttpResponse response = client.send(message);
  if (response.isSuccess()) {
    LOG.info("Send push message successful!");
  }
  LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
  assertTrue("", response.isSuccess());

} catch (Exception e) {
  LOG.error(e.getLocalizedMessage(), e);
} 
```


#### 弹窗

* 构建弹窗对象：推送目标是别名为 "alias2"，通知内容为 ALERT，消息素材 "https://xxxxxxxx/1130img.jpeg"。 
* 上传媒体文件  返回该文件在服务器的地址

```java
// 需要替换成使用者的自己的变量
String clientId = "clientId";
String secret = "secret";
String projectUid = "projectUid";
String ai = "ai";
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
// 构建媒体对象
Media media = Media.newBuilder()
  .setName("图片名称.png")
  .setFile(fileString)
  .build();
HttpResponse response = client.uploadMedia(media);
if (response.isSuccess()) {
  LOG.info("upload File successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
assertTrue("", response.isSuccess());
JSONObject responseJson = JSONObject.parseObject(response.getBody());
// 获取到的url
String url = (String) responseJson.get("url");
```

用获取到的 `url `进行构建弹窗对象


```java
HashMap<String, String> parameter1 = new HashMap<String, String>();
parameter1.put("key1", "value1");
parameter1.put("key2", "value2");

//设置参数 点击跳转携带参数，以 queryString 的形式添加到 url 后面。
// 比如 {"key1": "value1"} 会转化为 "?key1=value1" 添加到 url 后面。
HashMap<String, String> parameter2 = new HashMap<String, String>();
parameter2.put("key1", "value1");
parameter2.put("key2", "value2");

// 创建targets
// target 为指定产品和跳转页面的关系。

Target target1 = Target.newBuilder()
        .setProductId("xxxx")
      //设置点击跳转链接类型。
      //打开网页："openH5"
      //打开应用内具体页面："openUrl"
      //自定义参数："custom
        .setType("openUrl")
      //设置点击跳转路径。网页需要制定具体协议，
  		//支持 http/https。
        .setUrl("XxxActivity")
      //设置点击跳转携带参数，以 queryString 的形式添加到 url 后面。比如 {"key1": "value1"} 会转化为 "?key1=value1" 添加到 url 后面。
        .putAllParameter(parameter1)
        .build();
List<Target> targets = new ArrayList<Target>();
Target target2 = Target.newBuilder()
        .setProductId("xxxx")
        .setType("openUrl")
        .setUrl("XxxActivity")
        .putAllParameter(parameter2)
        .build();
targets.add(target1);
targets.add(target2);


// 根据 targets 创建 Rule
// rule 消息触发规则配置。
Rule rule = Rule.newBuilder()
  		// 设置动作
  		// 打开应用：appOpen
  		//自定义埋点事件：事件 key
        .setAction("xxxOpen")
  		//设置本条消息最大展示次数。
        .setLimit(2)
      // 设置指定产品和跳转页面的关系。
        .addAllTargets(targets)
      // 设置预约上线起始时间，unix 时间戳。
        .setStartAt(1575092361116L)
      // 设置预约下线时间，unix 时间戳。
        .setEndAt(1575095961116L)
      // 设置本条消息展示间隔, 单位秒 。
        .setTriggerCd(86400L)
        .build();

// 根据 rule 创建 InAppMessage
InAppMessage message = InAppMessage.newBuilder()
        .setName("弹窗名称")
        .setAudience("alias2")
        .setRule(rule)
        // 填写上传图片获取的url
        .setContent(url)
        .build();
```

* 创建弹窗

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.send(message);
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
```

* 更新弹窗 需要提供指定的的弹窗id(messageUid)

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.update(messageUid,message);
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
```

* 删除弹窗 只需要提供指定的弹窗id(messageUid)

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.delete(messageUid);
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
```

* 检索弹窗 根据项目id(projectUid)来查询该项目下的所有弹窗

```java
 InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.index();
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
```