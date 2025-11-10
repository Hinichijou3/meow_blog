# Meow Blog 多用户博客系统

## 项目简介

Meow Blog 是一个功能丰富的多用户博客平台，支持用户进行个性化设置与内容互动。系统具备以下核心功能：

- 用户自定义头图与头像
- 文章点赞、收藏与投币
- 自定义硬币商店与广告系统
- 文章编辑、发布与草稿保存

### 技术栈

- **后端**: JSP、Servlet
- **数据库**: MySQL 8.0
- **服务器**: Apache Tomcat 11.0
- **构建工具**: Maven
- **开发环境**: Eclipse IDE

## 环境要求与安装

### 1. Java 开发环境安装

#### Windows 系统
```bash
# 下载并安装 JDK 18.0.2.1
# 访问 Oracle 官网或使用 OpenJDK

# 设置环境变量
JAVA_HOME=C:\Program Files\Java\jdk-18.0.2.1
PATH=%JAVA_HOME%\bin;%PATH%

# 验证安装
java -version
javac -version

#### Linux/macOS 系统
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-18-jdk

# CentOS/RHEL
sudo yum install java-18-openjdk-devel

# macOS (使用 Homebrew)
brew install openjdk@18

# 验证安装
java -version
javac -version

### 2. Apache Tomcat 11 安装

# 下载 Tomcat 11.0.13
wget https://downloads.apache.org/tomcat/tomcat-11/v11.0.13/bin/apache-tomcat-11.0.13.tar.gz

# 解压
tar -xzf apache-tomcat-11.0.13.tar.gz
sudo mv apache-tomcat-11.0.13 /opt/tomcat

# 设置环境变量
export CATALINA_HOME=/opt/tomcat
export PATH=$PATH:$CATALINA_HOME/bin

# 启动 Tomcat
$CATALINA_HOME/bin/startup.sh

# Eclipse 中配置 Tomcat
打开 Eclipse → Window → Preferences

选择 Server → Runtime Environments

点击 Add → Apache Tomcat v11.0

指定 Tomcat 安装目录

选择 JRE 版本（JDK 18）

### 3. MySQL 8.0 数据库安装

#### Windows系统安装

# 下载 MySQL Installer from https://dev.mysql.com/downloads/installer/
# 运行安装程序，选择 MySQL Server 8.0.43
# 设置 root 密码并记住凭证

# 启动 MySQL 服务
net start mysql80

#### Linux系统安装

# Ubuntu/Debian
wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.24-1_all.deb
sudo apt update
sudo apt install mysql-server

# 安全配置
sudo mysql_secure_installation

# 启动服务
sudo systemctl start mysql
sudo systemctl enable MySQL

#### 创建数据库

-- 登录 MySQL
mysql -u root -p

-- 创建数据库
CREATE DATABASE blog_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户并授权（可选）
CREATE USER 'blog_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON blog_db.* TO 'blog_user'@'localhost';
FLUSH PRIVILEGES;

### 4. Maven安装与配置

#### 安装Maven
# Windows: 下载并解压到 C:\Program Files\Apache\Maven
# 设置环境变量
M2_HOME=C:\Program Files\Apache\Maven\apache-maven-3.8.6
PATH=%M2_HOME%\bin;%PATH%

# Linux/macOS
wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
tar -xzf apache-maven-3.8.6-bin.tar.gz
sudo mv apache-maven-3.8.6 /opt/maven
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH

# 验证安装
mvn -version

#### 项目部署步骤

#导入项目到Eclipse
启动 Eclipse IDE

选择 File → Import → Maven → Existing Maven Projects

浏览并选择项目根目录（包含 pom.xml 的文件夹）

点击 Finish 完成导入

等待 Maven 依赖下载完成（首次导入可能需要几分钟）

# 数据库连接配置
在 src/main/java/com/yourblog/util/DatabaseUtil.java 中修改数据库连接信息：
// 更新以下配置
private static final String URL = "jdbc:mysql://localhost:3306/blog_db?useSSL=false&serverTimezone=UTC";
private static final String USERNAME = "your_username";
private static final String PASSWORD = "your_password";

确保 MySQL JDBC 驱动在 pom.xml 中正确配置：
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>

# 配置tomcat服务器
在 Eclipse 中，右键项目 → Properties → Project Facets

确保勾选 Dynamic Web Module 和 Java

在 Servers 视图右键 → New → Server

选择 Apache Tomcat v11.0 Server

将项目添加到服务器的配置中

# 构建与部署
右键项目 → Run As → Maven build

在 Goals 中输入：clean compile

右键项目 → Run As → Run on Server

选择配置好的 Tomcat 服务器

# 访问应用
启动 Tomcat 服务器

打开浏览器访问：http://localhost:8080/meow-blog

如遇端口冲突，可在 Tomcat 的 server.xml 中修改端口号


