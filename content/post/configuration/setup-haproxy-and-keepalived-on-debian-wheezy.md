---
title: "setup haproxy and keepalived on debian (wheezy)"
author: "ox0spy"
date: 2014-07-01T00:00:00+08:00
tags: ["haproxy", "keepalived"]
---

# 准备机器
* harpoxy_MASTER - 172.16.8.129
* haproxy_BACKUP - 172.16.8.130
* WEB_APP_SERVER_1 - 172.16.8.131
* WEB_APP_SERVER_2 - 172.16.8.132

注:
1. virtual server: 172.16.8.252 (非真实机器, 只需要在web app server上配下这个IP)
2. 所有机器都安装的Debian 7.5 (wheezy)

# 安装软件

## haproxy_MASTER上安装配置haproxy和keepalived

    $ ssh haproxy_MASTER
    $ sudo bash -c "echo 'deb http://ftp.debian.org/debian/ wheezy-backports main' >> /etc/apt/sources.list"
    $ sudo apt-get update
    $ sudo apt-get install haproxy keepalived

### 配置haproxy

    $ cat /etc/haproxy/haproxy.cfg
    global
            log 127.0.0.1   local0 notice
            maxconn 2000
            chroot /var/lib/haproxy
            user haproxy
            group haproxy
            daemon

    defaults
            log     global
            mode    http
            option  httplog
            option  dontlognull
            option  redispatch
            contimeout 5000
            clitimeout 50000
            srvtimeout 50000
            retries 3
            errorfile 400 /etc/haproxy/errors/400.http
            errorfile 403 /etc/haproxy/errors/403.http
            errorfile 408 /etc/haproxy/errors/408.http
            errorfile 500 /etc/haproxy/errors/500.http
            errorfile 502 /etc/haproxy/errors/502.http
            errorfile 503 /etc/haproxy/errors/503.http
            errorfile 504 /etc/haproxy/errors/504.http

    listen webserver 0.0.0.0:80
        mode http
        stats enable
        stats uri /haproxy?stats
        stats realm Strictly\ Private
        stats auth admin:admin
        balance roundrobin
        #option httpclose
        option http-server-close
        timeout http-keep-alive 3000
        option forwardfor
        cookie SRVNAME insert
        server app1 172.16.8.131:80 cookie S1 check
        server app2 172.16.8.132:80 cookie S2 check

### 配置keepalived

    $ cat /etc/keepalived/keepalived.conf
    global_defs {
    router_id LVS_MASTER #BACKUP上修改为LVS_BACKUP
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

## haproxy_BACKUP上安装配置haproxy和keepalived

    $ ssh haproxy_BACKUP
    $ sudo bash -c "echo 'deb http://ftp.debian.org/debian/ wheezy-backports main' >> /etc/apt/sources.list"
    $ sudo apt-get update
    $ sudo apt-get install haproxy keepalived

### 配置haproxy

    $ cat /etc/haproxy/haproxy.cfg
    global
            log 127.0.0.1   local0 notice
            maxconn 2000
            chroot /var/lib/haproxy
            user haproxy
            group haproxy
            daemon

    defaults
            log     global
            mode    http
            option  httplog
            option  dontlognull
            option  redispatch
            contimeout 5000
            clitimeout 50000
            srvtimeout 50000
            retries 3
            errorfile 400 /etc/haproxy/errors/400.http
            errorfile 403 /etc/haproxy/errors/403.http
            errorfile 408 /etc/haproxy/errors/408.http
            errorfile 500 /etc/haproxy/errors/500.http
            errorfile 502 /etc/haproxy/errors/502.http
            errorfile 503 /etc/haproxy/errors/503.http
            errorfile 504 /etc/haproxy/errors/504.http

    listen webserver 0.0.0.0:80
        mode http
        stats enable
        stats uri /haproxy?stats
        stats realm Strictly\ Private
        stats auth admin:admin
        balance roundrobin
        #option httpclose
        option http-server-close
        timeout http-keep-alive 3000
        option forwardfor
        cookie SRVNAME insert
        server app1 172.16.8.131:80 cookie S1 check
        server app2 172.16.8.132:80 cookie S2 check

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

# 启动haproxy, keepalived

    $ ssh haproxy_MASTER
    $ sudo service haproxy restart
    $ sudo service keepalived restart
    
    $ ssh haproxy_BACKUP
    $ sudo service haproxy restart
    $ sudo service keepalived restart


# 测试
## 查看服务器状态

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 1
    Web App Server 2
    Web App Server 1
    Web App Server 2
    ...

## 查看haproxy状态
* 用/etc/haproxy/haproxy.cfg中的用户名、密码登录 http://172.16.8.129/haproxy?stats 


## 关闭haproxy_MASTER查看web服务是否正常工作

    $ ssh haproxy_MASTER
    $ sudo shutdown -h now

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 1
    Web App Server 2
    Web App Server 1
    Web App Server 2
    ...

## 关闭WEB_APP_SERVER_1查看web服务是否正常工作

    $ ssh WEB_APP_SERVER_1
    $ sudo shutdown -h now

    $ while true; do curl 172.16.8.252; curl 172.16.8.252; sleep 1; done
    Web App Server 2
    Web App Server 2
    Web App Server 2
    Web App Server 2
    ...
