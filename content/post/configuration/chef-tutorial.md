---
title: "chef tutorial"
date: 2017-12-15T19:21:58+08:00
tags: ["mac", " chef"]
author: "ox0spy"
categories: ["configuration"]
---

Chef入门.


## Chef组件

- workstation (个人工作电脑, 用来编写cookbook)
- chef server (存放cookbooks的中央仓库)
- node (被chef server管理的node节点)

## 环境准备

### workstation

安装 [Chef Development Kit](https://downloads.chef.io/chef-dk/)。Mac可以直接通过brew install Caskroom/cask/chefdk；Linux、Windows系统最好从前面链接页面中下载最新版本。