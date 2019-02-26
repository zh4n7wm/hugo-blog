---
title: "禁用笔记本键盘"
date: 2019-02-26T09:22:01+08:00
tags: ["linux", "tips"]
author: "ox0spy"
categories: ["Linux"]
---

记录如何禁用笔记本自带键盘。

因为笔记本自带键盘坏了，`Enter` 键随机处于被按下的状态，导致无法使用。接入外接键盘后，禁用笔记本自带键盘。

以下内容只在 `Ubuntu 18.04` 上测试过，虽然 `Linux` 系统差异不大，但不保证其它系统中可用。

## 禁用笔记本键盘

用 `xinput` 工具查看、禁用、启用笔记本键盘，如果系统没有提供该工具，可以用包管理工具安装。

### 查看键盘

    $ xinput list

### 方法一：Remove slave from its current master device

    $ sudo xinput float <id>

注：<id> 是从 `xinput list` 输出的需要禁用的键盘 id

如 `AT Translated Set 2 keyboard id=15 [slave  keyboard (3)]` 则 id 为 15

### 方法二： Disable the device

禁用：

    $ sudo xinput --disable <id>

    等同于
    $ sudo xinput --set-prop <id> "Device Enabled" 1

再次启用：

    $ sudo xinput --enable <id>

    等同于
    $ sudo xinput --set-prop <id> "Device Enabled" 0

### 方法三：Disabling on Boot

修改 `grub` 的配置文件，启动时就禁用 **内置键盘**。

修改 `/etc/default/grub`，将 `i8042.nokbd` 加入 `GRUB_CMDLINE_LINUX_DEFAULT`，如下：

    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.nokbd"

更新 `grub`：

    $ sudo update-grub

重启后，内置键盘将被禁用。
