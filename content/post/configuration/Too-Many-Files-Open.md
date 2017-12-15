---
title: "too many files open"
date: 2017-12-15T19:21:57+08:00
tags: ["mac", " linux"]
author: "ox0spy"
categories: ["configuration"]
---

## Linux

将下面的行加入 `/etc/security/limits.conf`

    *               soft    nofile             8192
    *               hard    nofile             8192

将下面的行加入 `/etc/sysctl.conf` ，提高kernel性能，可以不添加。

    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.tcp_tw_recycle = 1
    net.ipv4.ip_local_port_range = 1024 65000
    fs.file-max = 65000

运行 `sudo sysctl -p` 将对 `/etc/sysctl.conf` 的修改生效。


## Mac

查看max files:

	$ sudo launchctl limit
        cpu         unlimited      unlimited
        filesize    unlimited      unlimited
        data        unlimited      unlimited
        stack       8388608        67104768
        core        0              unlimited
        rss         unlimited      unlimited
        memlock     unlimited      unlimited
        maxproc     709            1064
        maxfiles    256            unlimited

修改max file到8192:

    $ sudo launchctl limit maxfiles 8192 unlimited
	$ sudo launchctl limit
        cpu         unlimited      unlimited
        filesize    unlimited      unlimited
        data        unlimited      unlimited
        stack       8388608        67104768
        core        0              unlimited
        rss         unlimited      unlimited
        memlock     unlimited      unlimited
        maxproc     709            1064
        maxfiles    8192           10240

    # 注：
    $ sudo launchctl limit maxfiles unlimited  # 也可以直接设置为unlimited