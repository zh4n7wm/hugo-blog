---
title: "nginx as database load balancer for mysql"
date: 2017-12-15T19:22:00+08:00
tags: ["ubuntu", " nginx", " mysql"]
author: "ox0spy"
categories: ["mysql"]
---

这个配置能完成几件事情：

- 如题，通过Nginx做MySQL负载均衡
- 从外网的内网中的RDS

## 安装

    $ sudo apt-get install nginx

## 配置

/etc/nginx/nginx.conf

    user www-data;
    worker_processes auto;
    pid /run/nginx.pid;

    events {
        worker_connections 768;
        # multi_accept on;
    }

    stream { include stream.conf; }


/etc/nginx/stream.conf

    upstream mysql_cluster {
        server node1:3306;
        server node2:3306;
        zone tcp_mem 64k;
        least_conn;
    }

    server {
        listen 3306; # MySQL default
        proxy_pass mysql_cluster;
        proxy_timeout 5s;
    }

重启 `Nginx`：

    $ sudo service nginx restart

注：

- 配置安全组 或 防火墙
 + 只让指定 IP 或 网段访问 nginx 主机
 + 允许Nginx主机访问MySQL集群

## 测试

    $ mysql -h localhost -u xxx -p  # 测试是否可以连接MySQL