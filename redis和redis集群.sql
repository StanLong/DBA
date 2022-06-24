redis单机版

1、上传redis安装包到环境
	redis-3.0.0.tar.gz

2、安装 gcc
	yum install gcc-c++

3、解压 redis-3.0.0.tar.gz 到 /opt 目录下
[root@taotao redis-3.0.0]# pwd
/opt/redis/redis-3.0.0


4、执行 make 命令

5、执行 make install 
	make install PREFIX=/opt/redis/redis
	
[root@taotao redis]# ll
total 0
drwxr-xr-x 3 root root  17 Aug 30 09:44 redis
drwxrwxr-x 6 root root 306 Aug 30 09:43 redis-3.0.0
[root@taotao redis]# 


6、启动 redis
	前端启动 /opt/redis/redis/bin  redis-server           --默认时前端启动模式，端口时6379
	
	后端启动需要配置  redis.conf
	cp /opt/redis/redis-3.0.0/redis.conf /opt/redis/redis/bin
	修改如下两行
	37 daemonize yes
	45 port 6379
	
启动命令
[root@taotao bin]# ./redis-server redis.conf
查看进程
[root@taotao bin]# ps aux | grep redis
root       4455  0.0  0.7 140892  7424 ?        Ssl  08:57   0:00 ./redis-server *:6379
root       4484  0.0  0.0 112708   988 pts/0    R+   08:57   0:00 grep --color=auto redis
[root@taotao bin]# 

7、常用命令
[root@taotao bin]# ./redis-cli 
127.0.0.1:6379> set a 100
OK
127.0.0.1:6379> get a
"100"
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> incr a
(integer) 101
127.0.0.1:6379> decr a
(integer) 100
127.0.0.1:6379> del a
(integer) 1
127.0.0.1:6379> keys *
(empty list or set)
127.0.0.1:6379> 

8、支持的数据类型
String Hash List Set SortedSet



redis集群

	集群内部各个节点彼此互联，连接哪一个节点都可以，如果有超过半数的节点认为某个节点挂了，则这个集群就挂了。
	redis-cluster 把所有的物理节点映射到[0-16383] slot 上， cluster 负责维护
	集群中最少有三个节点，每个节点有一主一备。
	
搭建一个伪分布式集群，使用六个 redis 实例来模拟

redis集群管理工具 redis-trib 宜兰 ruby 环境，首先要安装 ruby 环境
yum install ruby
yum install rubygems

管理工具目录
[root@taotao src]# ll *.rb
-rwxrwxr-x 1 root root 48141 Apr  1  2015 redis-trib.rb
[root@taotao src]# pwd
/opt/redis/redis-3.0.0/src

该工具需要 ruby 包
[root@taotao ~]# ll
-rw-r--r-- 1 root root     57856 Jul 27 11:08 redis-3.0.0.gem

安装：
[root@taotao ~]# gem install redis-3.0.0.gem 


1、创建一个集群目录
[root@taotao redis]# ll
total 0
drwxr-xr-x 3 root root  17 Aug 30 09:44 redis
drwxrwxr-x 6 root root 306 Aug 30 09:43 redis-3.0.0
drwxr-xr-x 8 root root 145 Aug 31 08:25 redis-cluster

2、拷贝 redis/bin 目录到 redis-cluster 下，并重命名为 redis01
[root@taotao opt]# cp -r /opt/redis/redis/bin/ /opt/redis/redis-cluster/redis01

3、将 redis01 拷贝成六份
[root@taotao redis-cluster]# ll
total 52
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis01
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis02
drwxr-xr-x 2 root root   187 Aug 31 08:52 redis03
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis04
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis05
drwxr-xr-x 2 root root   187 Aug 31 08:40 redis06

4、修改每一个目录下 redis.conf 文件里的端口号， 从 7001-7006， 同时去掉  cluster-enabled yes 前面的注释

