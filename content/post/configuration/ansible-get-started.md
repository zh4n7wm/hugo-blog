---
title: "ansible入门"
date: 2017-12-15T19:21:57+08:00
tags: ["linux", " mac", " ansible"]
author: "ox0spy"
categories: ["configuration"]
---

Ansible是


## 安装ansible

### Mac上安装

    $ brew install ansible

Mac上brew安装后，默认的hosts配置文件路径是`/usr/local/etc/ansible/hosts`，可以通过`ANSIBLE_INVENTORY`环境变量修改hosts路径。

    $ tail -1 ~/.zshrc
    export ANSIBLE_INVENTORY=/etc/ansible/hosts


### Linux上都有ansible安装包，可以通过包管理工具安装。

    # Ubuntu/Debian
    $ sudo apt-get install ansible

    # CentOS
    $ sudo yum install ansible

### 测试是否安装成功 -- 第一条命令

将自己有权限登录的机器添加到 `/etc/ansible/hosts` 文件中，该文件是 `ini` 配置文件格式，如下：

    $ cat /etc/ansible/hosts
    192.168.1.118

运行下面命令测试：

    $ ansible all -m ping
	192.168.1.118 | SUCCESS => {
    "changed": false,
    "ping": "pong"
    }

看到上面的 `SUCCESS` 说明已经可以通过`ansible`连接远程主机了。


### ansible配置文件

ansible的配置文件是 `/etc/ansible/ansible.cfg` 或 `~/.ansible.cfg`

避免由于主机重装、更新IP导致的 `known_hosts issue`，可以将 `host_key_checking = False` 添加到ansible配置文件中。

    $ cat ~/.ansible.cfg
    [defaults]
    host_key_checking = False

也可以通过环境变量完成 `export ANSIBLE_HOST_KEY_CHECKING=False`

log_path # FIXME

### ansible的常用命令行选项

- `--ask-pass`: 需要输入登录密码
- `--ask-become-pass`: 需要输入`sudo`密码
- `--private-key`: 指定使用的ssh private key
- `-u <username>`: 指定登录用户名
- `-b|--become`: 登录主机后切换到`sudo`权限
- `--become-user <username>`: 登录主机后切换到`username`

### Inventory

#### AWS Dynamic Inventory

使用 `ec2.py` 动态生成 `Inventory`:

  $ sudo wget -O /etc/ansible/ec2.ini https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
  $ sudo wget -O /etc/ansible/ec2.py https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py
  $ sudo chmod +x /etc/ansible/ec2.py

指定profile:

  $ /etc/ansible/ec2.py --profile prod --list
  $ AWS_PROFILE=prod ansible -i /etc/ansible/ec2.py all -m pin
  $ AWS_PROFILE=prod ansible-playbook -i ec2.py myplaybook.yml

`/etc/ansible/ec2.ini` 的 `cache_path` 指定了 `ec2.py` 的缓存结果，清除缓存:

  $ /etc/ansible/ec2.py --refresh-cache

### playbooks

安装apache的实例:

playbook语法检查:

  $ ansible-playbook playbook.yml --syntax-check

查看playbook会在哪些hosts上运行:

  $ ansible-playbook playbook.yml --list-hosts

### variables

#### 变量作用域

- Global: this is set by config, environment variables and the command line
- Play: each play and contained structures, vars entries, include_vars, role defaults and vars.
- Host: variables directly associated to a host, like inventory, facts or registered task outputs

通过命令行传变量:

  ---
  - hosts: '{{ hosts }}'
    remote_user: '{{ user }}'
    tasks:
      - ...

  $ ansible-playbook release.yml --extra-vars "hosts=vipers user=starbuck" # key=value
  $ --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}' # json
  $ --extra-vars "@some_file.json" # json file