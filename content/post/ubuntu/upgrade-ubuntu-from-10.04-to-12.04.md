---
title: "upgrade ubuntu from 10.04 to 12.04"
date: 2017-12-15T19:22:01+08:00
tags: ["ubuntu", " nis"]
categories: ["ubuntu"]
---

公司开发人员电脑都安装的是Ubuntu 10.04，现在越来越不好用，而且，很多同事发现编译最新的Firefox OS都有问题，所以，我尝试升级并把碰到的问题记录下来。

升级
=====

修改源
-------

    :::bash

    $ cat /etc/apt/sources.list
    deb http://172.26.32.18/ubuntu/ lucid main restricted universe multiverse
    deb http://172.26.32.18/ubuntu/ lucid-security main restricted universe multiverse
    deb http://172.26.32.18/ubuntu/ lucid-updates main restricted universe multiverse
    deb http://172.26.32.18/ubuntu/ lucid-proposed main restricted universe multiverse
    deb http://172.26.32.18/ubuntu/ lucid-backports main restricted universe multiverse

    # aliyun
    deb http://mirrors.aliyun.com/ubuntu/ lucid main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ lucid-security main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ lucid-updates main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ lucid-proposed main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ lucid-backports main restricted universe multiverse


开始升级
---------

    :::bash
    $ sudo do-release-upgrade

nis无法启动，导致升级过程中配置nis包失败
-----------------------------------------

    :::bash
    $ grep redhat /etc/hosts
    172.26.32.12    cd-redhat-001.TCTCD

    $ tail -1 /etc/yp.conf 
    ypserver cd-redhat-001.TCTCD

    $ cat /etc/defaultdomain 
    TCTCD

    $ grep NIS /etc/default/nis | grep -Ev '#'
    NISSERVER=false
    NISCLIENT=true
    NISMASTER=

    $ cat /etc/auto.master
    /home /etc/auto.home

    $ cat /etc/auto.home 
    xcsu cd-redhat-001.TCTCD:/home/xcsu

    $ /usr/lib/yp/ypinit -s cd-redhat-001.TCTCD

    $ sudo service portmap restart
    $ sudo service nis restart

启动后登录时发现只能用administrator和guest登录
===============================================

    :::bash
    $ cat /etc/lightdm/lightdm.conf 
    [SeatDefaults]
    user-session=ubuntu
    greeter-session=unity-greeter
    allow-guest=false
    greeter-show-manual-login=true

重启电脑，就可以用其它用户登录了
---------------------------------

    :::bash
    $ sudo reboot