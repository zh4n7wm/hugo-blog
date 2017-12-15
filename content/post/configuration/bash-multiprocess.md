---
title: "Bash Multiprocess"
author: "ox0spy"
date: 2013-08-06T00:00:00+08:00
categories: ["Linux"]
tags: ["Linux", "Bash", "Git"]
---

## Git同步

成都和上海分别建有git server, 虽有 Gerrit Replication, 但新创建分支、git库无法自动同步, 直到该git库有新Gerrit merge.

所以, 写脚本通过 gitweb_url?a=project_index 获取所有git库, 然后, 已经下载的就做 git remote update, 否则通过 git clone --mirror克隆裸库到本地.

当项目增加，需要同步的git库太多后，速度就是大问题了.

下面Bash脚本用6个进程同步 (进程数可以自己调整)

    #!/bin/bash
    ################################################################
    # Multiprocess Sync ShangHai modules, if no permission, skip it.
    ################################################################

    PROGRAM="$0"
    GIT=/tools/bin/git
    SH_MOD="alps jrd mtk6572 mtk6575 mtk6582 mtk6589"
    GIT_LIST="/tmp/$$.list"
    PID_FILE="/tmp/sync_git.pid"
    FIFO_FILE="/tmp/$$.fifo"
    THREAD=6

    if [ -f $PID_FILE ]; then
        echo "$0 already running ..."
        exit
    else
        echo "$$" > $PID_FILE
    fi

    function clean_up()
    {
        rm -f $FIFO_FILE $GIT_LIST $PID_FILE
    }

    function send_email()
    {
        test -z "$(which sendmail)" && \
            echo "can not find sendmail command" && return

        local parent_lineno="$1"
        local message="$2"
        local code="${3:-1}"
        local err_msg=""
        if [[ -n "$message" ]] ; then
            err_msg="Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
        else
            err_msg="Error on or near line ${parent_lineno}; exiting with status ${code}"
        fi

        local mail_content=$(mktemp -u)


    cat << EOF > $mail_content
    From: "Wanming Zhang" <Wanming.Zhang@tcl.com>
    To: "Wanming Zhang" <Wanming.Zhang@tcl.com>
    CC: "Liang Lin" <LinLiang@tcl.com>
    Subject:Sync Source Code From Other Site Failed
    Dears,

    $err_msg

    Please check script $PROGRAM and log file.

    This script run by git user's crontab.
    EOF

        cat $mail_content | sendmail -t -f root@localhost
        rm -f $mail_content
    }

    trap 'send_email ${LINENO}' ERR

    function update_git()
    {
        test $# -ne 2 && return

        platform=$1
        git_repo=$2

        PRE_URL="git@172.24.61.94:$platform"
        MOD_DIR="/data/git/repositories/$platform"
        x_dir="$MOD_DIR/$git_repo"
        if [ -d $x_dir ];then
            echo "`date +'%Y-%m-%d %H:%M'` Update $x_dir"
            cd $x_dir && pwd && $GIT remote update && git gc
        else
            echo "`date +'%Y-%m-%d %H:%M'` New add repo $x_dir "
            rm -f $x_dir && $GIT clone --mirror $PRE_URL/$git_repo $x_dir
        fi
    }

    # always remove temporary files
    trap clean_up EXIT

    rm -f $GIT_LIST
    for mod in $SH_MOD
    do
        MOD_URL="http://gitweb.tcl-ta.com/gitweb-$mod/?a=project_index"

        if echo $mod | grep -qE "^(alps|mtk6575)$"; then
            MOD_URL="http://gitweb.tcl-ta.com:8080/gitweb-$mod/?a=project_index"
        fi

        curl $MOD_URL 2>/dev/null | grep -P '^\S+\.git\s+$' | sed "s#^#"$mod":#" >> $GIT_LIST || \
            echo "WARNING: curl $MOD_URL failed."
    done

    mkfifo $FIFO_FILE
    exec 6<>$FIFO_FILE
    rm -f $FIFO_FILE

    for ((i=0; i<$THREAD; i++)); do
        echo
    done >&6

    for x in $(cat $GIT_LIST); do
        read -u6

        {
            platform=$(echo $x | cut -d':' -f1)
            git_repo=$(echo $x | cut -d':' -f2)

            update_git $platform $git_repo || \
                echo "update_git $platform $git_repo failed."

            echo >&6
        } &
    done

    rm -f $GIT_LIST

    wait

    exec 6>&-  # close df6

    rm -f $PID_FILE

    exit 0
