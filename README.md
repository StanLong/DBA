windows 按二进制包的形式安装mysql

https://blog.csdn.net/m0_62808124/article/details/126769669

my.ini
[client]
    port=3306
    default-character-set=utf8mb4
[mysql]
	prompt=\\u@\\h \\v [\\d]>\\_
	default-character-set = utf8mb4
[mysqld]
	port=3306
	character_set_server=utf8mb4
	default-storage-engine=INNODB
	default-time_zone='+8:00'
	basedir=D:\StanLong\Tools\mysql-8.0.40-winx64
	datadir=D:\StanLong\Tools\mysql-8.0.40-winx64\data
[WinMySQLAdmin]
	%MYSQL_HOME%\bin\mysqld.exe
