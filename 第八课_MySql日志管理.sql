error log   错误日志    排错   /var/log/mysqld.log(默认开启)
bin log     二进程日志  备份   增量备份 
relay log   中继日志    复制   接收 replication master
slow log    慢查询日志  调优   查询时间超过指定值


按ctrl+z退出mysql，按fg返回mysql


修改mysql日志配置文件
vim /etc/my.cnf

log-error=/var/log/mysqld.log                         --错误日志
pid-file=/var/run/mysqld/mysqld.pid
log-bin=mysqlbinilog-node01                             --mysql 二进制日志， 看起来只能保存日志到默认路径 /var/bin/mysql  mysqlbinilog-node01 为日志前缀
server-id=11
slow_query_log=1                                      --开启慢查询日志
slow_query_log_file=/var/log/mysql/slow.log
long_query_time=3


配置完成之后重启 mysql
systemctl restart mysqld

查看二进制文件
mysqlbinilog -v 文件名

清理二进制日志，禁用
reset master

截断日志，重启也会截断日志
flush logs

删除部分日志
purge binary logs to 'mysqlbinilog-node01-0001';
purge binary logs before '2016-04-02 22:46:26';

暂停， 进当前会话
set sql_log_bin=0;
set sql_log_bin=1;

截取 binlog
datetime：
#mysqlbinlog mysqlbinilog-node01-0001 --start-datetime="20190726 10:10:10"
#mysqlbinlog mysqlbinilog-node01-0001 --stop-datetime="20190727 10:10:10"
#mysqlbinlog mysqlbinilog-node01-0001 --start-datetime="20190726 10:10:10" --stop-datetime="20190727 10:10:10"

position:
#mysqlbinlog mysqlbinilog-node01-0001 --start-position=250
#mysqlbinlog mysqlbinilog-node01-0001 --stop-position=260
#mysqlbinlog mysqlbinilog-node01-0001 --start-position=250 --stop-position=260

测试慢查询 
select benchmark(50000000, 2*3);