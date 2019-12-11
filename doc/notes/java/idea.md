## 在 Intelij IDEA 中修改 maven 为国内镜像

国内镜像：阿里
打开 IntelliJ IDEA-&gt;Settings -&gt;Build, Execution, Deployment -&gt; Build Tools &gt; Maven
或者直接搜索 maven
具体如下图所示：
而一般情况下在 c:\Users\xx.m2 \ 这个目录下面没有 settings.xml 文件，我们可以新建一个，settings.xml 文件下的内容是：直接粘贴复制保存在上图所示的目录下面就可以了. 需要注意的是，需要点击上图所示右下角的 override。

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">

      <mirrors>
        <mirror>  
            <id>alimaven</id>  
            <name>aliyun maven</name>  
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>  
            <mirrorOf>central</mirrorOf>          
        </mirror>  
      </mirrors>
</settings>
```


如果是 linux 系统，操作过程基本相同，只是 settings.xml 文件的存放路径不一样，不过都可以通过上面截图所示的页面中查到。



## idea 常用快捷键

ctrl+N 生成代码  

ctrl+shift+A 命令全搜索.  
This is almost always followed by Ctrl + Alt + Left to get back to where I was (Ctrl + Alt + Right works to “go forward” again).     
Ctrl+N 创建class

Ctrl + J 查看方法JavaDoc





## 自动导入静态包

`command+enter` 对于测试的很多静态方法无法方便的导入。   
需要添加对模糊的包进行导入就可以完成

```
Perferences->Editor->General->Auto Import->java->add unambigous import on fly   
```

