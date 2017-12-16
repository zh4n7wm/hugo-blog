---
title: "Hugo搭建部署在Github上的blog"
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

### 创建名为 `blog` 的静态博客

    $ hugo new site blog

### 下载 `theme`

从 github 上 fork 主题到自己的 github 中，方便以后自己修改主题。

   $ git submodule add https://github.com/ox0spy/hugo-theme-even themes/even
   $ cp themes/even/exampleSite/config.toml .

注：编辑 `config.toml`

### 写第一篇文章

    $ hugo new hello-world.md
    $ vim content/hello-world.md  # 用vim编辑器写 Markdown 即可

### 查看效果

    $ hugo server --theme=even --buildDrafts --watch

### 生成静态文件

    $ hugo --theme even

更多 `theme`: <http://themes.gohugo.io/>

### 在 `github.com` 上创建名为 `username.github.io` 的 `git` 库

### 将生成的静态文件 `push` 到 `username.github.io`

    $ cd public
    $ git init
    $ git add -A
    $ git commit -m 'initial commit.'
    $ git push origin master

将 `public` 作为 submodule

    $ cd ../
    $ git submodule add git@github.com:ox0spy/ox0spy.github.io.git public

### 创建一个git库

在 `github` 上创建一个新的 `git`库 来保存 `hugo`文件及 `*.md`。

    $ git init
    $ git add .
    $ git commit -m 'initial commit.'
    $ git remote add origin git@github.com:ox0spy/hugo-blog.git
    $ git -u origin master
