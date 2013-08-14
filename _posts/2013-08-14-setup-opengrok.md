---
layout: post
title: "Setup OpenGrok"
description: ""
category: OpenGrok
tags: [Linux, Android, OpenGrok]
---
{% include JB/setup %}

#  OpenGrok安装使用指南

Author: Liang Lin

参考： <https://github.com/OpenGrok/OpenGrok/wiki/How-to-install-OpenGrok>

注意：最好是单独建立一个opengrok用户，并保证该用户对代码和后面创建索引的目录读写权限

下面整个流程以如下目录结构为例:
{% highlight sh %}
/data/opengrok-0.11.1       # opengrok 应用程序包
/data/apache-tomcat-7.0.6   # apache-tomecat路径
/data/opengrok_data         # opengrok数据,配置文件,log存放路径
/data/opengrok_projects     # 需要创建索引的项目代码路径
{% endhighlight %}

##  准备工作

1. 以opengrok用户身份登录  

2. 安装jdk和Exuberant Ctags
    {% highlight sh %}
    $ sudo apt-get install sun-java6-jdk ctags
    {% endhighlight %}

3. 下载opengrok安装包（opengrok-0.11.1.tar.gz）和tomcat安装包(apachetomcat-7.0.6.tar.gz)解压安装包到/data目录下面
    {% highlight sh %}
    $ cd /data
    $ tar -zxvf /path/to/opengrok-0.11.1.tar.gz
    $ tar -zxvf /path/to/apachetomcat-7.0.6.tar.gz
    {% endhighlight %}

4. 启动tomcat，确认tomcat没有问题
    {% highlight sh %}
    $ /data/apache-tomcat-7.0.6/bin/startup.sh
    {% endhighlight %}

    访问<http://127.0.0.1:8080>检查tomcat是否正常工作

5. 下载需要创建索引的项目
    {% highlight sh %}
    $ mkdir -p /data/opengrok\_projects/project1
    $ mkdir -p /data/opengrok\_projects/project2
    $ cd /data/opengrok\_projects/project1
    $ # download code of project1 (such as: git clone ... or repo init ... && repo sync)
    $ cd /data/opengrok\_projects/project2
    $ # download code of project2 (such as: git clone ... or repo init ... && repo sync)
    {% endhighlight %}

    目录结构如下:
    {% highlight sh %}
    /data/opengrok\_projects/----project1
                    |----project2
                    |----project3
                    |----.......
    {% endhighlight %}


##  部署OpenGrok

执行命令
{% highlight sh %}
$ OPENGROK_TOMCAT_BASE=/data/apache-tomcat-7.0.6 /data/opengrok-0.11.1/bin/OpenGrok deploy
{% endhighlight %}

这一步实际操作是/data/opengrok-0.11.1/lib/source.war部署到/data/apache-tomcat-7.0.6/webapps/.

访问<http://127.0.0.1:8080/source>, 已经可以看到opengrok页面了，但是没有项目的数据信息.

在/data/apache-tomcat-7.0.6/webapps/目录下面可以看到一个source目录和source.war，就是刚刚部属的产物。source.war已经没有什么用了，可以删除。


###  创建索引

创建索引时，会创建三个目录，一个data目录来存放索引信息，一个etc目录创建配置信息和一个log目录。
{% highlight sh %}
$ OPENGROK_VERBOSE=true OPENGROK_INSTANCE_BASE=/data/opengrok_data /data/opengrok-0.11.1/bin/OpenGrok index /data/opengrok_projects
{% endhighlight %}

__PS__:默认情况下，调用OpenGork脚本是会生成项目的历史记录的Cache，并且每次调用都会这样做一次，比较浪费时间.

如果不想生成脚本的历史记录Cache, 可以修改/data/opengrok-0.11.1/bin/OpenGrok脚本的`UpdateGeneratedData` 方法，去掉`StdInvocation -H`的`-H`.

因此在执行创建索引文件之前,建议去掉`-H`, 不会影响到OpenGrok的正常使用.

创建索引的时间视/data/opengrok\_projects的代码数量决定.

最后会在/data/opengrok\_data/目录下面生成data,etc,log 三个目录
{% highlight sh %}
    /data/opengrok_data 
            ├── data   # 索引数据
            │   ├── historycache
            │   ├── index
            │   ├── spellIndex
            │   ├── timestamp
            │   └── xref
            ├── etc   # 配置文件
            │   └── configuration.xml
            ├── log   # log文件
            │   ├── opengrok0.0.log
            │   ├── opengrok1.0.log
            │   └── opengrok2.0.log
            └── logging.properties
{% endhighlight %}

修改/data/apache-tomcat-7.0.6/webapps/source/WEB-INF/web.xml
{% highlight xml %}
  &lt;context-param&gt;
    &lt;param-name&gt;CONFIGURATION&lt;/param-name&gt;
    &lt;param-value&gt;/var/opengrok/etc/configuration.xml&lt;/param-value&gt;
    &lt;description&gt;Full path to the configuration file where OpenGrok can read it's configuration&lt;/description&gt;
  &lt;/context-param&gt;
{% endhighlight %}

将上面的param-value修改为`/data/opengrok\_data/etc/configuration.xml`

修改web.xml文件这步操作只需要在首次搭建opengrok环境的时候修改一次即可, 以后只有在配
置文件/data/opengrok\_data/etc/configuration.xml的路径发生改变时,再修改就可以了.

