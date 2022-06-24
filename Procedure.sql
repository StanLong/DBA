-- 查询存储过程
show procedure status

--mysql中创建数据库
CREATE DATABASE IF NOT EXISTS scott default charset utf8 COLLATE utf8_general_ci

--mysql 存储过程：
语法结构：
delimiter $                                           --声明存储过程的结束符， 这里声明 $ 为该存储过程的结束符
create procedure pro_test()                           --存储过程名称(参数列表)
begin                                                 --开始
    sql语句                                           --sql 语句 + 流程
end $                                                 --结束 结束符。 这里的结束符要和开关声明的结束符一样

执行存储过程
call pro_test();                                      --调用存储过程

参数
IN:    表示输入参数
OUT:   表示输出参数
INOUT: 表示输入输出参数

--带有输入功能的存储过程
delimiter $
create procedure pro_findbyId(IN eno int(10))
begin
    select * from emp where empno = eno;
end $

call pro_findbyId(7369)

scott@root>call pro_findbyId(7369);
+-------+-------+-------+------+------------+--------+------+--------+
| empno | ename | job   | mgr  | hiredate   | sal    | comm | deptno |
+-------+-------+-------+------+------------+--------+------+--------+
|  7369 | SMITH | CLERK | 7902 | 1980-12-17 | 800.00 | NULL |     20 |
+-------+-------+-------+------+------------+--------+------+--------+
1 row in set (0.00 sec)

--mysql 变量
    --全局变量（内置变量）  --所有连接都起作用
        --查看所有全局变量
            show variables
            --常用的全局变量
            show variables like 'character_%'
            scott@root>show variables like 'character_%';
            +--------------------------+----------------------------------------+
            | Variable_name            | Value                                  |
            +--------------------------+----------------------------------------+
            | character_set_client     | gbk                                    |     --服务器接收数据的编码
            | character_set_connection | gbk                                    |
            | character_set_database   | utf8                                   |
            | character_set_filesystem | binary                                 |
            | character_set_results    | gbk                                    |     --服务器输出数据编码
            | character_set_server     | latin1                                 |
            | character_set_system     | utf8                                   |
            | character_sets_dir       | D:\Program Files\MySql\share\charsets\ |
            +--------------------------+----------------------------------------+
            8 rows in set (0.00 sec)
            
        --查看某个全局变量
            select @@ 变量名
            scott@root>select @@character_set_client;
            +------------------------+
            | @@character_set_client |
            +------------------------+
            | gbk                    |
            +------------------------+
            1 row in set (0.00 sec)
            
    --会话变量；只存在于当前客户端与数据库服务器连接当中，如果连接断开，那会话变量会全部丢失
        --定义一个会话变量
            set @name = 'stanlong'
        --查看会话变量
            select @name
        
    --局部变量： 所有在存储过程中使用的变量都是局部变量，只要存储过程结束，局部变量丢失
   
--带有输出功能的存储过程
delimiter $
create procedure pro_testOut(OUT str varchar(20))
begin
    set str = '这是一个输出参数';
end $

call pro_testOut(@name)

select @name

--删除存储过程
drop procedure 存储过程名称


--带有输入输出功能的存储过程
delimiter $
create procedure pro_testInOut(INOUT n INT)
begin
    select n;
    set n = 500;
end $

set @n = 10;

call pro_testInOut(@n);

select @n

--带有条件判断的存储过程
--需求：输入1则返回星期一，输入2则返回星期二，输入3则返回星期3，如果是其他则返回输入错误
delimiter $
create procedure pro_testIf(IN num INT, OUT str VARCHAR(20))
begin
    IF num = 1 
        THEN set str = '星期一';
    ELSEIF num = 2 
        THEN set str = '星期二';
    ELSEIF num = 3 
        THEN set str = '星期三';
    ELSE set str = '输入错误';
    END IF;
end $

call pro_testIf(1,@str);

select @str;

--带有循环的存储过程
--需求：求1到100的和
delimiter $
create procedure pro_testWhile(IN num INT, OUT result_sum INT)
begin
    DECLARE i INT DEFAULT 1;
    DECLARE v_sum INT DEFAULT 0;
    WHILE i <= num  DO
        set v_sum = v_sum + i;
        set i = i+1;
    END WHILE;
    set result_sum = v_sum;
end $

call pro_testWhile(100, @result_sum);

select @result_sum;


--使用查询结果作为返回值

delimiter $
create procedure pro_findByEno(IN eno int(10), OUT v_ename varchar(20))
begin
    SELECT ename INTO v_ename from emp where empno = eno;
end $

call pro_testByEno(7369, @ename);

select @ename;
