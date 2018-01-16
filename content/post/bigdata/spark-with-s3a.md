---
title: "Spark with AWS S3 support"
date: 2018-01-16T15:34:00+08:00
tags: ["mac", "spark", "bigdata", "s3"]
author: "ox0spy"
categories: ["bigdata"]
---

# Spark with S3

从 `Spark` 上读取 `AWS S3` 中的文件。

[Hadoop-AWS module: Integration with Amazon Web Services](https://hadoop.apache.org/docs/r2.8.0/hadoop-aws/tools/hadoop-aws/index.html) 该文档介绍如何在 `Hadoop` 中使用 `AWS S3`。

推荐使用 `s3a://`；`s3n://` 和 `s3://` 不推荐使用；`Hadoop 3` 将只能使用 `s3a://`。

## 配置Spark

### 下载 `jar` 包：(`aws-java-sdk-1.7.4.jar`, `hadoop-aws-2.7.2.jar`)

    $ wget -P $SPARK_HOME/jars/ http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar
    $ wget -P $SPARK_HOME/jars/ http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.2/hadoop-aws-2.7.2.jar

注：较新的 `aws-java-sdk` 或 `hadoop-aws` 无法工作。

### 创建 Spark 配置文件：

    $ cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf

`$SPARK_HOME/conf/spark-defaults.conf` 配置如下：

    $ cat $SPARK_HOME/conf/spark-defaults.conf
    # aws s3a

    # 为了让 Spark 识别 s3a:// ，有三种方法
    # 方法一
    # spark.jars.packages com.amazonaws:aws-java-sdk:1.7.4,org.apache.hadoop:hadoop-aws:2.7.2
    # 方法二
    # spark.jars /usr/local/opt/apache-spark/libexec/jars/aws-java-sdk-1.7.4.jar,/usr/local/opt/apache-spark/libexec/jars/hadoop-aws-2.7.2.jar
    # 方法三
    spark.executor.extraClassPath   /usr/local/opt/apache-spark/libexec/jars/aws-java-sdk-1.7.4.jar:/usr/local/opt/apache-spark/libexec/jars/hadoop-aws-2.7.2.jar
    spark.driver.extraClassPath   /usr/local/opt/apache-spark/libexec/jars/aws-java-sdk-1.7.4.jar:/usr/local/opt/apache-spark/libexec/jars/hadoop-aws-2.7.2.jar

    spark.hadoop.fs.s3a.impl    org.apache.hadoop.fs.s3a.S3AFileSystem
    spark.hadoop.fs.s3a.access.key  <aws_access_key>
    spark.hadoop.fs.s3a.secret.key  <aws_secret_key>
    spark.hadoop.fs.s3a.fast.upload true

    # aws s3n
    # spark.hadoop.fs.s3n.awsAccessKeyId  <aws_access_key>
    # spark.hadoop.fs.s3n.awsSecretAccessKey  <aws_secret_key>

    # 设置代理
    spark.driver.extraJavaOptions   -Dhttp.proxyHost=localhost -Dhttp.proxyPort=6152 -Dhttps.proxyHost=localhost -Dhttps.proxyPort=6152

    spark.shuffle.compress  true
    spark.io.compression.codec  snappy

## 测试

    $ pyspark
    In [1]: sc.textFile(f's3a://{bucket}/{file_path}').take(3)

## 参考文章

- [Hadoop-AWS module: Integration with Amazon Web Services](https://hadoop.apache.org/docs/r2.8.0/hadoop-aws/tools/hadoop-aws/index.html)
- [Spark + S3A filesystem client from HDP to access S3](https://community.hortonworks.com/articles/36339/spark-s3a-filesystem-client-from-hdp-to-access-s3.html)
- [Apache Spark and Amazon S3 — Gotchas and best practices](https://medium.com/@subhojit20_27731/apache-spark-and-amazon-s3-gotchas-and-best-practices-a767242f3d98)
