### 创建本地分支推到服务器
创建新的本地分支 
`git checkout -b dd `

从远程拉取分支 
`git checkout -b dd remote/origin/dd`

创建远程分支
`git push origin dd:dd`   

### 切换远程服务地址 

删除远程服务器地址
`git remote rm origin`   

添加新的 
`git remote add  origin  https://github.com/xiantang/jdcrawler`