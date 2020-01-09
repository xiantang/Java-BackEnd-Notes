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

### 添加多个远程源

查看远程源  `git remote -v`

```
origin  ssh://a.git (fetch)
origin  ssh://a.git (push)
```

添加一个名为 us 远程源

`git remote add us ssh://c.git`

查看远程源 `git remote -v`

```
origin  ssh://a.git (fetch)
origin  ssh://a.git (push)
us      ssh://b.git (fetch)
us      ssh://b.git (push)

```

获取所有远程分支到本地 `git fetch --all`



复原submodule

`git submodule foreach --recursive git reset --hard`
`git submodule update --init --recursive`







