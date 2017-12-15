---
title: "install docker on mac osx"
date: 2017-12-15T19:22:00+08:00
tags: ["docker", " brew", " mac"]
author: "ox0spy"
categories: ["mac-osx"]
---

从docker官网下载dmg包安装每次更新非常麻烦，幸运的是可以在Mac上通过brew安装Docker。
Docker不能直接在Mac上运行，所以会自动安装VirtualBox。


## 安装命令

    $ brew cask install dockertoolbox

## 参考链接
- [官网通过dmg包安装的文档](https://docs.docker.com/mac/step_one/)