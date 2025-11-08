# meow-blog

## 项目简介
- 多用户博客系统
- 支持修改头图，头像
- 点赞，收藏，投币博文
- 自定义硬币商店与广告系统
- 文章编辑，上传，存草稿
- 技术栈说明：JSP，MySQL，tomcat，maven，

## 环境要求
- java 18.0.2.1 2022-08-18
- Apache Tomcat/11.0.13
- MySQL 8.0.43
- javax.servlet-api-3.1.0
- Maven依赖库
- 基于Eclipse IDE运行

## 项目结构
仅列出与配置有关的文件
test2/
├── main

│ ├── java

│ │ ├──com

│ │ │ ├──yourblog

│ │ │ │ ├──controller

│ │ │ │ ├──dao

│ │ │ │ ├──filter

│ │ │ │ ├──model

│ │ │ │ ├──util

│ ├──webapp

│ │ ├──images

│ │ ├── WEB-INF/

│ │ │ ├── web.xml # 部署描述符

└─── JSP文件

├── blog_db # 项目数据库

├── stats # 其他可能需要的配置文件



## 部署步骤
1. 作为Maven项目导入到 Eclipse：File → Import → Existing Projects into Workspace
2. 配置 Tomcat 服务器
3. 配置数据库连接（数据库脚本位置）
4. 部署并启动项目

## 配置说明
<<<<<<< HEAD:README.txt
- 下载mysql JDBC驱动，修改main.java.com.yourblog.util.DatabaseUtil.java
=======
- 下载mysql JDBC驱动，修改main.java.com.yourblog.util.DatabaseUtil.java

>>>>>>> dbbc291db89de91d7638030dc3393d46333611ed:README.md
