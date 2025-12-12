# mysql 安装

## 一、环境检查

卸载已安装的mysql

```shell
[root@node01 ~]# rpm -qa | grep mysql | xargs rpm -e --nodeps
[root@node01 ~]# rpm -qa | grep mariadb | xargs rpm -e --nodeps
```

## 二、安装

这里采用安装mysql的yum源来安装mysql，需要保持网络畅通。

yum源下载地址：https://dev.mysql.com/downloads/repo/yum/

安装mysql yum源（文件在 ./doc/ 目录下）

1. 安装

   ```shell
   [root@node01 ~]# yum -y localinstall mysql57-community-release-el7-11.noarch.rpm
   ```

2. 编辑MySQL的yum源配置，指定要安装的MySQL版本（此步可跳过，不修改），默认安装mysql 5.7

   ```shell
   [root@node01 ~]# vi /etc/yum.repos.d/mysql-community.repo # enabled=1指mysql的默认安装项
   ```

   ```shell
   [mysql-connectors-community]
   name=MySQL Connectors Community
   baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/7/$basearch/
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql-tools-community]
   name=MySQL Tools Community
   baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/7/$basearch/
   enabled=1
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   # Enable to use MySQL 5.5
   [mysql55-community]
   name=MySQL 5.5 Community Server
   baseurl=http://repo.mysql.com/yum/mysql-5.5-community/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   # Enable to use MySQL 5.6
   [mysql56-community]
   name=MySQL 5.6 Community Server
   baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql57-community]
   name=MySQL 5.7 Community Server
   baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
   enabled=1  # 默认安装mysql 5.7
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql80-community]
   name=MySQL 8.0 Community Server
   baseurl=http://repo.mysql.com/yum/mysql-8.0-community/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql-tools-preview]
   name=MySQL Tools Preview
   baseurl=http://repo.mysql.com/yum/mysql-tools-preview/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql-cluster-7.5-community]
   name=MySQL Cluster 7.5 Community
   baseurl=http://repo.mysql.com/yum/mysql-cluster-7.5-community/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   
   [mysql-cluster-7.6-community]
   name=MySQL Cluster 7.6 Community
   baseurl=http://repo.mysql.com/yum/mysql-cluster-7.6-community/el/7/$basearch/
   enabled=0
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
   ```

3. yum安装

   ```shell
   [root@node01 ~]# yum install mysql-community-server -y
   ```

   ```shell
   # 注意，如果上面那步执行完成之后报错:
   # Public key for mysql-community-common-5.7.38-1.el7.x86_64.rpm is not installed
   
   # 需要按如下步骤再执行一次
   [root@node01 ~]# rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 # 这个公钥可能每年都不一样
   [root@node01 ~]# yum install mysql-community-server -y
   ```

   ```shell
   [root@node01 ~]#  rpm -qa | grep -i mysql
   mysql57-community-release-el7-11.noarch
   mysql-community-common-5.7.33-1.el7.x86_64
   mysql-community-client-5.7.33-1.el7.x86_64
   mysql-community-libs-5.7.33-1.el7.x86_64
   mysql-community-libs-compat-5.7.33-1.el7.x86_64
   mysql-community-server-5.7.33-1.el7.x86_64
   [root@node01 ~]#  rpm -ql mysql-community-client-5.7.33-1.el7.x86_64
   /usr/bin/mysql  # 可知 mysql 客户端命令在 /usr/bin/ 目录下
   /usr/bin/mysql_config_editor
   /usr/bin/mysqladmin
   ```

## 三、运行

1. 开启MySQL服务

   ```shell
   [root@node01 ~]# service mysqld status # 查看mysql状态
   Redirecting to /bin/systemctl status mysqld.service
   ● mysqld.service - MySQL Server
      Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
      Active: inactive (dead) # 未启动
        Docs: man:mysqld(8)
              http://dev.mysql.com/doc/refman/en/using-systemd.html
   [root@node01 ~]# service mysqld start # 启动mysql
   Redirecting to /bin/systemctl start mysqld.service
   [root@node01 ~]# service mysqld status
   Redirecting to /bin/systemctl status mysqld.service
   ● mysqld.service - MySQL Server
      Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
      Active: active (running) since Sat 2021-01-23 03:54:45 CST; 8s ago # 已启动
        Docs: man:mysqld(8)
              http://dev.mysql.com/doc/refman/en/using-systemd.html
     Process: 4855 ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid $MYSQLD_OPTS (code=exited, status=0/SUCCESS)
     Process: 4806 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
    Main PID: 4859 (mysqld)
      CGroup: /system.slice/mysqld.service
              └─4859 /usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid
   
   Jan 23 03:54:38 node01 systemd[1]: Starting MySQL Server...
   Jan 23 03:54:45 node01 systemd[1]: Started MySQL Server.
   ```

