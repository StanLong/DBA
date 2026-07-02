# Doris

# 一、简介

Apache Doris 由百度大数据部研发（之前叫百度 Palo，2018年贡献到 Apache 社区后， 更名为 Doris ），在百度内部，有超过200个产品线在使用，部署机器超过1000台，单一业务最大可达到上百 TB

# 二、环境配置

本环境采用单机部署，doris版本 doris-3.0.8， fe和be都安装在node01上

## 1、修改系统最大打开文件句柄数

通过以下命令可以调整最大文件句柄数。在调整后，需要重启会话以生效配置：

```shell
vi /etc/security/limits.conf 
* soft nofile 655350
* hard nofile 655350

---------------------------------------------


```

## 2、修改虚拟内存区域

通过以下命令可以永久修改虚拟内存区域至少为 2000000，并立即生效：

```bash
cat >> /etc/sysctl.conf << EOF
vm.max_map_count = 2000000
EOF

# 应用更改
sudo sysctl -p

## 检查
cat /proc/sys/vm/max_map_count

------------------------------------------------------------
# 或者直接执行命令
sysctl -w vm.max_map_count=2000000
```

## 3、配置环境变量

```shell
vim .bashrc

#设置DORIS环境变量
export DORIS_HOME=/opt/doris-3.0.8
export PATH=$PATH:$DORIS_HOME/fe/bin:$DORIS_HOME/be/bin

# 使配置生效
source .bashrc
```

# 三、安装doris

## 1、FE

1. 编辑 FE 配置文件 /opt/doris-3.0.8/fe/conf/fe.conf，修改以下参数：

   ```properties
   ## 指定 Java 环境
   JAVA_HOME=/usr/lib/jvm/jdk-1.8.0_421-oracle-x64
   
   # 配置 FE 的元数据目录
   meta_dir=/data/doris/doris-meta
   
   # 指定 FE 监听 IP 的 CIDR 网段
   priority_networks = 192.168.136.11/24
   
   # 单节点部署时需要加上这个配置，设置默认副本数为1（默认是3），测试环境采用单机部署
   default_replication_num = 1
   ```

2. 启动 FE

   执行 start_fe.sh 脚本启动 FE 进程：

   ```shell
   start_fe.sh --daemon
   ```

3. 检查 FE 状态

   使用 MySQL 客户端连接集群，并检查集群状态：

   ```sql
   
   ```

   





### 安装 BE

1. **配置 BE**

   修改 BE 配置文件 `apache-doris/be/conf/be.conf` 的以下内容：

   ```sql
   ## 指定 Java 环境
   JAVA_HOME=/home/doris/jdk
   
   # 指定 FE 监听 IP 的 CIDR 网段
   priority_networks=127.0.0.1/32
   ```

   

2. **启动 BE**

   通过以下命令启动 BE 进程：

   ```sql
   apache-doris/be/bin/start_be.sh --daemon
   ```

   

3. **在集群中注册 BE 节点**

   使用 MySQL 客户端连接 Doris：

   ```sql
   mysql -uroot -P9030 -h127.0.0.1
   ```

   

   使用 ADD BACKEND 命令注册 BE 节点：

   ```sql
   ALTER SYSTEM ADD BACKEND "127.0.0.1:9050";
   ```

   

4. **检查 BE 状态**

   使用 MySQL 客户端连接集群，并检查集群状态：

   ```sql
   ## 检查 BE 状态，确定 Alive 列为 true
   mysql -uroot -P9030 -h127.0.0.1 -e "show backends;"
   +-----------+-----------+---------------+--------+----------+----------+---------------------+---------------------+-------+----------------------+-----------+------------------+--------------------+---------------+---------------+---------+----------------+--------------------+--------------------------+--------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+----------+
   | BackendId | Host      | HeartbeatPort | BePort | HttpPort | BrpcPort | LastStartTime       | LastHeartbeat       | Alive | SystemDecommissioned | TabletNum | DataUsedCapacity | TrashUsedCapcacity | AvailCapacity | TotalCapacity | UsedPct | MaxDiskUsedPct | RemoteUsedCapacity | Tag                      | ErrMsg | Version                 | Status                                                                                                                        | HeartbeatFailureCounter | NodeRole |
   +-----------+-----------+---------------+--------+----------+----------+---------------------+---------------------+-------+----------------------+-----------+------------------+--------------------+---------------+---------------+---------+----------------+--------------------+--------------------------+--------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+----------+
   | 10156     | 127.0.0.1 | 9050          | 9060   | 8040     | 8060     | 2024-07-28 17:59:14 | 2024-07-28 18:08:24 | true  | false                | 14        | 0.000            | 0.000              | 8.342 GB      | 19.560 GB     | 57.35 % | 57.35 %        | 0.000              | {"location" : "default"} |        | doris-2.0.12-2971efd194 | {"lastSuccessReportTabletsTime":"2024-07-28 18:08:14","lastStreamLoadTime":-1,"isQueryDisabled":false,"isLoadDisabled":false} | 0                       | mix      |
   +-----------+-----------+---------------+--------+----------+----------+---------------------+---------------------+-------+----------------------+-----------+------------------+--------------------+---------------+---------------+---------+----------------+--------------------+--------------------------+--------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------+-------------------------+----------+
   ```

   

## 运行查询

1. **使用 MySQL 客户端连接集群**

   ```sql
   mysql -uroot -P9030 -h127.0.0.1
   ```

   

2. **创建数据库与测试表**

   ```sql
   create database demo;
   
   use demo; 
   CREATE TABLE mytable (
       k1 TINYINT,
       k2 DECIMAL(10, 2) DEFAULT "10.05",    
       k3 CHAR(10) COMMENT "string column",    
       k4 INT NOT NULL DEFAULT "1" COMMENT "int column"
   ) 
   COMMENT "my first table"
   DISTRIBUTED BY HASH(k1) BUCKETS 1
   PROPERTIES ( 
       "replication_num" = "1"  -- 手动指定副本数，改为1，匹配可用BE节点数
   );
   ```

   

3. **导入测试数据**

   使用 Insert Into 语句插入测试数据

   ```sql
   insert into mytable values
   (1,0.14,'a1',20),
   (2,1.04,'b2',21),
   (3,3.14,'c3',22),
   (4,4.35,'d4',23);
   ```

   

4. **在 MySQL 客户端中执行以下 SQL 语句可以查看到已导入的数据：**

   ```sql
   MySQL [demo]> select * from demo.mytable;
   +------+------+------+------+
   | k1   | k2   | k3   | k4   |
   +------+------+------+------+
   |    1 | 0.14 | a1   |   20 |
   |    2 | 1.04 | b2   |   21 |
   |    3 | 3.14 | c3   |   22 |
   |    4 | 4.35 | d4   |   23 |
   +------+------+------+------+
   4 rows in set (0.10 sec)
   ```

