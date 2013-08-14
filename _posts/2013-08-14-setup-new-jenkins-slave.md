---
layout: post
title: "Setup new Jenkins slave"
description: ""
category: CI
tags: [Linux, CI, Jenkins]
---
{% include JB/setup %}

# Setup new Jenkins slave

### Install Ubuntu 10.04

### Create jenkins/jenkins (user/group)
{% highlight sh %}
   # login new Jenkins slave
   $ sudo addgroup jenkins
   $ sudo useradd -m -s /bin/bash -g jenkins jenkins
   $ sudo su - jenkins
   $ scp -r jenkins@172.26.32.85:~/.ssh ~/
   $ passwd jenkins
   
   # change hostname
   $ sudo vim /etc/hostname
   
   # login Jenkins master
   $ ssh jenkins@master
   $ ssh-copy-id jenkins@new-slave-host
   
   # login new Jenkins slave
   $ sudo scp jenkins@master:/etc/apt/sources.list /etc/apt/sources.list
   $ sudo apt-get update
   $ sudo apt-get upgrade

   $ sudo apt-get install git-core
{% endhighlight %}

### Setup nis/autofs
{% highlight sh %}
   $ sudo tail -n 1 /etc/passwd /etc/group /etc/shadow
    ==> /etc/passwd <==
    +::::::

    ==> /etc/group <==
    +:::

    ==> /etc/shadow <==
    +::::::::

   $ sudo apt-get install nis portmap autofs
   $ sudo bash -c 'echo "ypserver int.cd.tct" >> /etc/yp.conf'
   $ echo '172.26.35.66 int.cd.tct' >> /etc/hosts
   $ sudo dpkg-reconfigure nis  # write "int.cd.tct"
    
   # autofs
   $ cat /etc/auto.master
   /home/nis /etc/auto.home
    
   $ cat /etc/auto.home
   *   -fstype=nfs 172.26.35.66:/home/nis/&

   # restart service 
   $ sudo service ypbind restart
   $ sudo service portmap restart
   $ sudo service autofs restart
{% endhighlight %}

### Install Java JDK/JRE 1.6
{% highlight sh %}
   $ cd /tmp && wget http://172.26.32.9/software/sun-java/install-sun-java6-jdk-jre.sh
   $ sudo bash install-sun-java6-jdk-jre.sh
{% endhighlight %}

### Install nagios client
{% highlight sh %}
   $ sudo apt-get install nagios-nrpe-server nagios-plugins-basic

   # change config files
   /etc/nagios/nrpe.cfg
   allowed_hosts=127.0.0.1,172.26.35.85
   dont_blame_nrpe=1
   include=/etc/nagios/nrpe_local.cfg

   $ cat /etc/nagios/nrpe_local.cfg
   command[check_root_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
   command[check_data_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /data

   # change nagios server
   /etc/nagios3/conf.d/hosts.cfg
   /etc/nagios3/conf.d/hostsservices.cfg
{% endhighlight %}

### setup ntpdate
{% highlight sh %}
$ sudo apt-get install ntpdate
$ cat /etc/cron.hourly/ntpdate
#!/bin/bash

ntpdate 172.26.32.18
$ sudo chmod +x /etc/cron.hourly/ntpdate
{% endhighlight %}

### join this machine to our Jenkins
* <http://172.26.35.81:8080/computer/new>
