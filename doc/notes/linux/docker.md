# 1、编写Scrapy的配置文件  


```conf
[scrapyd]
eggs_dir    = eggs
logs_dir    = logs
items_dir   =
jobs_to_keep = 5
dbs_dir     = dbs
max_proc    = 0
max_proc_per_cpu = 10
finished_to_keep = 100
poll_interval = 5.0
bind_address = 0.0.0.0
http_port   = 6800
debug       = off
runner      = scrapyd.runner
application = scrapyd.app.application
launcher    = scrapyd.launcher.Launcher
webroot     = scrapyd.website.Root

[services]
schedule.json     = scrapyd.webservice.Schedule
cancel.json       = scrapyd.webservice.Cancel
addversion.json   = scrapyd.webservice.AddVersion
listprojects.json = scrapyd.webservice.ListProjects
listversions.json = scrapyd.webservice.ListVersions
listspiders.json  = scrapyd.webservice.ListSpiders
delproject.json   = scrapyd.webservice.DeleteProject
delversion.json   = scrapyd.webservice.DeleteVersion
listjobs.json     = scrapyd.webservice.ListJobs
daemonstatus.json = scrapyd.webservice.DaemonStatus

```

### 新建requirements

`vim requirements.txt`

### Dockerfile

`vi Dockerfile`

 ```dockerfile
FROM python:3.5
ADD . /code
WORKDIR /code
RUN pip install  -r ./requirements.txt
EXPOSE 6800
COPY ./scrapyd.conf /etc/scrapyd/
CMD ["scrapyd"]
 ```
### 建立镜像
`docker build -t scrapyd:test .`

### 启动
`docker run -d -p 6800:6800 scrapyd`

### 部署
`scrapyd-deploy 0`

### 调度爬虫项目

`curl http://111.231.255.225:6800/schedule.json -d project=jdcrawler -d spider=DetailSpider`

### 查看正在运行的容器 

`docker ps`

### 进入容器
`sudo docker exec -it 0bf7d9d4aa4f bash`

### 部署爬虫项目  
`curl http://111.231.255.225:6800/schedule.json -d project=jdcrawler -d spider=DetailSpider`

### 取消某个爬虫
`curl http://xiantang.info:6800/cancel.json -d project=jdcrawler -d job=65edbff03cd911e9ae0f0242ac110002`

*  登录阿里云Docker Registry
`$ sudo docker login --username=战神皮皮迪 registry.cn-hangzhou.aliyuncs.com`
用于登录的用户名为阿里云账号全名，密码为开通服务时设置的密码。您可以在产品控制台首页修改登录密码。
* 从Registry中拉取镜像
`$ sudo docker pull registry.cn-hangzhou.aliyuncs.com/xiantang/xiantang:[镜像版本号]`
* 将镜像推送到Registry
```shell
$ sudo docker login --username=战神皮皮迪 registry.cn-hangzhou.aliyuncs.com
$ sudo docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/xiantang/xiantang:[镜像版本号]
$ sudo docker push registry.cn-hangzhou.aliyuncs.com/xiantang/xiantan:[镜像版本号]
```
请根据实际镜像信息替换示例中的[ImageId]和[镜像版本号]参数。


# docker 常用命令

查看所有正在运行容器 
`docker ps `

查看所有容器
`docker ps -a`

关闭指定容器 
`docker stop [containerId]`   

删除已经退出的镜像 

`
docker rm -v $(docker ps -a -q -f status=exited)`

## 删除所有的镜像

```shell
docker rmi $(docker images -q)
```

# Ubuntu 16.04 安装 Docker

1.选择国内的云服务商，这里选择阿里云为例
`curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -`   

2.安装所需要的包
`sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual`


3.添加使用 HTTPS 传输的软件包以及 CA 证书

```shell
sudo apt-get update      
sudo apt-get install apt-transport-https ca-certificates
```

4.添加GPG密钥
`
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
`

5.添加软件源`echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list`
6.添加成功后更新软件包缓存`sudo apt-get update`
7.安装docker
`sudo apt-get install docker-engine`
8.启动 docker 
` sudo systemctl enable docker`
`sudo systemctl start docker`