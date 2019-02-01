---
title: "背景图全屏显示"
date: 2019-02-01T16:21:59+08:00
tags: ["css"]
author: "ox0spy"
categories: ["frontend"]
---

为页面设置一个背景图片，要求背景图片全屏显示。

### 解决方法

在 body 中添加一个空 div，比如：

    <html>
    <body>
        <div id='bg'></div>。
        <div>其它功能代码</div>
    </body>
    </html>

然后，为该 div 设置 css：

    #bg {
        background: url(/static/img/bg.jpg) no-repeat;
        background-size: 100%;
        width: 100%;
        height: 100%;
        position: fixed;
        top: 0;
        left: 0;
        z-index: -1;
    }

### 更多方法

请参考 [完美的背景图全屏css代码 – background-size:cover?](http://huilang.me/perfect-full-page-background-image/)
