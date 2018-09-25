---
title: "code formatter with ide"
author: "ox0spy"
categories: ["java", "eclipse", "IDEA"]
---

### 代码格式化

## 导入 Google java code style xml 配置

从 [google style guide](https://github.com/google/styleguide) 下载配置文件。

### IDEA Intellij

- 下载 intellij-java-google-style.xml
- IDEA -> Preferences -> Editor -> Code Style -> Java，Scheme -> Import Scheme -> Intellij IDEA code style xml，选择下载的 intellij-java-google-style.xml 文件。

### Eclipse

- 下载 eclipse-java-google-style.xml
- Eclipse -> Preferences -> Java -> Code Style -> Formatter，`Import...`，选择 eclipse-java-google-style.xml 文件。

参考链接：

- [Eclipse Google Java Style Guide](http://www.practicesofmastery.com/post/eclipse-google-java-style-guide/)
- [Netty - Setting up development environment](https://netty.io/wiki/setting-up-development-environment.html)

## google java format (可选)

如果用上面的方法已经配置好了，可以不用再通过这种方法设置了。它的好处是可以在命令行格式化代码。

使用 [google java format](https://github.com/google/google-java-format) 自动格式化代码风格。

### IDEA

安装插件 [google-java-format](https://plugins.jetbrains.com/plugin/8527-google-java-format)

重启 IDEA，IDEA -> Preferences -> google-java-format Settings，选中 `Enable google-java-format`

### Eclipse

下载插件 [google-java-format Eclipse
plugin](https://github.com/google/google-java-format/releases)，放到
Eclipse 安装目录下：

    $ cp ~/Downloads/google-java-format-eclipse-plugin_1.6.0.jar /Applications/Eclipse\ JEE.app/Contents/Eclipse/plugins/

重启 Eclipse，Eclipse > Preferences > Java > Code Style > Formatter > Formatter Implementation，选择 google-java-format。

### 命令行格式化代码

[Third-party integrations](https://github.com/google/google-java-format#third-party-integrations)
