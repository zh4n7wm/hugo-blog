---
title: "go学习笔记5之beego框架"
date: 2017-12-15T19:21:59+08:00
tags: ["go", " beego"]
author: "crazygit"
categories: ["go"]
---

### Beego框架准备

    $ go get github.com/astaxie/beego
    $ go get github.com/beego/bee

创建程序`hello-beego.go`

    :::go
    package main

    import (
            "github.com/astaxie/beego"
    )

    type MainController struct {
         beego.Controller
    }

    func (this *MainController) Get() {
        this.Ctx.WriteString("hello world")
    }

    func main() {
        beego.Router("/", &MainController{})
        beego.Run()
    }

执行`go run hello-beego.go`, 访问<http://127.0.0.1:8080>检查，　如果输出"hello world" 表示本地beego环境已经搭建成功