MySql 视图是一个虚拟表。其内容由查询定义。
使用视图的原因：
1、使复杂的查询简单化
2、安全


创建视图
create view u as select user, host, authentication_string from user;


查询视图
mysql> select * from u;
+------+-----------+-----------------------+
| user | host      | authentication_string |
+------+-----------+-----------------------+
| root | localhost |                       |
| root | 127.0.0.1 |                       |
| root | ::1       |                       |
|      | localhost | NULL                  |
+------+-----------+-----------------------+
4 rows in set (0.00 sec)

修改视图：
alter view u as select user, host from user;

删除视图
DROP view u;