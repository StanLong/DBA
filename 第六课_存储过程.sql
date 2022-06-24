函数必须有返回值，而存储过程没有
存储过程的参数可以是IN, OUT, INOUT类型， 函数的参数只能是IN

---------------------------------------------------------------------------
语法格式：
delimiter $$
create procedure 过程名（形式参数列表）
begin
    sql语句
end $$
delimiter;

三种参数类型
1、无参
delimiter $$
create procedure p1()
begin
    select count(*) from mysql.user;
end $$

调用
call p1();
--------------------------------------------------------------------------------
delimiter $$
create procedure autoinsert_t11()
begin
    declare i int default 1;
    while(i<=20) do
        insert into t11(id, password) values(i, md5(i));
        set i = i+1;
    end while;
end $$

call autoinsert_t11();
--------------------------------------------------------------------------------
2、输入变量

delimiter $$
create procedure autoinsert_t22(IN a int)
begin
    declare i int default 1;
    while(i <= a) do
        insert into t22(id, password) values(i, md5(i));
        set i = i+1;
    end while;
end $$

call autoinsert_t22(40);

--------------------------------------------------------------------------------
mysql 定义变量

set @num=50;
select @num;
mysql> set @num=50;
Query OK, 0 rows affected (0.01 sec)

mysql> select @num;
+------+
| @num |
+------+
|   50 |
+------+
1 row in set (0.01 sec)

存储过程调用变量

call autoinsert_t22(@num);
--------------------------------------------------------------------------------
3、输出变量 OUT

delimiter $$
create procedure p2(OUT result INT)
begin
    select count(*) into result from mysql.user;
end $$

获取输出变量的结果
call p2(@result);
select @result;
mysql> call p2(@result);
Query OK, 1 row affected (0.00 sec)

mysql> select @result;
+---------+
| @result |
+---------+
|       4 |
+---------+
1 row in set (0.00 sec)

--------------------------------------------------------------------------------
IN 和 OUT 配合使用
delimiter $$
create procedure count_num(IN p1 varchar(50), OUT p2 int) 
begin
    select count(*) into p2 from emp where deptno = p1;
end $$

调用
call count_num(20, @p2);
select @p2;

mysql> select @p2;
+------+
| @p2  |
+------+
|    5 |
+------+

---------------------------------------------------------------------------------------
4、输入输出变量 INOUT

delimiter $$
create procedure p4_inout(INOUT p1 INT)
BEGIN 
    if (p1 is not null) then
        set p1 = p1+1;
    else
        set p1 = 100;
    end if;
end $$


调用
set @p1 = 10;
call p4_inout(@p1);
select @p1;

mysql> select @p1;
+------+
| @p1  |
+------+
|   11 |
+------+
1 row in set (0.00 sec)


---------------------------------------------------------------------------------------
delimiter $$
create procedure count_inout(IN p1 VARCHAR(50), IN p2 float(10,2), OUT p3 INT)
begin
    select count(*) into p3 from emp where deptno = p1 and sal >= p2;
end $$


调用
call count_inout(10, 1000, @p3)
select @p3;


---------------------------------------------------------------------------------------

function 函数

create function hello(s char(30))
returns char(100)                      --定义返回的类型
return concat('hello', s, '!');

调用
select hello('zhangsan');

---------------------------------------------------------------------------------------

delimiter $$
create function name_from_emp(x int)
returns varchar(50)
begin
    return (select ename from emp where deptno = x); ---返回的是多行， 这样写在调用的时候会报错
end $$

select name_from_emp(10);