访问<http://127.0.0.1:8080/source>, Enjoy it!


###  项目代码更新或者添加新的项目

首先更新项目代码或者下载新的项目到~/opengrok/projects目录下面。

然后重新执行如下命令即可
{% highlight sh %}
$ OPENGROK_VERBOSE=true OPENGROK_INSTANCE_BASE=/data/opengrok_data/ /data/opengrok-0.11.1/bin/OpenGrok index /data/opengrok_projects/
{% endhighlight %}



###  可选操作

可以通过修改/data/apache-tomcat-7.0.6/webapps/source/index\_body.html 来定制化你的OpenGrok首页.
如添加公司LOGO或一些有用的帮助信息。

###  直接调用命令行接口
上面创建索引的命令
{% highlight sh %}
$ OPENGROK_VERBOSE=true OPENGROK_INSTANCE_BASE=/data/opengrok_data /data/opengrok-0.11.1/bin/OpenGrok index /data/opengrok_projects/
{% endhighlight %}

其实调用的是opengrok lib目录下的jar包：
{% highlight sh %}
java -Xmx2048m -Dorg.opensolaris.opengrok.history.cvs=/usr/bin/cvs
-Dorg.opensolaris.opengrok.history.git=/usr/bin/git
-Djava.util.logging.config.file=/data/opengrok_data/logging.properties
-jar /data/opengrok-0.11.1/bin/../lib/opengrok.jar
-P -S -r on -v -c /usr/bin/ctags-exuberant -a on
-W /data/opengrok_data/etc/configuration.xml
-U localhost:2424 -s /data/opengrok_projects/
-d /data/opengrok_data/data -H..
{% endhighlight %}

上面各个参数的意思如下:
{% highlight sh %}
$ java -jar opengrok.jar

Usage: opengrok.jar [options]
-?
    Help

-A ext:analyzer
    Files with the named extension should be analyzed with the specified class

-a on/off
    Allow or disallow leading wildcards in a search

-B url
    Base URL of the user Information provider. Default: "http://www.opensolaris.org/viewProfile.jspa?username="

-C
    Print per project percentage progress information(I/O extensive, since one read through dir structure is made before indexing, needs -v, otherwise it just goes to the log)

-c /path/to/ctags
    Path to Exuberant Ctags from http://ctags.sf.net by default takes the Exuberant Ctags in PATH.

-D
    Store history cache in a database (needs the JDBC driver in the classpath, typically derbyclient.jar or derby.jar)

-d /path/to/data/root
    The directory where OpenGrok stores the generated data

-e
    Economical - consumes less disk space. It does not generate hyper text cross reference files offline, but will do so on demand - which could be sightly slow.

-H
    Generate history cache for all repositories

-h /path/to/repository
    just generate history cache for the specified repos (absolute path from source root)

-I pattern
    Only files matching this pattern will be examined (supports wildcards, example: -I *.java -I *.c)

-i pattern
    Ignore the named files or directories (supports wildcards, example: -i *.so -i *.dll)

-j class
    Name of the JDBC driver class used by the history cache. Can use one of the shorthands "client" (org.apache.derby.jdbc.ClientDriver) or "embedded" (org.apache.derby.jdbc.EmbeddedDriver). Default: "client"

-k /path/to/repository
    Kill the history cache for the given repository and exit. Use '*' to delete the cache for all repositories.

-K
    List all repository pathes and exit.

-L path
    Path to the subdirectory in the web-application containing the requested stylesheet. The following factory-defaults exist: "default", "offwhite" and "polished"

-l on/off
    Turn on/off locking of the Lucene database during index generation

-m number
    The maximum words to index in a file

-N /path/to/symlink
    Allow this symlink to be followed. Option may be repeated.

-n
    Do not generate indexes, but process all other command line options

-O on/off
    Turn on/off the optimization of the index database as part of the indexing step

-P Generate a project for each of the top-level directories in source root 
-p /path/to/default/project
    This is the path to the project that should be selected by default in the web application(when no other project set either in cookie or in parameter). You should strip off the source root.

-Q on/off
    Turn on/off quick context scan. By default only the first 32k of a file is scanned, and a '[..all..]' link is inserted if the file is bigger. Activating this may slow the server down (Note: this is setting only affects the web application)

-q
    Run as quietly as possible

-R /path/to/configuration
    Read configuration from the specified file

-r on/off
    Turn on/off support for remote SCM systems

-S
    Search for "external" source repositories and add them

-s /path/to/source/root
    The root directory of the source tree

-T number
    The number of threads to use for index generation. By default the number of threads will be set to the number of available CPUs

-t number
    Default tabsize to use (number of spaces per tab character)

-U host:port
    Send the current configuration to the specified address (This is most likely the web-app configured with ConfigAddress)

-u url
    URL to the database that contains the history cache. Default: If -j specifies "embedded", "jdbc:derby:$DATA_ROOT/cachedb;create=true"; otherwise, "jdbc:derby://localhost/cachedb;create=true"

-V
    Print version and quit

-v
    Print progress information as we go along

-W /path/to/configuration
    Write the current configuration to the specified file (so that the web application can use the same configuration

-w webapp-context
    Context of webapp. Default is /source. If you specify a different name, make sure to rename source.war to that name.

-X url:suffix
    URL Suffix for the user Information provider. Default: ""

-z number
    depth of scanning for repositories in directory structure relative to source root

{% endhighlight %}
