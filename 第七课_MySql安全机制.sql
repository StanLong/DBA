默认情况下mysql不允许从远程连接

MySql 权限表

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| framework          |
| jdbc_database      |
| mysql              |   --权限库
| performance_schema |
| scott              |
| taotao             |
| test               |
+--------------------+

mysql.user              --全局权限
mysql.db                --数据库级别的权限
mysql.tables_priv       --表级权限
mysql.columns_priv      --列级授权
mysql.procs_priv        --存储过程和函数授权
mysql.proxies_priv      --代理授权


mysql> desc user;
+------------------------+-----------------------------------+------+-----+-----------------------+-------+
| Field                  | Type                              | Null | Key | Default               | Extra |
+------------------------+-----------------------------------+------+-----+-----------------------+-------+
| Host                   | char(60)                          | NO   | PRI |                       |       |
| User                   | char(16)                          | NO   | PRI |                       |       |
| Password               | char(41)                          | NO   |     |                       |       |
| Select_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Insert_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Update_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Delete_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Create_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Drop_priv              | enum('N','Y')                     | NO   |     | N                     |       |
| Reload_priv            | enum('N','Y')                     | NO   |     | N                     |       |
| Shutdown_priv          | enum('N','Y')                     | NO   |     | N                     |       |
| Process_priv           | enum('N','Y')                     | NO   |     | N                     |       |
| File_priv              | enum('N','Y')                     | NO   |     | N                     |       |
| Grant_priv             | enum('N','Y')                     | NO   |     | N                     |       |
| References_priv        | enum('N','Y')                     | NO   |     | N                     |       |
| Index_priv             | enum('N','Y')                     | NO   |     | N                     |       |
| Alter_priv             | enum('N','Y')                     | NO   |     | N                     |       |
| Show_db_priv           | enum('N','Y')                     | NO   |     | N                     |       |
| Super_priv             | enum('N','Y')                     | NO   |     | N                     |       |
| Create_tmp_table_priv  | enum('N','Y')                     | NO   |     | N                     |       |
| Lock_tables_priv       | enum('N','Y')                     | NO   |     | N                     |       |
| Execute_priv           | enum('N','Y')                     | NO   |     | N                     |       |
| Repl_slave_priv        | enum('N','Y')                     | NO   |     | N                     |       |
| Repl_client_priv       | enum('N','Y')                     | NO   |     | N                     |       |
| Create_view_priv       | enum('N','Y')                     | NO   |     | N                     |       |
| Show_view_priv         | enum('N','Y')                     | NO   |     | N                     |       |
| Create_routine_priv    | enum('N','Y')                     | NO   |     | N                     |       |
| Alter_routine_priv     | enum('N','Y')                     | NO   |     | N                     |       |
| Create_user_priv       | enum('N','Y')                     | NO   |     | N                     |       |
| Event_priv             | enum('N','Y')                     | NO   |     | N                     |       |
| Trigger_priv           | enum('N','Y')                     | NO   |     | N                     |       |
| Create_tablespace_priv | enum('N','Y')                     | NO   |     | N                     |       |
| ssl_type               | enum('','ANY','X509','SPECIFIED') | NO   |     |                       |       |
| ssl_cipher             | blob                              | NO   |     | NULL                  |       |
| x509_issuer            | blob                              | NO   |     | NULL                  |       |
| x509_subject           | blob                              | NO   |     | NULL                  |       |
| max_questions          | int(11) unsigned                  | NO   |     | 0                     |       |
| max_updates            | int(11) unsigned                  | NO   |     | 0                     |       |
| max_connections        | int(11) unsigned                  | NO   |     | 0                     |       |
| max_user_connections   | int(11) unsigned                  | NO   |     | 0                     |       |
| plugin                 | char(64)                          | YES  |     | mysql_native_password |       |
| authentication_string  | text                              | YES  |     | NULL                  |       |
| password_expired       | enum('N','Y')                     | NO   |     | N                     |       |
+------------------------+-----------------------------------+------+-----+-----------------------+-------+
43 rows in set (0.03 sec)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
创建用户
官方实例
CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'mypass';
GRANT ALL ON db1.* TO 'jeffrey'@'localhost';
GRANT SELECT ON db2.invoice TO 'jeffrey'@'localhost';
GRANT USAGE ON *.* TO 'jeffrey'@'localhost' WITH MAX_QUERIES_PER_HOUR 90;


grant all on *.* to 'stanlong'@'127.0.0.1' identified by 'stanlong';  --创建用户 stanlong 密码 stanlong, 并赋予所有库，所有表的权限

mysql> select * from user where user='stanlong'\G;
*************************** 1. row ***************************
                  Host: 127.0.0.1
                  User: stanlong
              Password: *37DF556B2E1D8EE4DB7197732B6EDAA7AC2F2880
           Select_priv: Y
           Insert_priv: Y
           Update_priv: Y
           Delete_priv: Y
           Create_priv: Y
             Drop_priv: Y
           Reload_priv: Y
         Shutdown_priv: Y
          Process_priv: Y
             File_priv: Y
            Grant_priv: N                          -- 没有给其他帐户赋予权限的权限，即没有授权权限
       References_priv: Y
            Index_priv: Y
            Alter_priv: Y
          Show_db_priv: Y
            Super_priv: Y
 Create_tmp_table_priv: Y
      Lock_tables_priv: Y
          Execute_priv: Y
       Repl_slave_priv: Y
      Repl_client_priv: Y
      Create_view_priv: Y
        Show_view_priv: Y
   Create_routine_priv: Y
    Alter_routine_priv: Y
      Create_user_priv: Y
            Event_priv: Y
          Trigger_priv: Y
Create_tablespace_priv: Y
              ssl_type:
            ssl_cipher:
           x509_issuer:
          x509_subject:
         max_questions: 0
           max_updates: 0
       max_connections: 0
  max_user_connections: 0
                plugin: mysql_native_password
 authentication_string:
      password_expired: N
1 row in set (0.00 sec)


查看权限
mysql> show grants;
+--------------------------------------------------------------------------------------------------------------------------+
| Grants for stanlong@127.0.0.1                                                                                            |
+--------------------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'stanlong'@'127.0.0.1' IDENTIFIED BY PASSWORD '*37DF556B2E1D8EE4DB7197732B6EDAA7AC2F2880' |
+--------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

查看其他用户权限
show grants for stanlong@'127.0.0.1';

回收权限
revoke all privileges on *.* from 'stanlong'@'127.0.0.1';

revoke select on *.* from 'stanlong'@'127.0.0.1'; --撤回 select 权限

grant select on *.* to stanlong@'%'; --重新赋权

grant select(col1), insert(col2, col3) on taotao.tb_user to stanlong@'%'; --给 stanlong 用户赋于 taotao.tb_user 表 第一列的查询权限，第二列和第三列的insert权限

修改用户密码
--方法1：
C:\Users\矢量>mysqladmin -uroot -proot password 'root123';
Warning: Using a password on the command line interface can be insecure.

--方法2：
set password = password('root');

--方法3：改其他用户的密码
mysql> set password for 'stanlong'@'127.0.0.1'=password('root123');
Query OK, 0 rows affected (0.00 sec)

方法4：
update mysql.user set authentication_string=password('root123') where user='stanlong' and host='127.0.0.1';
flush privileges;



--删除用户
方法1：
drop user 'stanlong'@'127.0.0.1';
方法2：
delete from mysql.user where user='stanlong' and host='localhost';
flush privileges;
