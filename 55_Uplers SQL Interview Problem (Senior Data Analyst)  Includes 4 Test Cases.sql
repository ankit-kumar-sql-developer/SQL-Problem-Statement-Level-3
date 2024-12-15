
drop table if exists #candidates
Create table #candidates(
id int primary key,
positions varchar(10) not null,
salary int not null);

-- test case 1:
insert into #candidates values(1,'junior',5000);
insert into #candidates values(2,'junior',7000);
insert into #candidates values(3,'junior',7000);
insert into #candidates values(4,'senior',10000);
insert into #candidates values(5,'senior',30000);
insert into #candidates values(6,'senior',20000);

--
; with running_cte as (
select *, 
SUM(salary) over (Partition by positions order by salary asc,id) as running_sal
from  #candidates )
, senior as (
select COUNT(*) as senior,SUM(salary) as salary from running_cte 
where positions='senior' and running_sal <=50000 )
, junior as (
select COUNT(*) as junior from running_cte 
where positions='Junior' and 
running_sal <= 50000 - ( select SUM(salary) from senior) )
select senior,junior from senior,junior



--test case 2:
drop table if exists #candidates
Create table #candidates(
id int primary key,
positions varchar(10) not null,
salary int not null);

insert into #candidates values(20,'junior',10000);
insert into #candidates values(30,'senior',15000);
insert into #candidates values(40,'senior',30000);

--

; with running_cte as (
select *, 
SUM(salary) over (Partition by positions order by salary asc,id) as running_sal
from  #candidates )
, senior as (
select COUNT(*) as senior,SUM(salary) as salary from running_cte 
where positions='senior' and running_sal <=50000 )
, junior as (
select COUNT(*) as junior from running_cte 
where positions='Junior' and 
running_sal <= 50000 - ( select SUM(salary) from senior) )
select senior,junior from senior,junior




--test case 3:
drop table if exists #candidates
Create table #candidates(
id int primary key,
positions varchar(10) not null,
salary int not null);

insert into #candidates values(1,'junior',15000);
insert into #candidates values(2,'junior',15000);
insert into #candidates values(3,'junior',20000);
insert into #candidates values(4,'senior',60000);

--

; with running_cte as (
select *, 
SUM(salary) over (Partition by positions order by salary asc,id) as running_sal
from  #candidates )
, senior as (
select COUNT(*) as senior,coalesce(SUM(salary),0) as salary from running_cte 
where positions='senior' and running_sal <=50000 )
, junior as (
select COUNT(*) as junior from running_cte 
where positions='Junior' and 
running_sal <= 50000 - ( select SUM(salary) from senior) )
select senior,junior from senior,junior




--test case 4:
drop table if exists #candidates
Create table #candidates(
id int primary key,
positions varchar(10) not null,
salary int not null);

insert into #candidates values(10,'junior',10000);
insert into #candidates values(40,'junior',10000);
insert into #candidates values(20,'senior',15000);
insert into #candidates values(30,'senior',30000);
insert into #candidates values(50,'senior',15000);

--

select * from #candidates

 ;with running_cte as (
select *, 
SUM(salary) over (Partition by positions order by salary asc,id) as running_sal
from  #candidates )
, senior as (
select COUNT(*) as senior,coalesce(SUM(salary),0) as salary from running_cte 
where positions='senior' and running_sal <=50000 )
, junior as (
select COUNT(*) as junior from running_cte 
where positions='Junior' and 
running_sal <= 50000 - ( select SUM(salary) from senior) )
select senior,junior from senior,junior


--***********************************************--

with cte as(
select *,
sum(salary) over(partition by positions order by salary asc) as cumulative
from Emple),cte1 as
(select *from cte where positions in('senior','junior') and cumulative<=50000 )
select sum(case when positions='senior' then 1 else 0 end) as senior, sum(case when positions='junior' then 1 else 0 end) as junior 
from cte1