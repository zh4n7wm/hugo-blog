---
title: "Setup cgit"
author: "ox0spy"
date: 2013-08-14T00:00:00+08:00
categories: ["Git"]
tags: ["Linux", "Git"]
---

# cgit

## setup cgit

### install

    $ git://hjemli.net/pub/git/cgit
    $ cd cgit
    $ git submodule init     # register the git submodule in .git/config
    $ $EDITOR .git/config    # if you want to specify a different url for git
    $ git submodule update   # clone/fetch and checkout correct git version

    $ make
    $ sudo make install

### setup cgitrc

    $ cat  /etc/cgitrc
    #
    # cgit config
    #

    css=/cgit/cgit.css
    logo=/cgit/cgit.png

    # if you don't want that webcrawler (like google) index your site
    robots=noindex, nofollow

    #
    # List of repositories.
    # This list could be kept in a different file (e.g. '/etc/cgitrepos')
    # and included like this:
    #   include=/etc/cgitrepos
    #

    source-filter=/usr/lib/cgit/filters/syntax-highlighting.sh

    #root-title=Chengdu Integration CGIT
    #root-desc=Chengdu cgit
    root-readme=
    cache-root=/data/git/cgit_cache
    cache-size=1024000


    scan-path=/data/git/repositories
    section-from-path=1

    enable-commit-graph=1

    max-repo-count=99999999
    max-commit-count=10240
    max-message-length=0
    max-atom-items=0
    max-stats=quarter
    #snapshots=tar.bz2

### setup apache2

    $ cat /etc/apache2/conf.d/cgit
    Alias /cgit /usr/share/cgit

    <Directory /usr/share/cgit>
    AllowOverride None
    Options +ExecCGI
    Order allow,deny
    Allow from all
    AddHandler cgi-script .cgi
    </Directory>

### reload apache2 configuration file

    $ sudo services apache2 reload

### test
* <http://your-server-ip/cgit>
