# InitDemo
## 介绍
IOS App 项目的基础模版可以clone下来作为其他项目的初始化
这里主要做的是通过脚本方便更改项目名 （基础模版不包括 pod install 出现的文件）

## 步骤
- git clone
- 在当前目录执行 ./init.sh newProject  没权限注意先改权限
- 更换远端仓库源
	- git commit -m "" 
    - git remote remove origin
    - git remote add origin [YOUR NEW .GIT URL]
	- git pull origin master --allow-unrelated-histories
    - git push -u origin master
	
## 注意
当命名的新项目名中包含 “-” 可能会出错
要手动删除Pods_newProject.framework
