# kafka数据到clickhouse

参考地址： https://cloud.tencent.com/developer/article/1986850

## 一、环境准备

jdk、zookeeper、kafka、clickhouse 先安装好。

安装过程略

## 二、创建消费表

消费数据结构如下

```json
{
  "common": {
    "ar": "230000",
    "ba": "iPhone",
    "ch": "Appstore",
    "is_new": "1",
    "md": "iPhone 8",
    "mid": "YXfhjAYH6As2z9Iq",
    "os": "iOS 13.2.9",
    "uid": "485",
    "vc": "v2.1.134"
  },
  "actions": [
    {
      "action_id": "favor_add",
      "item": "3",
      "item_type": "sku_id",
      "ts": 1585744376605
    }
  ],
  "displays": [
    {
      "displayType": "query",
      "item": "3",
      "item_type": "sku_id",
      "order": 1,
      "pos_id": 2
    },
    {
      "displayType": "promotion",
      "item": "6",
      "item_type": "sku_id",
      "order": 2,
      "pos_id": 1
    },
    {
      "displayType": "promotion",
      "item": "9",
      "item_type": "sku_id",
      "order": 3,
      "pos_id": 3
    },
    {
      "displayType": "recommend",
      "item": "6",
      "item_type": "sku_id",
      "order": 4,
      "pos_id": 2
    },
    {
      "displayType": "query ",
      "item": "6",
      "item_type": "sku_id",
      "order": 5,
      "pos_id": 1
    }
  ],
  "page": {
    "during_time": 7648,
    "item": "3",
    "item_type": "sku_id",
    "last_page_id": "login",
    "page_id": "good_detail",
    "sourceType": "promotion"
  },
  "start": {
    "entry": "icon",
    "loading_time": 18803,
    "open_ad_id": 7,
    "open_ad_ms": 3449,
    "open_ad_skip_ms": 1989
  },
  "err": {
    "error_code": "1234",
    "msg": "***********"
  },
  "ts": 1585744374423
}
```

```sql
create database kafka_data;
use kafka_data;

CREATE TABLE kafka_queue
(
    `common` Tuple(ar String, ba String, ch String, is_new String, md String, mid String, os String, uid String, vc String),
    `actions` Array(Tuple(action_id String, item String, item_type String, ts Int64)),
    `displays` Array(Tuple(displayType String, item String, item_type String, order Int64, pos_id Int64)),
    `page` Tuple(during_time Int64, item String, item_type String, last_page_id String, page_id String, sourceType String),
    `start` Tuple(entry String, loading_time Int64, open_ad_id Int64, open_ad_ms Int64, open_ad_skip_ms Int64),
    `err` Tuple(error_code String, msg String),
    `ts` Int64
)engine =Kafka() 
settings 
kafka_broker_list = 'node02:9092',
kafka_topic_list='topic_log',
kafka_group_name='group1',
kafka_format='JSONEachRow',
kafka_skip_broken_messages=100;

create table kafka_table
(
`common` Tuple(ar String, ba String, ch String, is_new String, md String, mid String, os String, uid String, vc String),
    `actions` Array(Tuple(action_id String, item String, item_type String, ts Int64)),
    `displays` Array(Tuple(displayType String, item String, item_type String, order Int64, pos_id Int64)),
    `page` Tuple(during_time Int64, item String, item_type String, last_page_id String, page_id String, sourceType String),
    `start` Tuple(entry String, loading_time Int64, open_ad_id Int64, open_ad_ms Int64, open_ad_skip_ms Int64),
    `err` Tuple(error_code String, msg String),
    `ts` Int64
) engine=MergeTree() order by ts;

create materialized view consumer to kafka_table as select common,actions,displays,page,start,err,ts from kafka_queue;

```

clickhouse 模式推断判断json字段类型

```
CREATE TABLE user_log
ENGINE = MergeTree
ORDER BY ts 
AS SELECT *
FROM format(JSONEachRow, '{"common":{"ar":"230000","ba":"iPhone","ch":"Appstore","is_new":"1","md":"iPhone 8","mid":"YXfhjAYH6As2z9Iq","os":"iOS 13.2.9","uid":"485","vc":"v2.1.134"},"actions":[{"action_id":"favor_add","item":"3","item_type":"sku_id","ts":1585744376605}],"displays":[{"displayType":"query","item":"3","item_type":"sku_id","order":1,"pos_id":2},{"displayType":"promotion","item":"6","item_type":"sku_id","order":2,"pos_id":1},{"displayType":"promotion","item":"9","item_type":"sku_id","order":3,"pos_id":3},{"displayType":"recommend","item":"6","item_type":"sku_id","order":4,"pos_id":2},{"displayType":"query ","item":"6","item_type":"sku_id","order":5,"pos_id":1}],"page":{"during_time":7648,"item":"3","item_type":"sku_id","last_page_id":"login","page_id":"good_detail","sourceType":"promotion"},"start":{"entry":"icon","loading_time":18803,"open_ad_id":7,"open_ad_ms":3449,"open_ad_skip_ms":1989},"err":{"error_code":"1234","msg":"***********"},"ts":1585744374423}') SETTINGS schema_inference_make_columns_nullable = 0;



SHOW CREATE TABLE user_log;
```





