---
title: "fuck gfw"
date: 2017-12-15T19:21:58+08:00
tags: ["gfw", " archlinux"]
author: "ox0spy"
categories: ["configuration"]
---

系统是ArchLinux.

## supervisor

supervisor是一个进程启动管理工具，安装:

    $ sudo pacman -S supervisor

配置文件`/etc/supervisord.conf`默认只识别 `*.ini` 配置，修改为 `*.conf`:

    files = /etc/supervisor.d/*.conf

## shadowsocks-libev

安装shadowsocks-libev:

    $ sudo pacman -S shadowsocks-libev
    $ sudo mkdir -p /etc/shadowsocks/
    $ cat /etc/shadowsocks/config.json
	{
        "server":"0.0.0.0",
        "server_port":4698,
        "local_port":1080,
        "password":"your-password",
        "timeout":300,
        "method":"aes-256-cfb"
    }

通过supervisor配置自启动:

    $ cat /etc/supervisor.d/shadowsocks-libev.conf
    [program:shadowsocks-libev]
    command=/usr/bin/ss-server -c /etc/shadowsocks/config.json -d 8.8.8.8 -u
    autorestart=true
    user=nobody

## net-speeder加速

服务器上安装net-speeder:

    $ yaourt -S net-speeder

通过supervisor配置自启动:

    $ cat /etc/supervisor.d/net-speeder.conf
    [program:net-speeder]
    command=/usr/bin/net-speeder ens3 "ip"
    autorestart=true
    user=root

## strongswan

生成CA证书的私钥:

    $ ipsec pki --gen --outform pem > ca.pem

使用私钥，签名CA证书:

    $ ipsec pki --self --in ca.pem --dn "C=com, O=wiseturtles, CN=kx CA" --ca --outform pem >ca.cert.pem

生成服务器证书所需的私钥:

    $ ipsec pki --gen --outform pem > server.pem

用CA证书签发服务器证书:

    $ ipsec pki --pub --in server.pem | ipsec pki --issue --cacert ca.cert.pem \
    --cakey ca.pem --dn "C=com, O=wiseturtles, CN=kx.wiseturtles.com" \
    --san="kx.wiseturtles.com" --flag serverAuth --flag ikeIntermediate \
    --outform pem > server.cert.pem

生成客户端证书所需的私钥:

    $ ipsec pki --gen --outform pem > client.pem

用CA签名客户端证书(C,O的值要与上面第2步CA的值一致,CN的值随意):

    $ ipsec pki --pub --in client.pem | ipsec pki --issue --cacert ca.cert.pem --cakey ca.pem --dn "C=com, O=wiseturtles, CN=kx Client" --outform pem > client.cert.pem

生成pkcs12证书:

    $ openssl pkcs12 -export -inkey client.pem -in client.cert.pem -name "client" -certfile ca.cert.pem -caname "kx CA"  -out client.cert.p12

安装证书:

    $ sudo cp -f ca.cert.pem  /etc/ipsec.d/cacerts/
    $ sudo cp -f server.cert.pem  /etc/ipsec.d/certs/
    $ sudo cp -f server.pem  /etc/ipsec.d/private/
    $ sudo cp -f client.cert.pem  /etc/ipsec.d/certs/
    $ sudo cp -f client.pem  /etc/ipsec.d/private/

### 配置strongswan

修改/etc/ipsec.conf

    $ cat /etc/ipsec.conf
    config setup
        uniqueids=never

    conn iOS_cert
        keyexchange=ikev1
        # strongswan version >= 5.0.2, compatible with iOS 6.0,6.0.1
        fragmentation=yes
        left=%defaultroute
        leftauth=pubkey
        leftsubnet=0.0.0.0/0
        leftcert=server.cert.pem
        right=%any
        rightauth=pubkey
        rightauth2=xauth
        rightsourceip=10.31.2.0/24
        rightcert=client.cert.pem
        auto=add

    conn android_xauth_psk
        keyexchange=ikev1
        left=%defaultroute
        leftauth=psk
        leftsubnet=0.0.0.0/0
        right=%any
        rightauth=psk
        rightauth2=xauth
        rightsourceip=10.31.2.0/24
        auto=add

    conn networkmanager-strongswan
        keyexchange=ikev2
        left=%defaultroute
        leftauth=pubkey
        leftsubnet=0.0.0.0/0
        leftcert=server.cert.pem
        right=%any
        rightauth=pubkey
        rightsourceip=10.31.2.0/24
        rightcert=client.cert.pem
        auto=add

    conn windows7
        keyexchange=ikev2
        ike=aes256-sha1-modp1024!
        rekey=no
        left=%defaultroute
        leftauth=pubkey
        leftsubnet=0.0.0.0/0
        leftcert=server.cert.pem
        right=%any
        rightauth=eap-mschapv2
        rightsourceip=10.31.2.0/24
        rightsendcert=never
        eap_identity=%any
        auto=add

修改/etc/strongswan.conf

    $ cat /etc/strongswan.conf
	charon {
	load_modular = yes
	duplicheck.enable = no
	compress = yes
	plugins {
		include strongswan.d/charon/*.conf
	}
        dns1 = 8.8.8.8
        dns2 = 8.8.4.4
        nbns1 = 8.8.8.8
        nbns2 = 8.8.4.4
    }

    include strongswan.d/*.conf

## 本地DNS配置