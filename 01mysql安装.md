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
name: mysql8
services: 
  mysql: 
    container_name: mysql
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=root
      - TZ=Asia/Shanghai
    volumes:
      - mysql-data:/var/lib/mysql
      - /app/myconf:/etc/mysql/conf.d
    restart: always
volumes:
  mysql-data:
```

