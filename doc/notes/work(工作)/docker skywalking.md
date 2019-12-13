# **Docker 部署 SkyWalking OAP & UI**

### ▶ 获取镜像

> 当前版本：6.1.0
> 自制镜像：[Docker 镜像 - 构建 SkyWalking OAP & UI](https://www.jianshu.com/p/a3a8d54b7da9)

```
# oap
docker pull registry.cn-hangzhou.aliyuncs.com/anoy/skywalking-oap

# ui
docker pull registry.cn-hangzhou.aliyuncs.com/anoy/skywalking-ui
```

### ▶ 部署 SkyWalking OAP

**简易部署（仅供体验）**

```
docker run -d \
--name skywalking-oap \
-p 11800:11800 \
-e TZ=Asia/Shanghai \
registry.cn-hangzhou.aliyuncs.com/anoy/skywalking-oap
```

**端口说明**

- `0.0.0.0/11800`：gRPC APIs，用于 Java、.NetCore、Node.js、Istio 探针
- `0.0.0.0/12800`：http rest APIs，用于 SkyWalking UI 请求，做 GraphQL 查询

**自定义配置**

配置挂载路径 `/skywalking/config`，配置文件说明：

- `application.yml`：基本配置，参考 [application.yml](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fdocker%2Fconfig%2Fapplication.yml)
- `component-libraries.yml`：组件库配置，参考 [component-libraries.yml](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fdocker%2Fconfig%2Fcomponent-libraries.yml)
- `alarm-settings.yml`：报警配置，参考 [alarm-settings.yml](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fdocker%2Fconfig%2Falarm-settings.yml)
- `datasource-settings.properties`：数据库配置，参考 [datasource-settings.properties](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fdocker%2Fconfig%2Fdatasource-settings.properties)
- `log4j2.xml`：日志配置， 参考 [log4j2.xml](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fdocker%2Fconfig%2Flog4j2.xml)

### ▶ 部署 SkyWalking UI

```
docker run -d \
--name skywalking-ui \
--link skywalking-oap:skywalking-oap \
-p 8088:8080 \
-e TZ=Asia/Shanghai \
registry.cn-hangzhou.aliyuncs.com/anoy/skywalking-ui \
--collector.ribbon.listOfServers=skywalking-oap:12800 \
--security.user.admin.password=admin
```

参数说明：

- `collector.ribbon.listOfServers`：SkyWalking OAP 地址，多个地址用 "," 分隔
- `security.user..password`：指定登录的账号密码

更多配置参考：[https://github.com/apache/skywalking/blob/master/apm-webapp/src/main/resources/application.yml](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fapache%2Fskywalking%2Fblob%2Fmaster%2Fapm-webapp%2Fsrc%2Fmain%2Fresources%2Fapplication.yml)

### ▶ 访问 SkyWalking

- 地址：[http://127.0.0.1:8088/](https://links.jianshu.com/go?to=http%3A%2F%2F127.0.0.1%3A8088%2F)
- 账号：admin
- 密码：admin



play 集成scala

自定义一个task 

build.sbt

```scala
import scala.sys.process._
lazy val agent = taskKey[Unit]("Execute clone skywalking-agent scripts")
agent := {
 "git clone ssh://vcs-user@codes.growingio.com/source/skywalking-agent.git ./agent" !
}
```



在 ./docker/build.sh 中添加执行task 的命令

```shell
git submodule init
git submodule update
cd  $home/growing-micros/
git checkout submodule
cd ../


sbt agent  <- here!!!!
sbt dist
cp target/universal/$archive_name $home/$base/

cd $home/$base/
```





skywalking 有两个端，一个是服务端一个是客户端端，客户端是以javaagent 的方式嵌入到play 项目中

