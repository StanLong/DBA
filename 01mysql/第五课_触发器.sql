触发器（trigger）是一个特殊的存储过程,它的执行不是由程序调用，也不是手工启动的。而是由事件来触发。


语法：
create table 触发器名称 BEFORE|AFTER 触发事件 ON 表名称 FOR EACH ROW
BEGIN
    触发器程序体
END

<触发器名称>               最多64个字符，它和mysql中其他对象的命名方式一样
{BEFORE|AFTER}             触发器时机
{INSERT|UPDATE|DELETE}     触发事件
ON <表名称>                标识建立触发器的表名，即在哪张表上建立触发器
FOR EACH ROW               触发器的执行间隔 FOR EACH ROW子名通知触发器，每隔一行执行一次动作。而不是对每个表执行一次





操作实例
建表
create table student(
    id int unsigned auto_increment primary key,
    name varchar(50)
);

create table student_total(
    total int
);

insert into student_total values(0);

创建触发器

\d $$
create trigger student_insert_trigger after insert on student for each row
begin
    update student_total set total=total+1;
end $$

\d $$
create trigger student_delete_trigger after delete on student for each row
begin
    update student_total set total=total-1;
end $$

查看触发器
show triggers;

验证触发器
insert into student(name) values('stanlong');
insert into student(name) values('zhangsan'), ('lisi'),('wangwu') ;

select total from student_total;
mysql> select total from student_total;
+-------+
| total |
+-------+
|     4 |
+-------+

delete from student;
mysql> select total from student_total;
+-------+
| total |
+-------+
|     0 |
+-------+


印刷品案例
建表：
DROP TABLE IF EXISTS tab1;
create table tab1(
    id int primary key auto_increment,
    name varchar(50),
    sex enum('f', 'm'),
    age int
);

drop table if exists tab2;
create table tab2(
    id int primary key auto_increment,
    name varchar(50),
    salary double(10,w)
);

创建触发器
触发器1：当tab1表中删除一条记录的同时，tab2表也删除一条记录
delimiter $$
create trigger tab1_after_delete_triger
after delete on tab1 for each row
begin
    delete from tab2 where name = old.name;         --删除一定要根据主键删除
end$$

触发器2: 当 tab1更新后, tab2自动更新
delimiter $$
create trigger tab1_after_insert_triger
after insert on tab1 for each row
begin
    update tab2 set name = new.name where name = old.name;  --更新也一定要根据主键更新
    
end $$

触发器3: 当 tab1增加记录后, tab2自动增加记录
delimiter $$
create trigger tab1_after_insert_triger
after insert on tab1 for each row
begin
    insert into tab2(name, salary) values(new.name, new.salary);
end $$


测试：
insert into tab1(name, sex, age) values("zhangsan", 'm', 18);

预计 tab2 的结果：
mysql> select * from tab2;
+----+----------+---------+
| id | name     | salary  |
+----+----------+---------+
|  1 | zhangsan | 5000.00 |
+----+----------+---------+
结果符合预计。


update tab1 set name="lisi" where name="zhangsan";
mysql> select * from tab2;
+----+------+---------+
| id | name | salary  |
+----+------+---------+
|  1 | lisi | 5000.00 |
+----+------+---------+
1 row in set (0.00 sec)



delete from tab1 where name="lisi";
mysql> select * from tab2;
Empty set (0.00 sec)