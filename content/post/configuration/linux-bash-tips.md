---
title: "Linux Bash Tips"
author: "ox0spy"
date: 2013-08-14T00:00:00+08:00
tags: ["Linux", "Bash", "Programming"]
---

## Command line option parse

    while (( $# > 0 )) ; do
        case $1 in
            --local_branch)
                git_local_branch=$2
                shift
                ;;
            --remote_branch)
                git_remote_branch=$2
                shift
                ;;
            --remote_repo)
                git_remote_repo=$2
                shift
                ;;
            --tag)
                git_tag=$2
                shift
                ;;
            -f|--force)
                git_force="-f"
                ;;
            --keyfile)
                export git_publish_keyfile=$2
                shift
                ;;
        esac
        shift
    done

## Pointer variable
The example shows how to make a bash environment variable reference the value of another:

    $ foo=bar
    $ name=foo
    $ echo ${!name}
    bar

The example shows how to get a list of all variables beginning with "H" (Note: the wildcard can only go at the end)

    $ echo ${!H*}
    foo fs_abc_opts fs_name

## Send email

    $ cat a
    From: "Liang Lin" <linliang@tcl.com>
    To: "Wanming Zhang" <wanming.zhang@tcl.com>
    CC:
    Subject: Test
    Dears,

    hello world!

    $ cat a | sendmail -t -f root@localhost

## Newline

* check if exist '\r' in inputfile

    $ od -c inputfile | grep -E '\\r'

* remove '\r'

    $ tr -d '\r' < inputfile > outputfile

or

    $ sed -i 's#\r##g' inputfile

* converting all CR newlines to LF

    $ tr '\r' '\n' < inputfile > outputfile

or

    $ sed -i 's#\r#\n#g' inputfile

* converting DOS format file to UNIX format

    $ fromdos inputfile

Reference: <https://en.wikipedia.org/wiki/Newline>

## Bash command line editor
### Set vi mode in Bash

Vi mode allows for the use of vi like commands when at the bash prompt. When set to this mode initially you will be in insert mode (be able to type at the prompt unlike when you enter vi). Hitting the escape key takes you into command mode.

    $ set -o vi

#### find history commands

    $ ESC , /keyword

    e.g.:
    $ /ls , then press enter
    $ ls mtk6582* | xargs

### Set emacs mode in Bash

This is usually the default editing mode when in the bash environment and means that you are able to use commands like those in Emacs (defined in the Readline library) to move the cursor, cut and paste text, or undo editing.

    $ set -o emacs

## Bash with MySQL

Simple bash example to store the output of a MySQL query in an array:

    dbquery=$(mysql -u username -p password -e "use table; select field from table;")
    array=( $( for i in $dbquery ; do echo $i ; done ) )

    # you can check the contents of your new array with:
    echo ${array[@]}

    # Now that you have a nice array, you can do things like this:
    for i in ${array[@]};do
        echo $i
    done

    # or, more sophisticated:
    cnt=${#array[@]}
    for (( i=0 ; i&lt;cnt ; i++ ))
    do
        echo "Record No. $i: ${array[$i]}"
    done

simple, but effective !
