cd /d/project/Java-BackEnd-Notes
# 自动获取远端分支
git pull origin master
git add .
result=`git status -s`
git commit -m "$result"
git push origin master

