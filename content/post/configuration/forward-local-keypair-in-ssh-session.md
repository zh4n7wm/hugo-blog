---
title: "forward local keypair in ssh session"
date: 2018-10-25T18:01:58+08:00
tags: ["linux", " ssh", " tunnel"]
author: "ox0spy"
categories: ["configuration"]
---

**SSH 不应该通过密码认证，只应该通过 ssh keypair 认证。**

如果我既有登录 A 机器的权限，也有登录 B 机器的权限。那么，通过 `ssh-copy-id` 配置后，就可以从本地自动登录 A、B 机器了。但 A 机器没有登录 B 机器的权限。

如果需要从 A 机器 登录 B 机器，应该怎么办呢？

- ~~在 A 机器上通过 `ssh-keygen` 生成 keypair，然后将公钥放到B机器的 `~/.ssh/authorized_keys`？~~
- forward agent？

服务器上不应该放 keypair，所以，方案一不可取。

本文介绍 `forward agent` 方案。

## forward agent

### 确保 ssh-agent 已经运行

    $ ssh-agent

    或者

    $ eval "$(ssh-agent)"

### 添加想要转发的 ssh private key 到 ssh agent

    $ ssh-add <path-to-key/private-key-name>

比如：

    $ ssh-add ~/.ssh/id_rsa

列出 ssh agent 中的key:

    $ ssh-add -L

### 登录 A主机

从本地登录 主机A：

    $ ssh -A host-A  # 假设 host-A 的登录信息已经在 ~/.ssh/config 中配置过

注：`-A` 参数用来转发 key

通过上面命令登录到 主机A 后，通过 `ssh-add -L` 查看是否有 key。

    host-A:~$ ssh-add -L  # 应该能看到自己之前添加的 key，否则无法登录到 主机B 的

### 登录 B 主机：

在 A主机 上登录 B主机：

    host-A:~$ ssh host-B

### 每次都需要手动输入 -A 很麻烦

修改 `~/.ssh/config`，如下：

    Host host-B
        Hostname host-B
        user <username>
        Port <port>
        IdentityFile <~/.ssh/id_rsa>
        ForwardAgent yes

注：其实就是加了：`ForwardAgent yes`。这样就不需要每次手动输入 `ssh -A`。

### 能不能对所有主机配置？

答案当然是肯定的！

    Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile ~/.ssh/id_rsa

### ssh-agent 还能让你避免每次为ssh key 输入密码

如果你的 ssh keypair 设置过密码，那么 `ssh-add` 时就要求输入密码，这样避免每次使用 ssh keypair 都需要输入密码。
