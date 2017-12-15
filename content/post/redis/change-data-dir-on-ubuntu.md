---
title: "ubuntu 16.04上修改redis data dir"
date: 2017-12-15T19:21:59+08:00
tags: ["redis", " ubuntu"]
author: "zhang wanming"
categories: ["redis"]
---

## 修改redis 的data dir

redis是通过`sudo apt-get install redis-server`命令安装的。

### 修改 /etc/redis/redis.conf

  dir /data/redisdata

注：将redis data dir 修改为`dir /data/redisdata`

### 修改 /etc/systemd/system/redis.service

在该文件中加入一行：`ReadWriteDirectories=-/data/redisdata`

### 测试是否可以正常保存

  $ redis-cli
  127.0.0.1:6379> save


## 报错

之前只修改了 `/etc/redis/redis.conf` 下的配置，而没有修改 `/etc/systemd/system/redis.service` ，所以一直报如下错误：

  9827:M 17 Jan 15:08:22.596 # Failed opening .rdb for saving: Read-only file system