---
title: "spark"
author: "ox0spy"
date: 2017-12-15T19:22:01+08:00
categories: ["bigdata"]
---

# Spark

## 安装 `Apache-Spark`

$ brew install apache-spark

### 用IPython作为 PySpark 的交互式终端

创建 `Python 3`虚拟环境：`py3`

	$ mkvirtualenv -p python3.6 py3
	$ pip install ipython

修改 `Zsh` 环境变量：

	$ cat ~/.zshrc
	# spark with Python
	export SPARK_HOME="/usr/local/opt/apache-spark/libexec"
	export PYSPARK_DRIVER_PYTHON="$HOME/.virtualenvs/py3/bin/ipython"
	#export PYSPARK_DRIVER_PYTHON_OPTS=""
	export PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$PYTHONPATH"

测试：

	$ pyspark  # 应该能看到熟悉的 IPython 终端
	In [1]: sc
	Out[1]: <SparkContext master=local[*] appName=PySparkShell>

### 经典的单词统计

	$ cat wordcount.py
	from pyspark import SparkConf, SparkContext
	
	
	filename = __file__
	outdir = 'word-count-out'
	conf = SparkConf().setMaster('local').setAppName('Word Count')
	sc = SparkContext(conf=conf)
	lines = sc.textFile(filename)
	words = lines.flatMap(lambda line: line.split())
	result = words.map(lambda word: (word, 1)).reduceByKey(lambda x, y: x + y)
	print(result.collect())
	result.saveAsTextFile(outdir)

一行实现统计所有单词个数：

    sc.textFile('/tmp/p').map(lambda line: len(line.split())).reduce(lambda a, b: a + b)

一行实现统计每个单词出现次数(word count)：

    sc.textFile('/tmp/p').flatMap(lambda line: line.split()).map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b).collect()

## RDD (Resilient Distributed Dataset)