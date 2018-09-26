---
title: "liquibase with Maven support multiply deploy environments"
date: 2018-09-26T10:06:00+08:00
author: "ox0spy"
categories: ["java", "database", "migration", "liquibase"]
---

## Liquibase 简介

> Liquibase is an open-source database-independent library for tracking, managing and applying database schema changes. It was started in 2006 to allow easier tracking of database changes, especially in an agile software development environment.

方便管理、维护数据库 schema 变化。

## Maven 集成 Liquibase

目录结构

```
|-- pom.xml
`-- src
    `-- main
       |-- resources
       |   `-- liquibase.properties
       |   |-- changelog
       |       `-- db-changelog-master.xml
       |       `-- db-changelog-1.0.xml
       |       `-- db-changelog-add-table-admin.xml
       |-- filters
           |-- dev
           |   `-- db.properties
           |-- prod
           |   `-- db.properties
```

### pom.xml 配置文件

添加 liquibase-maven-plugin

```
      <plugin>
        <groupId>org.liquibase</groupId>
        <artifactId>liquibase-maven-plugin</artifactId>
        <version>3.6.2</version>
        <configuration>
          <propertyFile>target/classes/liquibase.properties</propertyFile>
        </configuration>
      </plugin>
```

添加 maven filters

```
  <profiles>
    <profile>
      <id>dev</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <build>
        <filters>
          <filter>src/main/filters/dev/db.properties</filter>
        </filters>
        <resources>
          <resource>
            <directory>src/main/resources</directory>
            <filtering>true</filtering>
          </resource>
        </resources>
      </build>
    </profile>
    <profile>
      <id>prod</id>
      <build>
        <filters>
          <filter>src/main/filters/prod/db.properties</filter>
        </filters>
        <resources>
          <resource>
            <directory>src/main/resources</directory>
            <filtering>true</filtering>
          </resource>
        </resources>
      </build>
    </profile>
  </profiles>

```

### src/main/filters 目录里的配置文件

```
src/main/filters
├── dev
│   └── db.properties
└── prod
    └── db.properties
```

可以为不同环境创建不同的配置文件。

src/main/filters/dev/db.properties 文件内容

```
database.driver=com.mysql.jdbc.Driver
database.url=jdbc:MySQL://localhost:3306/your-dbname?createDatabaseIfNotExist=true
database.username=dbuser
database.password=dbpasswd
```

注：** 根据自己数据库配置，修改 db.properties **

### src/main/resources/liquibase.properties 配置文件

```
driver: ${database.driver}
url: ${database.url}
username: ${database.username}
password: ${database.password}
changeLogFile: changelog/db-changelog-master.xml
outputChangeLogFile: output.xml
verbose: true
```

### changelog xml 文件

changelog 文件支持多种书写语法，下面是它自己的 dsl 语法：

```
<?xml version="1.1" encoding="UTF-8" standalone="no"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog" xmlns:ext="http://www.liquibase.org/xml/ns/dbchangelog-ext" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.6.xsd">
    <changeSet id="add-new-table-just_test" author="wm">
        <createTable tableName="just_test">
            <column autoIncrement="true" name="id" type="BIGINT">
                <constraints primaryKey="true"/>
            </column>
            <column name="name" remarks="用户名" type="VARCHAR(255)"/>
        </createTable>
        <rollback> <!-- 回滚操作 -->
            <dropTable tableName="just_test" />
        </rollback>
    </changeSet>
</databaseChangeLog>
```

changelog 同时支持 SQL 语句书写：

```
<?xml version="1.1" encoding="UTF-8" standalone="no"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog" xmlns:ext="http://www.liquibase.org/xml/ns/dbchangelog-ext" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.6.xsd">
    <changeSet id="add-new-table-just_test" author="wm">
        <sql>
            CREATE TABLE just_test ( id bigint(20) NOT NULL AUTO_INCREMENT, name varchar(255) DEFAULT NULL COMMENT '用户名', PRIMARY KEY (`id`));
        </sql>
        <rollback> <!-- 回滚操作 -->
            <sql>
                DROP TABLE just_test;
            </sql>
        </rollback>
    </changeSet>
</databaseChangeLog>
```

更详细的学习changelog 语法：<https://www.liquibase.org/documentation/changeset.html>


### 管理 schema

#### 将 changelog xml 中的更新应用到数据库

```
$ mvn resources:resources liquibase:update -Pdev  # -Pprod 使用 src/main/filters/prod/db.properties 配置连接数据库，并更新数据库 schema
```

#### 将数据库schema 生成 changelog xml

```
$ mvn resources:resources liquibase:generateChangeLog -Pdev
```

如果项目已经开发了一段时间后才将 Liquibase 引入项目，则可以用该命令生成初始的 changelog xml。以后在这个基础上更新数据库 schema 时添加新的 changelog xml。

注：** 多次运行该命令将导致一个数据库 schema 被多次写入 output.xml，所以，确保运行命令前先删除 output.xml。**

#### 标记 checkpoint

tag 命令，标记 checkpoint，方便未来回滚到指定 checkpoint

```
$ mvn resources:resources liquibase:tag -Dliquibase.tag=checkpoint
```

#### 回滚数据库 schema 修改

如果已经修改了数据库 schema，但又想回滚，可以通过 rollback 命令完成。

```
$ mvn resources:resources liquibase:rollback -Dliquibase.rollbackCount=1  # 回滚最后一次 changeset

$ mvn resources:resources liquibase:rollback -Dliquibase.rollbackTag=checkpoint  # 回滚到指定 checkpoint
```
