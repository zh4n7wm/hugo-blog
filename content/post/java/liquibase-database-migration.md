---
title: "liquibase for Java database migration"
author: "ox0spy"
categories: ["java", "database", "migration", "liquibase"]
---

## 维护项目中的数据库 schema

### 简介

团队开发项目时，每个人都有可能修改数据库表的结构，但不同人修改了表结构后，如何确保修改记录的同步？

也许让所有人维护一个 SQL 文件，所有人修改表结构时都要修改、提交 该 SQL 文件记录。

应该能起到一定作用，但想回退数据库又比较麻烦了。

一些项目已经能协助我们完成该工作，Java 世界最流行的应该是下面两个：

- [Liquibase](https://www.liquibase.org/)
- [Flywaydb](https://flywaydb.org/)

本文只介绍 Liquibase。

#### 安装 Liquibase 命令行工具：(如果在命令行使用才需要安装)

    $ brew install liquibase

### 通过 Maven plugin 集成到项目中使用

通过 Maven plugin 集成到项目中，方便使用。

在 pom.xm 中添加：

    <plugin>
        <groupId>org.liquibase</groupId>
        <artifactId>liquibase-maven-plugin</artifactId>
        <version>3.6.2</version>
        <configuration>
            <verbose>true</verbose>
            <propertyFile>${basedir}/src/main/resources/liquibase/liquibase.properties</propertyFile>
            <changeLogFile>${basedir}/src/main/resources/liquibase/db.changelog.xml</changeLogFile>
            <outputChangeLogFile>${basedir}/src/main/resources/liquibase/output.xml</outputChangeLogFile>
            <promptOnNonLocalDatabase>false</promptOnNonLocalDatabase>
        </configuration>
    </plugin>


#### liquibase 配置

liquibase 配置文件：`${basedir}/src/main/resources/liquibase/liquibase.properties`

让 liquibase 知道如何连接数据库，内容如下：（liquibase支持很多数据库，我用MySQL做测试）

    driver=com.mysql.jdbc.Driver
    url=jdbc:MySQL://localhost:3306/testdb?createDatabaseIfNotExist=true
    username=mysql-username
    password=mysql-password

注：testdb 是本文的测试库，根据自己实际情况设置

changelog 配置文件：`${basedir}/src/main/resources/liquibase/db.changelog.xml`

该文件记录了数据库变更，liquibase 将数据库变更更新到数据库中，文件内容如下：

    <?xml version="1.1" encoding="UTF-8" standalone="no"?>
    <databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog" xmlns:ext="http://www.liquibase.org/xml/ns/dbchangelog-ext" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.6.xsd">
    <include file="src/main/resources/liquibase/changelog/initial.xml" relativeToChangelogFile="false"/>
    <include file="src/main/resources/liquibase/changelog/add-new-table-just_test.xml" relativeToChangelogFile="false"/>
    </databaseChangeLog>


##### changelog 文件

changelog 文件支持多种书写语法，下面是它自己的 dsl 语法：

`<include file="src/main/resources/liquibase/changelog/initial.xml" relativeToChangelogFile="false"/>`，引入一个变更文件。

    $ cat src/main/resources/liquibase/changelog/initial.xml
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

changelog 同时支持 SQL 语句书写：

    $ cat src/main/resources/liquibase/changelog/initial.xml
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

#### 更新数据库

通过上面的配置，就可以更新数据库了。

generateChangeLog 命令，可以将当前数据库的schema导出为 changelog 文件，适用于已经存在的项目。

    $ mvn -X liquibase:generateChangeLog

update 命令，将所有 changeset 更新到数据库：

    $ mvn liquibase:update

tag 命令，标记 checkpoint，方便未来回滚到指定 checkpoint

    $ mvn liquibase:tag -Dliquibase.tag=checkpoint

rollback 回滚命令，将数据库中的一些 changeset 回滚：

    $ mvn liquibase:rollback -Dliquibase.rollbackCount=1  # 回滚最后一次 changeset

    $ mvn liquibase:rollback -Dliquibase.rollbackTag=checkpoint  # 回滚到指定 checkpoint

注：命令后面带 `SQL` 意思是生成对应的 SQL 语句

## 参考文档

- [How To Execute Database Migrations With Liquibase](https://blog.smaato.com/how-to-execute-database-migrations-with-liquibase)
- [Liquibase 筆記](http://blog.kent-chiu.com/2014/08/30/liquibase-101.html)
