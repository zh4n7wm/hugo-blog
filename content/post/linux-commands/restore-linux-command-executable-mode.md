---
title: "复恢Linux命令的执行权限"
date: 2018-08-09T16:21:59+08:00
author: "ox0spy"
categories: ["Linux"]
---

> 问题：linux服务器上/bin,/sbin,/usr/bin目录下所有文件都被执行了chmod
> -x，但是bash窗口还在，并且是sudo权限 - `蛋疼的axb`

详见：<https://weibo.com/1809500942/GswhBroTL>

整理下大家贴出来的方案。

## 解决方法

### umask

设置 umask 后，新创建的文件权限会基于 umask 值来设置。

比如：默认 umask 的值为 `022`

新创建文件的权限：666 - 022 = 644

### ld-linux

> 可以用 /lib/ld-linux.so.2 （或 /lib64/ld-linux-x86-64.so.2） 直接加载运行 ELF
> 程序，不需要执行权限，比如 /lib/ld-linux.so.2 /bin/chmod +x /bin/* ... -- by Verdano

    $ sudo /lib64/ld-linux-x86-64.so.2 /bin/chmod +x /bin/*

### 其它语言的 chmod

> 用/usr/local/bin 下的python，直接os.chmod()，瞬间命令全搞定？[吃瓜] -- by 我是谁我是在哪儿我又在干什么

#### Python

    # Python 2
    $ python -c 'import os; os.chmod("/bin/chmod", 0755)'

    # Python 3
    $ python -c 'import os; os.chmod("/bin/chmod", 0o755)'

注：

- 其它语言类似，差不多所有语言都有操作系统的 API 封装。
- 如果 `/usr/bin/`
  下的所有命令都被去掉可执行权限的话，大部分语言的解析器也没法运行起来了。

### 重启进 recovery mode

并不适合线上服务器。