## 四、初始化配置

### 1、配置密码

1. 查看默认随机密码

   mysql服务启动后会在/var/log/mysqld.log文件中生成了一个随机的默认密码

   ```shell
   [root@node01 ~]# more /var/log/mysqld.log
   找到 A temporary password is generated for root@localhost: 13=gdpmnU,ez
   可知默认密码是 13=gdpmnU,ez
   ```

2. 登录mysql

   ```shell
   [root@node01 ~]# mysql -u root -p 
   Enter password: 
   mysql> 
   ```

3. 修改默认密码

   如果不希望密码太复杂，可以把密码设置的简单点， 比如这里我把密码设置成：root  

   如果修改后的密码不符合密码设置的规定，会出现如下错误；

   ```sql
   mysql> alter user 'root'@'localhost' identified by 'root';
   ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
   ```

   为了执行sql语句，必须先设置一个复杂的符合规定的密码，如：lPSQG(Zsn5Uj

   ```sql
   mysql>  alter user 'root'@'localhost' identified by 'lPSQG(Zsn5Uj';
   Query OK, 0 rows affected (0.00 sec)
   ```

    修改密码成功后，就可以执行SQL语句了，先查看下默认的密码设置规定

   ```sql
   mysql> show variables like '%password%';
   +----------------------------------------+-----------------+
   | Variable_name                          | Value           |
   +----------------------------------------+-----------------+
   | default_password_lifetime              | 0               |
   | disconnect_on_expired_password         | ON              |
   | log_builtin_as_identified_by_password  | OFF             |
   | mysql_native_password_proxy_users      | OFF             |
   | old_passwords                          | 0               |
   | report_password                        |                 |
   | sha256_password_auto_generate_rsa_keys | ON              |
   | sha256_password_private_key_path       | private_key.pem |
   | sha256_password_proxy_users            | OFF             |
   | sha256_password_public_key_path        | public_key.pem  |
   | validate_password_check_user_name      | OFF             |
   | validate_password_dictionary_file      |                 |
   | validate_password_length               | 8               |
   | validate_password_mixed_case_count     | 1               |
   | validate_password_number_count         | 1               |
   | validate_password_policy               | MEDIUM          |
   | validate_password_special_char_count   | 1               |
   +----------------------------------------+-----------------+
   17 rows in set (0.03 sec)
   ```

   修改密码检查策略

   ```sql
   // 查看验证相关的变量
   SHOW VARIABLES LIKE '%validate%';
   
   //设置密码检查策略为0(即LOW，默认为MEDIUM)
   mysql> set global validate_password_policy=0;   -- mysql8 中改成  set global validate_password.policy=0;
   Query OK, 0 rows affected (0.00 sec) 
   
   //设置密码的长度为1，默认为8，但是密码长度最短为4，虽然设置成1，但还是4
   mysql> set global validate_password_length=1;   -- mysql8 中改成 set global validate_password.length=1;
   Query OK, 0 rows affected (0.00 sec) 
   
   最后执行 alter user 'root'@'localhost' identified by 'root'; 123！@#
   ```


### 2、允许远程登录

```sql
mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> update user set host = '%' where user = 'root'; # root用户可以再任何机器上登录到本机
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

--  mysql8 里因为插件 caching_sha2_password 的影响会导致远程登录不生效，需要启用 mysql_native_password 插件
vim /etc/my.cnf
追加 mysql_native_password=ON
修改 root@% 的 认证插件为 mysql_native_password
use mysql;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '1qaz@WSX';  -- 这里要保证密码复杂度，不然会报错
flush privileges;

```
