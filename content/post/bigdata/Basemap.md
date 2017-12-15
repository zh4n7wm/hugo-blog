---
title: "安装basemap"
author: "ox0spy"
categories: ["bigdata"]
---

# Basemap

## 安装Basemap

安装 basemap 的依赖库：

	$ pip install numpy pandas matplotlib
	# 注：basemap release包中带有 GEOS，所以，直接使用 release 包中的

目前 basemap 不支持 pip 安装。所以，从 [basemap release](https://github.com/matplotlib/basemap/releases) 下载最新版本的basemap。

安装：

	$ wget https://github.com/matplotlib/basemap/archive/v1.1.0.tar.gz
	$ tar zxf v1.1.0.tar.gz
	$ cd basemap-1.1.0/
	
	$ cd geos-3.3.3  # 安装 GEOS
	$ sudo mkdir /opt/geos && sudo chown -R $USER /opt/geos
	$ export GEOS_DIR=/opt/geos
	$ ./configure --prefix=$GEOS_DIR
	$ make && make install
	
	$ python setup.py install  # 安装 basemap

验证是否按照成功:

	$ python -c 'from mpl_toolkits.basemap import Basemap'  # 不报错就说明安装成功了