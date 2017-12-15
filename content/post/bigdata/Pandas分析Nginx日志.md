---
title: "pandas分析nginx日志"
author: "ox0spy"
date: 2017-12-15T19:22:01+08:00
tags: ["pandas", " nginx"]
categories: ["bigdata"]
---

# Pandas分析Nginx日志

## 安装所需Python库

	$ pip install numpy pandas matplotlib

注：所有工作都在Python 3中实践 （Python 2应该也没有问题）	
## Nginx日志格式

```
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```

注：Nginx 日志格式可以自己设置，根据日志格式修改下面的匹配正则表达式

## 分析日志

### 加载日志

```
#!/usr/bin/env python
# encoding: utf-8
from datetime import datetime
import pytz
import pandas as pd


def parse_str(s):
    """
    Return the string.

    Example:
    `>>> parse_str('[some string]')`
    `'some string'`
    """
    return s[1:-1]


def parse_datetime(date):
    """
    Return datetime.

    Parse datetime with timezone format as:
        `[day/month/year:hour:minute:second timezone]`

    Example:
    `>>> parse_datetime('17/Jan/2017:13:00:52 +0800')`
    `datetime.datetime(2017, 01, 17, 13, 00, 52, tzinfo=)`
    """
    dt = datetime.strptime(date[1:-7], '%d/%b/%Y:%H:%M:%S')
    dt_tz = int(date[-6:-3]) * 60 + int(date[-3:-1])
    return dt.replace(tzinfo=pytz.FixedOffset(dt_tz))


def load_csv(filename):
    df = pd.read_csv(
        filename,
        sep='\s(?=(?:[^"]*"[^"]*")*[^"]*$)(?![^\[]*\])',
        engine='python',
        na_values='-',
        header=None,
        usecols=[0, 3, 4, 5, 6, 7, 8],
        names=['remote_ip', 'date', 'request', 'status', 'size', 'referer', 'user_agent'],
        converters={
            'date': parse_datetime,
            'request': parse_str,
            'status': int,
            'size': int,
            'referer': parse_str,
            'user_agent': parse_str
        }
    )

    return df
```

### 访问次数最多的IP地址

	def top_remote_ip(df, n=5):
	    remote_ip = df.groupby('remote_ip')['remote_ip'].agg(len)
	    # remote_ip = remote_ip.divide(remote_ip.sum())
	    sorted_ip = remote_ip.sort_values()[-n:]
	    ax = sorted_ip.plot(kind='barh', title='Remote Access', rot=45, alpha=0.75)
	    ax.set_xlabel('Access Count')
	    ax.set_ylabel('Remote IP')
	    plt.show()
  

### 被请求次数最多的API


	def top_request_api(df, n=5):
	    # request = df['request']
	    path = df['request']
	    # path = request.str.extract('\S+\s*(\S+)')
	    # path.value_counts()[:n].plot(kind='pie')
	    path.value_counts()[:n].plot(kind='bar')
	    plt.show()


### 请求次数最多的 HTTP 方法

	def top_request_method(df):
	    method = df['request'].str.extract('(\S+)')
	    method.value_counts().plot(kind='barh')
	    plt.show()

### 访问频率

	def access_rate_base_datetime(df, rule='D', begin=None, end=None):
	    visits = df['request'].copy()
	    visits.index = df['date']
	    visits = visits.resample(rule, kind='period').count()
	    if begin and end:
	        visits = visits[begin:end]
	    elif begin:
	        visits = visits[begin:]
	    elif end:
	        visits = visits[:end]
	
	    visits.plot()
	    plt.title('Total visits')
	    plt.ylabel('vistis')
	    plt.xlabel('datetime')
	    plt.show()

### 测试

	if __name__ == '__main__':
	    import matplotlib.pyplot as plt
	    filename = './access.log'
	    df = load_csv(filename)
	    # print(df.head())
	    # top_remote_ip(df, 10)
	    # top_request_api(df)
	    # top_request_method(df)
	    access_rate_base_datetime(df, 'H', '2017-02-17', '2017-02-19')