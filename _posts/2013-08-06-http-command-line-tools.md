---
layout: post
title: "HTTP Command Line Tools"
description: ""
category: HTTP
tags: [HTTP, Linux]
---
{% include JB/setup %}

## Linux Network Tools

### wget

>GNU Wget is a free utility for non-interactive download of files from
the Web.  It supports HTTP, HTTPS, and FTP protocols, as well as
retrieval through HTTP proxies.

#### log to a server using POST and then proceed to download the desired pages, presumably only accessible to authorized users

Log in to the server.  This can be done only once.

{% highlight sh %}
wget --save-cookies cookies.txt \
     --post-data 'user=foo&password=bar' \
     http://server.com/auth.php
{% endhighlight %}

Now grab the page or pages we care about.

{% highlight sh %}
wget --load-cookies cookies.txt \
     -p http://server.com/interesting/article.php
{% endhighlight %}

Note: If the server is using session cookies to track user
authentication, the above will not work because --save-cookies will
not save them (and neither will browsers) and the cookies.txt file
will be empty.  In that case use --keep-session-cookies along with
--save-cookies to force saving of session cookies.

#### download all the files that are necessary to properly display a given HTML page
{% highlight sh %}
wget -E -H -k -K -p http://www.test.com/interestring.html
{% endhighlight %}

#### mirror site

* perso zip - sync_perso_zip.sh
{% highlight sh %}
#!/bin/bash

wget --no-proxy -c -r  -np  -nH --cut-dirs=2 --reject=index* -N \
    http://172.24.220.169/teleweb/perso/MOD_BEETLE_NEW/ \
    -P /home/opengrok/teleweb/perso/
{% endhighlight %}

* DocTree - sync_mtk_video.sh
{% highlight sh %}
#!/bin/bash

wget --user wanming.zhang --password xxxx \
    --no-proxy -c -r -np  -nH --cut-dirs=7 --reject=index* -N \
    http://172.24.61.76/dx/swd/Projects/Android/7-Platform_Documents&Tools/MTK/Document/MTK_Training_Video_20130226/ \
    -P /data/docs
{% endhighlight %}

#### debug wget with -d (and -o)

run wget with "-d" to check how to send HTTP request

{% highlight sh %}
$ wget -d --load-cookies cookies.txt --content-disposition http://bugzilla.tcl-ta.com/show_bug.cgi?id=214397
{% endhighlight %}

output

<pre>
---request begin---
HEAD /show_bug.cgi?id=214397 HTTP/1.0
User-Agent: Wget/1.12 (linux-gnu)
Accept: */*
Host: bugzilla.tcl-ta.com
Connection: Keep-Alive
Cookie: Bugzilla_login=2088; Bugzilla_logincookie=iehkBQOdds

---request end---
</pre>

then, run wget with your your HTTP header.

{% highlight sh %}
$ wget --no-cookies --header "Cookie: Bugzilla_login=2088; Bugzilla_logincookie=iehkBQOdds" \
    http://bugzilla.tcl-ta.com/show_bug.cgi?id=214397
{% endhighlight %}

with -o, save output to a file.

### curl

#### curl auth

{% highlight sh %}
curl --user name:pass http://www.example.com
curl -u name:pass http://example.com/secret-page/
curl http://name:pass@protected.example.com 
{% endhighlight %}

#### curl post data

for post data:
{% highlight sh %}
curl --request POST --data 'key1=val1&key2=val2' http://example.com/resource.cgi
{% endhighlight %}

for file upload:
{% highlight sh %}
curl --request POST --data "fileupload=@filename.txt" http://example.com/upload.cgi
{% endhighlight %}

#### curl and cookies

* log to bugzilla and save cookies

{% highlight sh %}
curl -d 'Bugzilla_login=wmzhang&Bugzilla_password=xxxxxx&Bugzilla_restrictlogin=on&GoAheadAndLogIn=1&GoAheadAndLogIn=Log+in' \
    http://bugzilla.tcl-ta.com/index.cgi -c curl_cookies.txt
{% endhighlight %}

* use this cookies
{% highlight sh %}
curl -b curl_cookies.txt http://bugzilla.tcl-ta.c_bug.cgi?id=407177
{% endhighlight %}
