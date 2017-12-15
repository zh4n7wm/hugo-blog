---
title: "hive分析elb访问日志"
author: "ox0spy"
date: 2017-12-15T19:22:01+08:00
tags: ["hive"]
categories: ["bigdata"]
---

# Hive分析ELB访问日志

## Hive 分析

### 创建Hive table

```
CREATE EXTERNAL TABLE IF NOT EXISTS elb_raw_access_logs (
  request_timestamp string, 
  elb_name string, 
  request_ip string, 
  request_port int, 
  backend_ip string, 
  backend_port int, 
  request_processing_time double, 
  backend_processing_time double, 
  client_response_time double, 
  elb_response_code string, 
  backend_response_code string, 
  received_bytes bigint, 
  sent_bytes bigint, 
  request_verb string, 
  url string, 
  protocol string, 
  user_agent string, 
  ssl_cipher string, 
  ssl_protocol string ) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
         'serialization.format' = '1','input.regex' = '([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:\-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \\\"([^ ]*) ([^ ]*) (- |[^ ]*)\\\" (\"[^\"]*\") ([A-Z0-9-]+) ([A-Za-z0-9.-]*)$' ) 
LOCATION 's3://onetouch-test-elb/';
```

### 分析

查看数据：

```
SELECT * FROM elb_raw_access_logs WHERE elb_response_code = '200' LIMIT 10;
```
日期：2017-04-17T10:11:32.623734Z

各模块正常请求的平均响应时间:

	SELECT elb_name, avg(backend_processing_time)
		FROM elb_raw_access_logs
		WHERE elb_response_code == '200'
		GROUP BY elb_name;

#### Hive partition

```
CREATE EXTERNAL TABLE IF NOT EXISTS elb_raw_access_logs_part (
  request_timestamp string, 
  elb_name string, 
  request_ip string, 
  request_port int, 
  backend_ip string, 
  backend_port int, 
  request_processing_time double, 
  backend_processing_time double, 
  client_response_time double, 
  elb_response_code string, 
  backend_response_code string, 
  received_bytes bigint, 
  sent_bytes bigint, 
  request_verb string, 
  url string, 
  protocol string, 
  user_agent string, 
  ssl_cipher string, 
  ssl_protocol string ) 
PARTITIONED BY(year string, month string, day string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
         'serialization.format' = '1','input.regex' = '([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:\-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \\\"([^ ]*) ([^ ]*) (- |[^ ]*)\\\" (\"[^\"]*\") ([A-Z0-9-]+) ([A-Za-z0-9.-]*)$' )
LOCATION 's3://onetouch-test-elb/';
```

#### alert table

```
ALTER TABLE elb_raw_access_logs_part ADD PARTITION (year='2017',month='05',day='30') 
    location 's3://onetouch-test-elb/proxy/AWSLogs/677234397898/elasticloadbalancing/us-east-1/2017/05/30/';

show partitions elb_raw_access_logs_part;
```
#### 分析

2017-05-30 的数据按 `elb_response_code` 分组：

```
SELECT elb_response_code, count(url) FROM elb_raw_access_logs_part
    WHERE year = '2017' AND month = '05' AND day = '30'
    GROUP BY elb_response_code;
```

以天为单位统计模块吞吐量：

```
select year, month, day, count(*) as total_request_count 
from auth_elb_access_logs_part
group by year, month, day;
```

以天为单位统计错误率:

```
select year, month, day, SUM( IF( substr(elb_response_code, 1, 1) != '2', 1 , 0 ) )/ COUNT(*) * 100 as error_rate_pct 
from auth_elb_access_logs_part
group by year, month, day;
```

以天为单位计算平均响应时间：

```
select year, month, day, avg(backend_processing_time) as avg_backend_processing_time
from auth_elb_access_logs_part
group by year, month, day;
```