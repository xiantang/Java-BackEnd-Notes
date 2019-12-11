# GrowingIO Marketing API Java Library

## 概述

GrowingIO Marketing API 的 Java 版本封装库。

对应的 REST API 文档：[REST API - Push](https://shimo.im/docs/rvKhdc3wDkhxRt8Y/read).

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
  
      Options options = Options.newBuilder().setApnsProduction(true).build();
      PushNotification notification =
          PushNotification.newBuilder()
              .setTitle("推送标题")
              .setAlert("推送内容")
              .setActionType("openApp")
              .setActionTarget("com.hello.world")
              .build();
  
      PushMessage message =
          PushMessage.newBuilder()
              .setCid(UUID.randomUUID().toString())
              .setName("测试名字"+System.currentTimeMillis())
              .setPackageName("com.growingio.giodemo")
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

```java
// 创建targets
HashMap<String, String> parameter1 = new HashMap<String, String>();
parameter1.put("key1", "value1");
parameter1.put("key2", "value2");
HashMap<String, String> parameter2 = new HashMap<String, String>();
parameter2.put("key1", "value1");
parameter2.put("key2", "value2");
Target target1 = Target.newBuilder()
        .setProductId("xxxx")
        .setType("openUrl")
        .setUrl("XxxActivity")
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
Rule rule = Rule.newBuilder()
        .setAction("xxxOpen")
        .setLimit(2)
        .addAllTargets(targets)
        .setStartAt(1575092361116L)
        .setEndAt(1575095961116L)
        .setTriggerCd(86400L)
        .build();

// 根据 rule 创建 InAppMessage
InAppMessage message = InAppMessage.newBuilder()
        .setName("testest")
        .setAudience("alias2")
        .setRule(rule)
        .setContent("https://xxxxxxxx/1130img.jpeg")
        .build();
```

* 创建弹窗

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.send(message);
if (response.isSuccess()) {
  LOG.info("Send push message successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
```

* 更新弹窗 需要提供指定的messageId

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.update(messageId,message);
if (response.isSuccess()) {
  LOG.info("Send push message successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
assertTrue("", response.isSuccess());
```

* 删除弹窗 只需要提供指定的messageId

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.delete(messageId);
if (response.isSuccess()) {
  LOG.info("Send push message successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
assertTrue("", response.isNoContent());
```

* 检索弹窗 根据 projectUid 来查询该项目下的所有弹窗

```java
 InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
HttpResponse response = client.index();
if (response.isSuccess()) {
  LOG.info("Send push message successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
assertTrue("", response.isSuccess());
```

* 上传媒体文件  返回该文件在服务器的地址

```java
InAppMessageClient client = InAppMessageClient.getInstance(clientId, secret, projectUid, ai);
// 构建媒体对象
Media media = Media.newBuilder()
  .setName("test.png")
  .setFile(fileString)
  .build();
HttpResponse response = client.uploadMedia(media);
if (response.isSuccess()) {
  LOG.info("Send push message successful!");
}
LOG.info("code: {}, body: {}", response.getCode(), response.getBody());
assertTrue("", response.isSuccess());
```

