---
title: "jvm"
author: "ox0spy"
categories: ["java"]
---

## Java options

JAVA_OPTIONS="-server -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -Xms1096m -Xmx1096m"


if [[ "gcprof" == "$1" ]]; then
    JAVA_OPTIONS="$JAVA_OPTIONS -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
    shift
fi

## JVM GC

- [GC专家系列目录索引](https://segmentfault.com/a/1190000004369048)
- [深入理解JVM](http://www.cnblogs.com/enjiex/p/5079338.html)

## 火焰图
- [白话火焰图](http://huoding.com/2016/08/18/531)
- [Java火焰图](http://colobu.com/2016/08/10/Java-Flame-Graphs/)
- [SCALE13x: Linux Profiling at Netflix](http://www.brendangregg.com/blog/2015-02-27/linux-profiling-at-netflix.html)
- [Java in Flames](http://techblog.netflix.com/2015/07/java-in-flames.html)
- [CPU Flame Graphs](http://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html)