# mysql 主从同步

mysql主从同步架构 ： https://developer.aliyun.com/article/1575650

# 一、实验环境

mysql 8.4.4 配置 一主一从

# 二、主从配置

## 1、主 node03

```shell
# 修改 Master 的配置文件/etc/my.cnf
vim /etc/my.cnf 

[mysqld]
# 主服务器唯一标识，必须是正整数
server-id = 1
# 开启二进制日志，记录数据库变更
log-bin = mysql-bin
# 启用 GTID 模式
gtid_mode = ON
# 强制 GTID 一致性
enforce_gtid_consistency = ON
# 允许从服务器将复制的事件写入自己的二进制日志，用于级联复制
log-slave-updates = ON
# 指定要同步的数据库，若同步所有数据库可省略此配置
# binlog-do-db = your_database_name
read_only=0
```

## 2、从 node04

```shell
[mysqld]
# 从服务器唯一标识，需与主服务器不同且为正整数
server-id = 2
# 开启 GTID 模式
gtid_mode = ON
# 强制 GTID 一致性
enforce_gtid_consistency = ON
# 中继日志，存储从主服务器接收到的二进制日志
relay-log = mysql-relay-bin
# 开启二进制日志，用于级联复制等
log-bin = mysql-bin
read_only=1
```

修改好之后重启主从上的mysql服务

```shell
service mysqld restart
```

## 3、创建同步用户

在主节点创建一个用户sync，用于从节点链接主节点时使用。

```mysql
mysql> CREATE USER 'sync'@'node04' IDENTIFIED BY 'Sync@node04';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'sync'@'node04';
mysql> flush privileges;
```

## 4、在从节点上设置主节点参数

```mysql
mysql> CHANGE REPLICATION SOURCE TO 
SOURCE_HOST='node03', 
SOURCE_USER='sync', 
SOURCE_PASSWORD='Sync@node04', 
SOURCE_PORT=3306,  
SOURCE_SSL=1,
SOURCE_AUTO_POSITION = 1;   
```

## 5、启动从服务器复制过程

```mysql
mysql> START REPLICA;
```

## 6、检查从服务器服务状态

```shell
mysql> show REPLICA status\G;
```

## 7、测试验证

在主上增删改查，观察从库变化
