---
title: "Setup LVS and Keepalived on Debian"
author: "ox0spy"
date: 2014-06-26T00:00:00+08:00
tags: ["LVS", "keepalived", "Debian"]
---

# 准备机器

* LVS_MASTER - 172.16.8.129
* LVS_BACKUP - 172.16.8.130
* WEB_APP_SERVER_1 - 172.16.8.131
* WEB_APP_SERVER_2 - 172.16.8.132

注:
1. virtual server: 172.16.8.252 (非真实机器, 只需要在web app server上配下这个IP)
2. 所有机器都安装的Debian 7.5 (wheezy)


# 安装软件

## LVS_MASTER上安装配置LVS和keepalived

    $ ssh LVS_MASTER
    $ sudo apt-get install ipvsadm keepalived


### 配置LVS

    $ cat /etc/default/ipvsadm
    # ipvsadm

    # if you want to start ipvsadm on boot set this to true
    AUTO="false"

    # daemon method (none|master|backup)
    DAEMON="master"

    # use interface (eth0,eth1...)
    IFACE="eth0"

    # syncid to use
    SYNCID="1"

### 配置keepalived

    $ cat /etc/keepalived/keepalived.conf
    global_defs {
    router_id LVS_MASTER   #BACKUP上修改为LVS_BACKUP
    }

    vrrp_instance VI_1 {
        state MASTER          #BACKUP上修改为BACKUP
        interface eth0
        virtual_router_id 51  #与备机的id必须一致
        priority 100          #BACKUP上修改为80
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
            172.16.8.252     #virtual server
        }
    }

    virtual_server 172.16.8.252 80 {
        delay_loop 6
        lb_algo rr
        lb_kind DR
        #lb_kind NAT
        #persistence_timeout 5
        protocol TCP

        real_server 172.16.8.131 80 {
            weight 3
            TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
            }
        }

        real_server 172.16.8.132 80 {
            weight 3
            TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
            }
        }
    }


## LVS_BACKUP上安装配置LVS和keepalived

    $ ssh LVS_BACKUP
    $ sudo apt-get install ipvsadm keepalived


### 配置LVS

    $ cat /etc/default/ipvsadm
    # ipvsadm

    # if you want to start ipvsadm on boot set this to true
    AUTO="false"

    # daemon method (none|master|backup)
    DAEMON="backup"

    # use interface (eth0,eth1...)
    IFACE="eth0"

    # syncid to use
    SYNCID="1"

### 配置keepalived

    $ cat /etc/keepalived/keepalived.conf
    global_defs {
    router_id LVS_BACKUP #BACKUP上修改为LVS_BACKUP
    }

    vrrp_instance VI_1 {
        state BACKUP          #BACKUP上修改为BACKUP
        interface eth0
        virtual_router_id 51  #与备机的id必须一致
        priority 80           #BACKUP上修改为80
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
            172.16.8.252     #virtual server
        }
    }

    virtual_server 172.16.8.252 80 {
        delay_loop 6
        lb_algo rr
        lb_kind DR
        #lb_kind NAT
        #persistence_timeout 5
        protocol TCP

        real_server 172.16.8.131 80 {
            weight 3
            TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
            }
        }

        real_server 172.16.8.132 80 {
            weight 3
            TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 80
            }
        }
    }

## 配置WEB_APP_SERVER_1

### 安装nginx

    $ ssh WEB_APP_SERVER_1
    $ sudo apt-get install nginx
    $ sudo bash -c 'echo "Web App Server 1" > /usr/share/nginx/www/index.html'

### 配置IP

    $ sudo ifconfig eth0:0 172.16.8.252 netmask 255.255.255.255 up

修改配置文件 （上面的配置重启后需要重新输入命令）

    $ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
    auto lo
    auto eth0
    auto eth0:0

    iface lo inet loopback

# The primary network interface
    allow-hotplug eth0
#iface eth0 inet dhcp
    iface eth0 inet static
            address 172.16.8.131
            netmask 255.255.255.0
            gateway 172.16.8.2

    iface eth0:0 inet static
            address 172.16.8.252
            netmask 255.255.255.255
            gateway 172.16.8.2


## 配置WEB_APP_SERVER_2

### 安装nginx

    $ ssh WEB_APP_SERVER_2
    $ sudo apt-get install nginx
    $ sudo bash -c 'echo "Web App Server 2" > /usr/share/nginx/www/index.html'


### 配置IP

    $ sudo ifconfig eth0:0 172.16.8.252 netmask 255.255.255.255 up

修改配置文件 （上面的配置重启后需要重新输入命令）

    $ cat /etc/network/interfaces
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    # The loopback network interface
    auto lo
    auto eth0
    auto eth0:0

    iface lo inet loopback

    # The primary network interface
    allow-hotplug eth0
    #iface eth0 inet dhcp
    iface eth0 inet static
            address 172.16.8.132
            netmask 255.255.255.0
            gateway 172.16.8.2

    iface eth0:0 inet static
            address 172.16.8.252
            netmask 255.255.255.255
            gateway 172.16.8.2

    # 启动LVS, keepalived
    $ ssh LVS_MASTER
    $ sudo service ipvsadm restart
    $ sudo service keepalived restart

    $ ssh LVS_BACKUP
    $ sudo service ipvsadm restart
    $ sudo service keepalived restart


# 测试
## 查看服务器状态

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 1
    Web App Server 2
    Web App Server 1
    Web App Server 2
    ...

    $ ssh LVS_MASTER
    $ sudo ipvsadm -ln
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.16.8.252:80 rr
    -> 172.16.8.131:80              Route   3      0          29
    -> 172.16.8.132:80              Route   3      0          30


## 将WEB_APP_SERVER_1的nginx进程结束，查看效果

    $ ssh WEB_APP_SERVER_1
    $ sudo service nginx stop

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    curl: (7) couldn't connect to host
    Web App Server 2
    curl: (7) couldn't connect to host
    Web App Server 2
    curl: (7) couldn't connect to host
    Web App Server 2
    Web App Server 2
    Web App Server 2
    Web App Server 2
    ...

    $ sudo ipvsadm -ln
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.16.8.252:80 rr
    -> 172.16.8.132:80              Route   3      0          114

    $ ssh WEB_APP_SERVER_1
    $ sudo service nginx stop

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 1
    Web App Server 2
    Web App Server 1
    Web App Server 2
    ...


## 将LVS_MASTER关闭，查看请求web app server的结果

    $ ssh LVS_MASTER
    $ sudo shutdown -h now

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 1
    Web App Server 2
    Web App Server 1
    Web App Server 2
    ...
