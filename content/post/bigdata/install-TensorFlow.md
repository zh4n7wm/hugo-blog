---
title: "mac osx 上安装 tensorflow [cpu support only]"
author: "ox0spy"
date: 2017-12-15T19:22:01+08:00
tags: ["tensorflow", " mac"]
categories: ["bigdata"]
---

## Mac OSX 上安装 TensorFlow [CPU support only]

本文介绍在 `Mac OSX` 系统上如何安装 Tensorflow ，但除了操作系统包管理有差异，其它内容使用于其它操作系统。

TensorFlow 可以在 Python 2 中运行，但，Python 3 才是未来。所以，建议大家直接使用 Python 3！

注：本文安装的是 `TensorFlow with CPU support only` ，以后再介绍如何安装 `TensorFlow with GPU support`。

### 安装 Python 3

	$ brew install python3

### 安装 virtualenv

安装 virtualenv

	$ sudo pip install -U virtualenv virtualenvwrapper

将下面命令加入 `~/.bashrc` 或 `~/.zshrc`，比如我使用`zsh`，所以加到 `~/.zshrc` 文件末尾:

	$ echo 'test -f /usr/local/bin/virtualenvwrapper.sh && source /usr/local/bin/virtualenvwrapper.sh' >> ~/.zshrc

### 安装 TensorFlow

	$ mkvirtualenv -p python3 tensorflow
	$ pip install -U tensorflow

### 安装 IPython

IPython 是一个体验特别好的 Python 交互式终端，安装：
	
	$ workon tensorflow
	$ pip install ipython

### 测试是否安装成功

	$ ipython
	In [1]: import tensorflow as tf
	In [2]: hello = tf.constant('Hello, TensorFlow!')
	In [3]: sess = tf.Session()
	In [4]: print(sess.run(hello))
	b'Hello, TensorFlow!'

看到成功输出 `b'Hello, TensorFlow!'` 说明已经成功安装 TensorFlow ！

这行之后：

	In [3]: sess = tf.Session()

可能会看到类似下面的输出：

	2017-06-14 13:50:49.512831: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.1 instructions, but these are available on your machine and could speed up CPU computations.
	2017-06-14 13:50:49.512872: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.2 instructions, but these are available on your machine and could speed up CPU computations.
	2017-06-14 13:50:49.512881: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX instructions, but these are available on your machine and could speed up CPU computations.
	2017-06-14 13:50:49.512894: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX2 instructions, but these are available on your machine and could speed up CPU computations.
	2017-06-14 13:50:49.512903: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use FMA instructions, but these are available on your machine and could speed up CPU computations.

上面输出中的 `W` 表示 `警告` (`Warning`)，提示从源码编译并开启一些编译选项后可以加快CPU计算速度。

#### 三种办法避免这类错误

上面的 `Warning` 信息并不影响学习 `TensorFlow` ，只是会导致 `TensorFlow` 运行的不够快。但，如果你还是不希望看到这些 `Warning` ，可以用下面的三种方法之一。

第一种仅仅是让你不再看到 `Warning`，而最后两种能让 `TensorFlow` 运行的更快！

##### 设置 tensorflow log level，避免 warning 输出

>`TF_CPP_MIN_LOG_LEVEL`

>- It defaults to 0, showing all logs
>- To filter out INFO set to 1
>- WARNINGS, additionally 2
>- and to additionally filter out ERROR logs set to 3

	$ ipython
	In [1]: import os
	In [2]: os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
	In [3]: import tensorflow as tf
	In [4]: hello = tf.constant('Hello, TensorFlow!')
	In [5]: sess = tf.Session()
	In [6]: print(sess.run(hello))
	b'Hello, TensorFlow!'

##### 安装别人编译好的 TensorFlow

移步[lakshayg/tensorflow-build](https://github.com/lakshayg/tensorflow-build)

更多，请参考：<https://github.com/yaroslavvb/tensorflow-community-wheels>

##### 自己编译 TensorFlow

请参考官方文档：[Installing TensorFlow from Sources](https://www.tensorflow.org/install/install_sources)