# mysql 安装

## 一、windows 安装

### 1、二进制包安装

https://blog.csdn.net/m0_62808124/article/details/126769669

## 二、linux安装

### 1、使用mysql的yum源安装

见 mysql/01mysql安装.md

## 三、docker安装

### 1、 docker

```shell
docker run -d -p 3306:3306 \
> -v /app/myconf:/etc/mysql/conf.d \
> -v /app/mydata:/var/lib/mysql \
> -e MYSQL_ROOT_PASSWORD=root \
> mysql:8.0
```

### 2、 docker compose

```yaml
version: '3.8'
services:
  mysql84:
    image: mysql:8.4
    container_name: mysql84
    restart: always
    environment:
      # root账号密码自行修改
      MYSQL_ROOT_PASSWORD: "root"
      # 时区统一东八区
      TZ: Asia/Shanghai
    ports:
      - "3306:3306"
    volumes:
      # 1. 数据持久化目录（核心，存放所有库表数据）
      - ./mysql/data:/var/lib/mysql
      # 2. 配置文件目录，自定义my.cnf
      - ./mysql/conf:/etc/mysql/conf.d
      # 3. 日志挂载：错误日志、慢查询、二进制日志
      - ./mysql/log:/var/log/mysql
    command:
      # 启动参数优化，utf8mb4全支持
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --default-time-zone=+8:00
      --lower_case_table_names=1
    networks:
      mysql-net:

# 自定义网络，容器互通隔离
networks:
  mysql-net:
    driver: bridge
```

