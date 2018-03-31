---
title: "DNSCrypt + dnsmasq"
author: "ox0spy"
date: 2018-03-31T21:49:01+08:00
categories: ["dns"]
---

本文介绍如何使用 `dnscrypt-proxy + dnsmasq` 避免 DNS 污染， `dnscrypt-proxy` 是 `dnscrypt` 的一种实现，它能让古老的 DNS 协议更安全，然后 `dnsmasq` 从 `dnscrypt-proxy` 上获取正确的 DNS 解析，并做本地缓存加快速度。

## DNSCrypt

`DNSCrypt` 是协议，它使 `DNS client` 和 `DNS resolver` 之间的通讯是经过认证的，避免 DNS 污染。

`dnscrypt-proxy` 是 `DNSCrypt` 的一种实现。

更多信息：[https://dnscrypt.info/](https://dnscrypt.info/)

### 安装 dnscrypt-proxy

    $ brew install dnscrypt-proxy

### 修改配置文件

让 `dnscrypt-proxy` 监听到 `127.0.0.1:40` 及 IPv6 的 `[::1]:40`

    $ grep -Pv '^\s*#|^$' /usr/local/etc/dnscrypt-proxy.toml
    listen_addresses = ['127.0.0.1:40', '[::1]:40']
    max_clients = 250
    ipv4_servers = true
    ipv6_servers = false
    dnscrypt_servers = true
    doh_servers = true
    require_dnssec = false
    require_nolog = true
    require_nofilter = true
    force_tcp = false
    timeout = 2500
    cert_refresh_delay = 240
    fallback_resolver = '9.9.9.9:53'
    ignore_system_dns = false
    log_files_max_size = 10
    log_files_max_age = 7
    log_files_max_backups = 1
    block_ipv6 = false
    cache = true
    cache_size = 256
    cache_min_ttl = 600
    cache_max_ttl = 86400
    cache_neg_ttl = 60
    [query_log]
    format = 'tsv'
    [nx_log]
    format = 'tsv'
    [blacklist]
    [ip_blacklist]
    [schedules]
    [sources]
    [sources.'public-resolvers']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
    cache_file = 'public-resolvers.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''
    [static]

### 启动服务

    $ sudo brew services restart dnscrypt-proxy

### 测试

    $ dnscrypt-proxy -resolve twitter.com
    Resolving [twitter.com]

    Domain exists:  yes, 9 name servers found
    Canonical name: twitter.com.
    IP addresses:   104.244.42.1, 104.244.42.129
    TXT records:    google-site-verification=h6dJIv0HXjLOkGAotLAWEzvoi9SxqP4vjpx98vrCvvQ v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:54.156.255.69 include:_spf.google.com include:_thirdparty.twitter.com -all
    Resolver IP:    45.76.91.215 (45.76.91.215.vultr.com.)

## dnsmasq

### 安装 dnsmasq

    $ brew install dnsmasq

### 修改配置文件

`server=127.0.0.1#40` 该行让 dnsmasq 请求 `dnscrypt-proxy` 来获取 DNS 解析。

`conf-dir=/usr/local/etc/dnsmasq.d` 目录中的文件是 [felixonmars/dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) 中的 `*.conf` 文件，这样会使国内域名通过国内DNS解析，加快解析速度。

`addn-hosts=/usr/local/etc/dnsmasq.hosts` 类似 `/etc/hosts` ，暂时并没有创建该文件。

    $ grep -Pv '^\s*#|^$' /usr/local/etc/dnsmasq.conf
    no-resolv
    no-poll
    conf-dir=/usr/local/etc/dnsmasq.d
    addn-hosts=/usr/local/etc/dnsmasq.hosts
    proxy-dnssec
    address=/.dev/127.0.0.1
    address=/.dom/127.0.0.1
    server=127.0.0.1#40
    keep-in-foreground
    no-dhcp-interface=lo
    listen-address=127.0.0.1
    bind-interfaces
    bogus-priv
    no-resolv
    stop-dns-rebind
    rebind-localhost-ok
    cache-size=2000
    proxy-dnssec
    log-queries

### 启动服务

    $ sudo brew services restart dnsmasq

### 修改 /etc/resolv.conf

    $ cat /etc/resolv.conf
    nameserver 127.0.0.1

查看系统使用的 DNS

    $ scutil --dns

### 测试

    $ dig twitter.com

可以看看 `Query time` 第二次的查询时间为 0，也就是 dnsmasq 做了本地缓存。