5、写一个脚本，有后端启动的方式启动这六个 redis 实例
[root@taotao redis-cluster]# ll
total 52
drwxr-xr-x 2 root root   187 Aug 31 09:30 redis01
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis02
drwxr-xr-x 2 root root   187 Aug 31 08:52 redis03
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis04
drwxr-xr-x 2 root root   187 Aug 31 08:37 redis05
drwxr-xr-x 2 root root   187 Aug 31 08:40 redis06
-rwxr-xr-x 1 root root 48141 Aug 31 08:20 redis-trib.rb
-rwx------ 1 root root   258 Aug 31 08:25 start-rediscluser.sh
[root@taotao redis-cluster]# cat start-rediscluser.sh
cd redis01
./redis-server redis.conf
cd ..
cd redis02
./redis-server redis.conf
cd ..
cd redis03
./redis-server redis.conf
cd ..
cd redis04
./redis-server redis.conf
cd ..
cd redis05
./redis-server redis.conf
cd ..
cd redis06
./redis-server redis.conf
cd ..

6、执行创建集群命令：
./redis-trib.rb create --replicas 1 192.168.235.20:7001 192.168.235.20:7002 192.168.235.20:7003 192.168.235.20:7004 192.168.235.20:7005  192.168.235.20:7006

部分信息
Using 3 masters:
192.168.235.20:7001
192.168.235.20:7002
192.168.235.20:7003                                                           --三个主节点
Adding replica 192.168.235.20:7004 to 192.168.235.20:7001
Adding replica 192.168.235.20:7005 to 192.168.235.20:7002
Adding replica 192.168.235.20:7006 to 192.168.235.20:7003
M: 576f1a4af66bb4b193674898ed9a8353c98f7ccc 192.168.235.20:7001
   slots:0-5460 (5461 slots) master
M: 80b571e74659c8d047abb225b85dab9a53eaeb4e 192.168.235.20:7002
   slots:5461-10922 (5462 slots) master
M: 9e365b937bd722bcf94074fb65bc40c4d61ddf1a 192.168.235.20:7003
   slots:10923-16383 (5461 slots) master                                       --主节点的槽信息分配
S: a28e91fd1785f19e66ff2f02c55c212de22ac5eb 192.168.235.20:7004
   replicates 576f1a4af66bb4b193674898ed9a8353c98f7ccc
S: 0034329530f0a346b436c4281d8fe2c061472a48 192.168.235.20:7005
   replicates 80b571e74659c8d047abb225b85dab9a53eaeb4e
S: 85ec9f19472c466c3b0c19ddbd81bbf0f22e198f 192.168.235.20:7006
   replicates 9e365b937bd722bcf94074fb65bc40c4d61ddf1a
Can I set the above configuration? (type 'yes' to accept): yes                  --yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join......
>>> Performing Cluster Check (using node 192.168.235.20:7001)
M: 576f1a4af66bb4b193674898ed9a8353c98f7ccc 192.168.235.20:7001
   slots:0-5460 (5461 slots) master
M: 80b571e74659c8d047abb225b85dab9a53eaeb4e 192.168.235.20:7002
   slots:5461-10922 (5462 slots) master
M: 9e365b937bd722bcf94074fb65bc40c4d61ddf1a 192.168.235.20:7003
   slots:10923-16383 (5461 slots) master
M: a28e91fd1785f19e66ff2f02c55c212de22ac5eb 192.168.235.20:7004
   slots: (0 slots) master
   replicates 576f1a4af66bb4b193674898ed9a8353c98f7ccc
M: 0034329530f0a346b436c4281d8fe2c061472a48 192.168.235.20:7005
   slots: (0 slots) master
   replicates 80b571e74659c8d047abb225b85dab9a53eaeb4e
M: 85ec9f19472c466c3b0c19ddbd81bbf0f22e198f 192.168.235.20:7006
   slots: (0 slots) master
   replicates 9e365b937bd722bcf94074fb65bc40c4d61ddf1a
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.


7、测试集群
[root@taotao redis-cluster]# redis01/redis-cli -h 192.168.235.20 -p 7001 -c
192.168.235.20:7001> set a 100
-> Redirected to slot [15495] located at 192.168.235.20:7003
OK
192.168.235.20:7003> get a
"100"
192.168.235.20:7003> 


8、关闭命令

单机版关闭命令
[root@taotao bin]# ./redis-cli 
127.0.0.1:6379> shutdown                     --shutdown
not connected> 
[root@taotao bin]# 

集群版关闭命令
[root@taotao redis-cluster]# cat stop-rediscluster.sh 
redis01/redis-cli -p 7001 shutdown
redis02/redis-cli -p 7002 shutdown
redis03/redis-cli -p 7003 shutdown
redis04/redis-cli -p 7004 shutdown
redis05/redis-cli -p 7005 shutdown
redis06/redis-cli -p 7006 shutdown
