---
title: "Setup Hugo Github Pages"
author: "ox0spy"
date: 2017-12-15T21:08:54+08:00
tags: ["blog", "hugo"]
---

hugo + github pages 搭建 blog。

## 安装 hugo

Mac brew 安装:

    $ brew install hugo

go 命令行安装:

    $ go get -u github.com/gohugoio/hugo

## 创建一个静态blog

1. 创建名为 `blog` 的静态博客

    $ hugo new site blog

2. 下载 `theme`

   $ git submodule add https://github.com/olOwOlo/hugo-theme-even themes/even
   $ cp themes/even/exampleSite/config.toml .

注：编辑 `config.toml`

3. 写第一篇文章

    $ hugo new hello-world.md
    $ vim content/hello-world.md  # 用vim编辑器写 Markdown 即可

4. 查看效果

    $ hugo server --theme=even --buildDrafts --watch

5. 生成静态文件

    $ hugo --theme even

6. 在 `github.com` 上创建名为 `username.github.io` 的 `git` 库

7. 将生成的静态文件 `push` 到 `username.github.io`

    $ cd public
    $ git init
    $ git add -A
    $ git commit -m 'initial commit.'
    $ git push origin master

将 `public` 作为 submodule

    $ cd ../
    $ git submodule add git@github.com:ox0spy/ox0spy.github.io.git public

