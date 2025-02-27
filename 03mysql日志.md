# mysql日志

## 一、错误日志

日志路径： `/var/log/mysqld.log` 错误日志默认开启。

```mysql
mysql> show variables like '%log_error%';
+----------------------------+----------------------------------------+
| Variable_name              | Value                                  |
+----------------------------+----------------------------------------+
| binlog_error_action        | ABORT_SERVER                           |
| log_error                  | stderr                                 |
| log_error_services         | log_filter_internal; log_sink_internal |
| log_error_suppression_list |                                        |
| log_error_verbosity        | 2                                      |
+----------------------------+----------------------------------------+
5 rows in set (0.00 sec)
```

## 二、二进制日志

- 在mysql8中二进制日志默认开启,  mysql 5 中是关闭的

```mysql
mysql> show variables like '%log_bin%';
+---------------------------------+--------------------------------+
| Variable_name                   | Value                          |
+---------------------------------+--------------------------------+
| log_bin                         | ON                             |
| log_bin_basename                | /var/lib/mysql/mysql-bin       |
| log_bin_index                   | /var/lib/mysql/mysql-bin.index |
| log_bin_trust_function_creators | OFF                            |
| log_bin_use_v1_row_events       | OFF                            |
| sql_log_bin                     | ON                             |
+---------------------------------+--------------------------------+
```

- 二进制日志格式

| 日志格式  | 含义                                                         |
| --------- | ------------------------------------------------------------ |
| STATEMENT | 每一条对数据造成修改的SOL 语句都会记录在日志中               |
| ROW       | 将每一行的变更记录到日志中                                   |
| MIXED     | 混合了STATEMENT和ROW 两种日志。默认情况采用STATEMENT，但在一些特殊情况下采用ROW 来进行记录 |

```sql
mysql> show variables like '%binlog_format%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
1 row in set (0.00 sec)
```

- 手动配置二进制日志,   配置文件路径 /etc/my.cnf

```properties
server-id=1
log-bin=mysql-bin
binlog_format=row
binlog-do-db=gmall
```

- 查看二进制日志

由于日志是以二进制方式存储的，不能直接读取，需要通过二进制日志查询工具 mysqlbinlog 来查看，具体语法

```
mysqlbinlog [ 参数选项 ] logfilename
参数选项：
-d 指定数据库名称，只列出指定的数据库相关操作。
-o 忽略掉日志中的前n行命令。
-v 将行事件(数据变更)重构为SQL语句
-vv 将行事件(数据变更)重构为SQL语句，并输出注释信
```

- 二进制日志删除

| 指令                                              | 含义                                                         |
| ------------------------------------------------- | ------------------------------------------------------------ |
| reset master                                      | 删除全部 binlog日志，删除之后， 日志编号将从 binlong.000001 重新开始 |
| `PURGE BINARY LOGS TO 'binlog.****';`             | 删除`****`编号之前的所有日志                                 |
| PURGE BINARY LOGS BEFORE 'yyyy-mm-dd hh24:mi:ss'; | 删除 yyyy-mm-dd hh24:mi:ss 之前产生的所有日志                |

也可以在mysql的配置文件中配置二进制日志的过期时间，设置了之后，二进制日志过期会自动删除 

```sql
show variables like '%binlog_expire_logs_seconds%';
```

查看当前写入的二进制文件

```sql
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |  3014532 | gmall        |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

## 三、查询日志

查询日志中记录了客户端的所有操作语句，而二进制日志不包含查询数据的 SQL 语句。默认情况下，查询日志是未开启的。

```sql
mysql> show variables like '%general%';
+------------------+---------------------------------+
| Variable_name    | Value                           |
+------------------+---------------------------------+
| general_log      | OFF                             |
| general_log_file | /var/lib/mysql/e6a7d4336717.log |
+------------------+---------------------------------+

```

如果需要开启查询日志，可以修改MySQL的配置文件 /etc/my.cnf 文件，添加如下内容:

```properties
#该选项用来开启查询日志 ， 可选值 ： 0 或者 1 ； 0 代表关闭， 1 代表开启
general_log=1
#设置日志的文件名 ， 如果没有指定， 默认的文件名为 host_name.log
general_log_file=mysql_query.log
```

开启了查询日志之后，在 MySQL 的数据存放目录，也就是 /var/lib/mysql/ 目录下就会出现mysql_query.log 文件。之后所有的客户端的增删改查操作都会记录在该日志文件之中，长时间运行后，该日志文件将会非常大

## 四、慢查询日志

慢查询日志记录了所有执行时间超过参数 long_query_time 设置值并且扫描记录数不小于min_examined_row_limit 的所有的 SQL 语句的日志，默认未开启。 long_query_time 默认为10 秒，最小为 0 ， 精度可以到微秒。
如果需要开启慢查询日志，需要在 MySQL 的配置文件 /etc/my.cnf 中配置如下参数：

```properties
#慢查询日志
slow_query_log=1
#执行时间参数
long_query_time=2
```

默认情况下，不会记录管理语句，也不会记录不使用索引进行查找的查询。可以使用log_slow_admin_statements 和 更改此行为 log_queries_not_using_indexes ，如下所述

```properties
#记录执行较慢的管理语句
log_slow_admin_statements =1
#记录执行较慢的未使用索引的语句
log_queries_not_using_indexes = 1
```

