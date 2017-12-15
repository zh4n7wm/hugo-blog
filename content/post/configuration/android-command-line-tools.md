---
title: "android命令行工具"
date: 2017-12-15T19:21:58+08:00
tags: ["android"]
author: "ox0spy"
categories: ["configuration"]
---

## Android命令行工具

### android

下面介绍命令行下使用android脚本。

场景：命令行下安装android build tools、sdk、API。

获取所有可用的包:

    :::bash
    $ android list sdk -a -u
    $ android list sdk -a -u --proxy-host proxy-host --proxy-port proxy-port  # 设置代理

安装指定的包：(num1, num2是上面命令返回的序号)

    :::bash
    $ android update sdk -u -a -t <num1,num2>

安装指定平台的包:

    $ android update sdk -u --filter platform-tools,android-24
    $ android update sdk -u --all --filter <number> # item前面的编号