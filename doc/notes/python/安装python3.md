创建文件
`mkdir /usr/local/python3`  

下载源码
`wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz`  

解压
`tar -xvf Python-3.6.3.tgz`

`cd Python-3.6.3/`

稍微解释上面这句命令，这句话的大致目的就是把python的安装目录指定一下，这样的话，里面的一些bin目录、lib目录就都会存放在这个目录下面。

`./configure --prefix=/usr/local/python3Dir`   

如果报错就表示gcc组件没有安装 

`yum install -y gcc`

编译源码 

`make`

执行安装

`make install`  

出现错误
`zipimport.ZipImportError: can't decompress data; zlib not available
make: *** [install] 错误 1`  

安装zlib相关的依赖包 

yum -y install zlib*
    