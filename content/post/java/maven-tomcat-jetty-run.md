---
title: "maven通过plugin在tomcat、jetty中运行项目"
date: 2017-12-15T19:22:00+08:00
tags: ["java", "maven", "tomcat", "jetty"]
author: "ox0spy"
categories: ["java"]
---

记录下如何在pom.xml中配置插件，通过tomcat、Jetty运行项目.

## 配置pom.xml

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.tomcat.maven</groupId>
            <artifactId>tomcat6-maven-plugin</artifactId>
            <version>2.2</version>
        </plugin>

        <plugin>
            <groupId>org.apache.tomcat.maven</groupId>
            <artifactId>tomcat7-maven-plugin</artifactId>
            <version>2.2</version>
        </plugin>

        <plugin>
            <groupId>org.mortbay.jetty</groupId>
            <artifactId>jetty-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

## 测试

### Maven Tomcat plugin

    :::bash
    $ mvn tomcat:run
    $ mvn tomcat7:run

### Maven Jetty plugin
    :::bash
    $ mvn jetty:run