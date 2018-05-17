---
title: "Spark logs location on AWS EMR"
date: 2018-05-17T09:22:01+08:00
tags: ["aws", " emr", "bigdata", "spark"]
author: "ox0spy"
categories: ["bigdata"]
---

在 EMR 上运行 Spark 程序的流程：[添加 Spark 步骤](https://docs.aws.amazon.com/zh_cn/emr/latest/ReleaseGuide/emr-spark-submit-step.html)

当 Spark 报错时，AWS EMR 页面 -> Steps 中的 `View logs` 中并没有程序运行的错误日志，没有错误日志很难知道Spark 程序为什么运行失败了。

查看Spark logs:

- 登陆emr slave/node: `/mnt/var/log/hadoop-yarn/containers/<application_ID>/<container_ID>/{stdout, stderr}`
- Resource Manager 的 web 接口：[查看 Amazon EMR 集群上托管的 Web 界面](https://docs.aws.amazon.com/zh_cn/emr/latest/ManagementGuide/emr-web-interfaces.html)

知道了如何查看错误日志，解决运行Spark程序 或者 环境的问题就很简单了。
