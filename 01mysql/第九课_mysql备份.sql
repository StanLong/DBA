最原始的数据备份：
tar备份数据库：备份期间，数据不可用

备份过程：【完全物理备份】
1、停止数据库
2、tar备份数据库
3、启动数据库

[root@node01 ~]# systemctl stop mysqld
[root@node01 ~]# make dir /var/mysqlbackup
[root@node01 ~]# tar -cf /var/mysqlbackup/`date +%F`-mysql-all.tar /var/lib/mysql
tar: Removing leading `/' from member names
[root@node01 ~]# cd /var/mysqlbackup/
[root@node01 mysqlbackup]# ll
total 123960
-rw-r--r-- 1 root root 126935040 Jul 28 09:05 2019-07-28-mysql-all.tar
注：备份的数据应该存储到其他的服务器或存储介质中


还原的过程
1、停止数据库
2、清理环境
3、导入备份数据
4、启动数据库
5、binlog恢复

[root@node01 mysqlbackup]# systemctl stop mysqld
[root@node01 mysqlbackup]# rm -rf /var/lib/mysql/*
[root@node01 mysql]# tar -xf /var/mysqlbackup/2019-07-28-mysql-all.tar -C /
[root@node01 mysql]# systemctl start mysqld




LVM备份
如果之前没有准备逻辑卷，需要先进行数据迁移

----------------------------------------------------------------------------------------------
数据迁移，数据迁移之前要先把mysql服务停掉，以保证所有的数据都已经保存到硬盘里
1、准备LVM及文件系统

在虚拟机上额外多准备一块硬盘

[root@node01 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0  200G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0  199G  0 part 
  ├─centos-root 253:0    0   50G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
  └─centos-home 253:2    0  147G  0 lvm  /home
sdb               8:16   0    1G  0 disk                      --从虚拟机上添加的硬盘
sr0              11:0    1  4.2G  0 rom  

2、把这块新硬盘做成VG
# VG:LVM中的物理的磁盘分区，也就是PV，必须加入VG，
#可以将VG理解为一个仓库或者是几个大的硬盘
#vgcreate命令 用于创建LVM卷组
#vgcreate datavg /dev/sdb 在 /dev/sdb 创建卷组 datavg

[root@node01 ~]# vgcreate datavg /dev/sdb 
  Physical volume "/dev/sdb" successfully created.
  Volume group "datavg" successfully created
[root@node01 ~]# 


3、创建逻辑卷
#LV：也就是从VG中划分的逻辑分区
#lvcreate -L 500M -n mysql datavg 在 卷组datavg上创建一个大小为 1000M，名称为mysql 的逻辑卷
[root@node01 ~]# lvcreate -L 1000M -n mysql datavg
  Logical volume "mysql" created.
[root@node01 ~]#

#lvscan指令用于扫描当前系统中存在的所有的LVM逻辑卷。
[root@node01 ~]# lvscan
  ACTIVE            '/dev/centos/root' [50.00 GiB] inherit
  ACTIVE            '/dev/centos/home' [146.99 GiB] inherit
  ACTIVE            '/dev/centos/swap' [2.00 GiB] inherit
  ACTIVE            '/dev/datavg/mysql' [900.00 MiB] inherit       --上一步创建的
[root@node01 ~]# 

#vgs:显示有关卷组的信息 
[root@node01 ~]# vgs
  VG     #PV #LV #SN Attr   VSize    VFree  
  centos   1   3   0 wz--n- <199.00g   4.00m
  datavg   1   1   0 wz--n- 1020.00m 520.00m
[root@node01 ~]# 

#dm-0、dm-1、dm-2的主设备号是253（是linux内核留给本地使用的设备号）
#次设备号分别是0、1、2，这类设备在/dev/mapper中
4、格式化逻辑卷
[root@node01 ~]# mkfs.xfs /dev/datavg/mysql 
meta-data=/dev/datavg/mysql      isize=512    agcount=4, agsize=32000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=128000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=855, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@node01 ~]# 

5、将逻辑卷挂在到临时目录
[root@node01 ~]# mount /dev/datavg/mysql /mnt/

6、备份数据
[root@node01 ~]# cp -a /var/lib/mysql/* /mnt/

7、卸载逻辑卷
[root@node01 ~]# umount /mnt/


8、编辑 vi /etc/fstab，加上这么一句
/dev/datavg/mysql       /var/lib/mysql          xfs     defaults        0 0
开机将 /dev/datavg/mysql 挂载到 /var/lib/mysql 不备份 不检测

9、查看
[root@node01 ~]# mount -a
[root@node01 ~]# df
Filesystem               1K-blocks    Used Available Use% Mounted on
/dev/mapper/centos-root   52403200 2381852  50021348   5% /
devtmpfs                    488784       0    488784   0% /dev
tmpfs                       499848       0    499848   0% /dev/shm
tmpfs                       499848    6836    493012   2% /run
tmpfs                       499848       0    499848   0% /sys/fs/cgroup
/dev/mapper/centos-home  154057220   32944 154024276   1% /home
/dev/sda1                  1038336  127468    910868  13% /boot
tmpfs                        99972       0     99972   0% /run/user/0
/dev/mapper/datavg-mysql    508580  162720    345860  32% /var/lib/mysql


10、改权限，重启mysql服务
[root@node01 mapper]# chown -R mysql.mysql /var/lib/mysql
[root@node01 mapper]# systemctl restart mysqld

--不改权限可能会报这个错
2019-07-30T15:33:09.552248Z 0 [ERROR] MYSQL_BIN_LOG::open_purge_index_file failed to open register  file.
2019-07-30T15:33:09.552259Z 0 [ERROR] MYSQL_BIN_LOG::open_index_file failed to sync the index file.
2019-07-30T15:33:09.552267Z 0 [ERROR] Aborting

到这一步，数据迁移结束 保存到 /var/lib/mysql 都已迁移到 /dev/mapper/datavg-mysql

------------------------------------------------------------------------------------------------------------------------------------


#LVM 快照被封流程
#1、加全局读锁
#mysql> flush tables with read lock;
#Query OK, 0 rows affected (0.00 sec)
#
#2、创建快照
#lvcreate -L 400M -s -n lv-mysql-snap /dev/datavg/mysql
#mysql -p('root') -e 'show master status' > /backup/`date +%F`_position.txt
#
#3、释放锁
#unlock tables;

4、1-3 这三步必须的同一会话中完成,否则没有意义，在同一段会话中执行 unlock tables 解锁可以不加
echo "flush tables with read lock; system lvcreate -L 400M -s -n mysql-snap /dev/datavg/mysql; unlock tables;" | mysql -u root -p

[root@node01 mapper]# echo "flush tables with read lock; system lvcreate -L 900M -s -n mysql-snap /dev/datavg/mysql; unlock tables;" | mysql -u root -p
Enter password: 
File descriptor 3 (socket:[28951]) leaked on lvcreate invocation. Parent PID 1256: mysql
  Using default stripesize 64.00 KiB.
  Logical volume "mysql-snap" created.
[root@node01 mapper]#
这一步执行完成之后，快照卷里的文件和 /dev/mapper/datavg-mysql 一样，即和 /var/lib/mysql。

查看快照
[root@node01 mapper]# lvscan
  ACTIVE            '/dev/centos/root' [50.00 GiB] inherit
  ACTIVE            '/dev/centos/home' [146.99 GiB] inherit
  ACTIVE            '/dev/centos/swap' [2.00 GiB] inherit
  ACTIVE   Original '/dev/datavg/mysql' [500.00 MiB] inherit
  ACTIVE   Snapshot '/dev/datavg/mysql-snap' [400.00 MiB] inherit


5、从快照中备份（这一步可能有问题）

[root@node01 mapper]# mount -o ro,nouuid /dev/datavg/mysql-snap /mnt/     --xfs文件系统不支持uuid
[root@node01 mapper]# ls /mnt/                                            --这一步应该能看到东西
[root@node01 mapper]# mkdir /backup
[root@node01 backup]# tar -czf /backup/mysql_`date +%F`.tar.gz /var/lib/mysql/*


6、卸载快照
[root@node01 backup]# umount /dev/datavg/mysql-snap 
[root@node01 backup]# lvremove /dev/datavg/mysql-snap -f
  Logical volume "mysql-snap" successfully removed
[root@node01 backup]#

7、数据恢复
	停止数据库
	[root@node01 ~]#systemctl stop mysqld
	清理环境
	[root@node01 ~]# rm -rf /var/lib/mysql/*
	导入数据
	[root@node01 ~]# tar -zxf /var/mysqlbackup/mysql_2019-08-04.tar.gz -C /
	修改权限
	[root@node01 ~]# chown -R mysql.mysql /var/lib/mysql
	启动数据库
	binlog恢复
	


