---
title: "hadoop with python"
author: "ox0spy"
date: 2017-12-15T19:22:01+08:00
tags: ["hadoop", " python"]
categories: ["bigdata"]
---

## HDFS

可以通过hdfs命令访问HDFS文件系统：

	$ hdfs dfs -ls /
	$ hdfs dfs -get /var/log/hadoop.log /tmp/  # 将HDFS的/var/log/hadoop.log拷贝到本机/tmp/目录
	$ hdfs dfs -put /tmp/a /user/hadoop/  # 将本机/tmp/a文件拷贝到HDFS的/user/hadoop/目录下
	$ hdfs dfs # 查看完整命令

Python Client:

- [hdfs3](https://github.com/dask/hdfs3)
- [snakebite](https://github.com/spotify/snakebite)
- [Apache Arrow](https://arrow.apache.org/)
- [Native Hadoop file system (HDFS) connectivity in Python](http://wesmckinney.com/blog/python-hdfs-interfaces/)

## MapReduce

MapReduce 是一种编程模型，受函数式编程启发。主要由三部分组成：map、shuffle and sort、reduce。

Hadoop streaming是Hadoop自带的工具，它允许通过任何语言编写MapReduce任务。

### 测试

使用hadoop mapreduce example 测试，确保搭建的环境正常工作：

	$ hdfs dfs -mkdir -p /user/$USER/input
	$ hdfs dfs -put $HADOOP_HOME/libexec/etc/hadoop /user/$USER/input
	$ hadoop jar $HADOOP_HOME/libexec/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.0.jar grep input output 'dfs[a-z.]+'

用Python写mapper、reducer来测试：

**mapper.py**

	#!/usr/bin/env python
	# encoding: utf-8
	import sys
	
	
	for line in sys.stdin:
	  words = line.split()
	  for word in words:
	      print('{}\t{}'.format(word.strip(), 1))


**reducer.py**

	#!/usr/bin/env python
	# encoding: utf-8
	import sys
	
	
	curr_word = None
	curr_count = 0
	
	for line in sys.stdin:
	  word, count = line.split('\t')
	  count = int(count)
	
	  if word == curr_word:
	      curr_count += count
	  else:
	      if curr_word:
	          print('{}\t{}'.format(curr_word, curr_count))
	      curr_word = word
	      curr_count = count
	
	if curr_word == word:
	  print('{}\t{}'.format(curr_word, curr_count))

执行Python写的mapper、reducer：

	$ hadoop jar $HADOOP_HOME/libexec/share/hadoop/tools/lib/hadoop-streaming-2.8.0.jar -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py -input input -output output

Hadoop streaming的命令行参数如下：

- `-files`: A command-separated list of  les to be copied to the MapReduce cluster
- `-mapper`: The command to be run as the mapper
- `-reducer`: The command to be run as the reducer
- `-input`: The DFS input path for the Map step
- `-output`: The DFS output directory for the Reduce step

### mrjob

#### 安装

	$ pip install mrjob

#### 用mrjob写wordcount

代码如下：

	$ cat word_count.py
	#!/usr/bin/env python
	# encoding: utf-8
	from mrjob.job import MRJob
	
	
	class MRWordCount(MRJob):
	
	    def mapper(self, _, line):
	        for word in line.split():
	            yield(word, 1)
	
	    def reducer(self, word, counts):
	        yield(word, sum(counts))
	
	
	if __name__ == '__main__':
	    MRWordCount.run()s
    
本机运行：

	$ python word_count.py data.txt
	
Hadoop上运行：

	$ python word_count.py -r hadoop hdfs:///user/wm/input/data.txt

mrjob runner 可选值：

- `-r inline`: (Default) Run in a single Python process
- `-r local`: Run locally in a few subprocesses simulating some Hadoop features
- `-r hadoop`: Run on a Hadoop cluster
- `-r emr`: Run on Amazon Elastic Map Reduce (EMR)

#### FIXME 如何在EMR上运行

## Pig

### 安装

	$ brew install pig




## Hive

### 安装

	$ brew install hive