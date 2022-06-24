索引在mysql中也叫做键，是存储引擎用于快速找到记录的一种数据结构。索引对于良好的性能十分关键。尤其是当表中的数据量越来越大的时候。索引对于性能的影响愈发重要。
索引优化应该是对查询性能优化最有效的手段了。索引能够难易将查询性能提高好几个量级。

索引的分类
    普通索引
    唯一索引
    全文索引
    单列索引
    多列索引
    空间索引
    

--准备表：
create table test_index
(   
    id int
   ,name varchar(50)
);



--创建存储过程，实现批量插入记录
delimiter $$
create procedure autoinsert()
BEGIN
declare i int default 1;
while (i<200000) do
    insert into test_index values(i, 'test_index');
    set i=i+1;
end while;
END $$



--调用存储过程
call autoinsert();



--存储过程进程死循环的处理方法
--1、查看连接着的会话，有点像linux里的w：
show processlist;

--2、从中找到call存储过程的那个id，kill之：
kill id号;

--3、删除数据
truncate table 表名



--创建索引
create index id_index on test_index(id);
mysql> desc test_index;
+-------+-------------+------+-----+---------+-------+
| Field | Type        | Null | Key | Default | Extra |
+-------+-------------+------+-----+---------+-------+
| id    | int(11)     | YES  | MUL | NULL    |       |
| name  | varchar(50) | YES  |     | NULL    |       |
+-------+-------------+------+-----+---------+-------+
2 rows in set (0.03 sec)



--测试索引
--未加索引的查询语句
mysql> explain select * from test_index where id = 190000\G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: test_index
         type: ALL
possible_keys: NULL  --没有使用索引
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 199780
        Extra: Using where
1 row in set (0.00 sec)

ERROR:
No query specified




--使用索引的查询语句
mysql> explain select * from test_index where id = 190000\G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: test_index
         type: ref
possible_keys: id_index --可以使用的索引 possible_keys：查询优化器
          key: id_index 
      key_len: 5
          ref: const
         rows: 1       
        Extra: NULL
1 row in set (0.00 sec)

ERROR:
No query specified

--删除索引
drop index 索引名 on 表名
drop index id_index on test_index
