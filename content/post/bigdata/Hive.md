---
title: "在mac osx练习hive"
date: 2017-12-15T19:22:01+08:00
tags: ["mac", " hive", " bigdata"]
author: "ox0spy"
categories: ["bigdata"]
---

# Hive

## 安装

将Hive的metastore存在MySQL中。

Mac OSX 上安装 Hive

	$ brew install hive mysql
	$ brew services start mysql
	$ tail -n 3 ~/.zshrc
	# Hive
	export HIVE_HOME="/usr/local/opt/hive"
	export HCAT_HOME="$HIVE_HOME/libexec/hcatalog"
	$ source ~/.zshrc

为Hive在MySQL中创建数据库，并分配用户访问权限。

	$ mysql -u root -p
	mysql> create database metastore;
	mysql> grant all privileges on metastore.* to 'hive'@'localhost' identified by 'hive';

下载MySQL jdbc connector：

	$ wget -P /tmp/ https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz
	$ cd /tmp/ && tar zxf mysql-connector-java-5.1.42.tar.gz
	$ mv mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar $(brew --prefix hive)/libexec/lib/

修改 libexec/conf/hive-site.xml

	$ cd $(brew --prefix hive)
	$ cp libexec/conf/hive-default.xml.template libexec/conf/hive-site.xml
	$ 修改 hive-site.xml
	<property>
		<name>javax.jdo.option.ConnectionURL</name>
		<value>jdbc:mysql://localhost/metastore?useSSL=false</value>
		<description>
		JDBC connect string for a JDBC metastore.
		To use SSL to encrypt/authenticate the connection, provide database-specific SSL flag in the connection URL.
		For example, jdbc:postgresql://myhost/db?ssl=true for postgres database.
		</description>
	</property>
	<property>
   		<name>javax.jdo.option.ConnectionDriverName</name>
   		<value>com.mysql.jdbc.Driver</value>
		<description>Driver class name for a JDBC metastore</description>
	</property>
	<property>
		<name>javax.jdo.option.ConnectionUserName</name>
		<value>hive</value>
		<description>Username to use against metastore database</description>
	</property>
	<property>
		<name>javax.jdo.option.ConnectionPassword</name>
		<value>hive</value>
		<description>password to use against metastore database</description>
	</property>

运行 Hive：

	$ hive
	hive> show tables;

### 参考

- [Configuring the Hive Metastore](https://www.cloudera.com/documentation/enterprise/5-6-x/topics/cdh_ig_hive_metastore_configure.html)

## 访问hdfs和主机

- !前缀运行宿主操作系统的命令
- dfs 命令访问hdfs

示例：

	hive> !pwd;
	hive> dfs -ls;
	
	注：命令都必须以';'结尾

## Hive数据处理

### 创建表结构，并加载数据

	hive> CREATE TABLE records (year STRING, temperature INT, quality INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
	hive> LOAD DATA LOCAL INPATH './sample.txt' OVERWRITE INTO TABLE records;
	
	注：最后一条命令从本机的当前目录加载数据
	   OVERWRITE关键字告诉Hive删除表对应目录中已有的所有文件；如果省去这一关键字，Hive就简单地把新的文件加入目录。

演示如何用Hive解决之前Pig解决的问题 - 得到年度最高气温：

	hive> SELECT year, MAX(temperature) FROM records WHERE temperature != 9999 and (quality = 0 OR quality = 1 OR quality = 4 OR quality = 5 OR quality = 9) GROUP BY year;