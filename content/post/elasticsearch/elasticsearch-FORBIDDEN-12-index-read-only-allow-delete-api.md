---
title: "elasticsearch FORBIDDEN 12 index read only allow delete api"
date: 2018-07-22T14:06:00+08:00
author: "ox0spy"
categories: ["elasticsearch"]
---

由于我的 Mac OSX 硬盘基本没空间了，导致 ElasticSearch 创建索引报错了。

ElasticSearch 报错:

    FORBIDDEN/12/index read-only / allow delete (api)

默认情况，当硬盘空间使用率超过 `90%` 时，ElasticSearch 就变成 `read only` 不允许再创建索引了。

可以修改一些参数，改变它的默认行为：(可用空间小于 1G 才变成 read only)

    $ cat /usr/local/etc/elasticsearch/elasticsearch.yml
    cluster.routing.allocation.disk.watermark.low: 3gb
    cluster.routing.allocation.disk.watermark.high: 1gb
    cluster.routing.allocation.disk.watermark.flood_stage: 1gb

参考链接：[Disk-based Shard Allocation](https://www.elastic.co/guide/en/elasticsearch/reference/6.2/disk-allocator.html)
