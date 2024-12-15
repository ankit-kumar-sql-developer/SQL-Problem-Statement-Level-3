
--wrxte an sql to find details of employees With 3rd highest salary xn each department.
--in case there are 1 then 3 employees in a department then return employee details with lowest salary in that dep.

CREATE TABLE #emp(
 [emp_id] [int] NULL,
 [emp_name] [varchar](50) NULL,
 [salary] [int] NULL,
 [manager_id] [int] NULL,
 [emp_age] [int] NULL,
 [dep_id] [int] NULL,
 [dep_name] [varchar](20) NULL,
 [gender] [varchar](10) NULL
) ;
insert into #emp values(1,'Ankit',14300,4,39,100,'Analytics','Female')
insert into #emp values(2,'Mohit',14000,5,48,200,'IT','Male')
insert into #emp values(3,'Vikas',12100,4,37,100,'Analytics','Female')
insert into #emp values(4,'Rohit',7260,2,16,100,'Analytics','Female')
insert into #emp values(5,'Mudit',15000,6,55,200,'IT','Male')
insert into #emp values(6,'Agam',15600,2,14,200,'IT','Male')
insert into #emp values(7,'Sanjay',12000,2,13,200,'IT','Male')
insert into #emp values(8,'Ashish',7200,2,12,200,'IT','Male')
insert into #emp values(9,'Mukesh',7000,6,51,300,'HR','Male')
insert into #emp values(10,'Rakesh',8000,6,50,300,'HR','Male')
insert into #emp values(11,'Akhil',4000,1,31,500,'Ops','Male')


select * from #emp

--
; with cte as (
select *,
RANK() over (partition by dep_id order by salary desc) as rn,
count(1) over (partition by dep_id) as cnt
from #emp )

select * from cte
where rn=3  or (cnt<3 and rn=cnt)

--
WITH cte as (
select *
, DENSE_RANK() over(partition by dep_id order by salary DESC) as RNK
from #emp )
, cte1 as (
select *
, MIN(salary)over(partition by dep_id ) as MINSAL
from cte
where RNK <= 3 )

select *
from cte1
where salary = MINSAL

--

with temp_table as (
select emp_name,dep_name,salary,DENSE_RANK() over (partition by dep_name order by salary desc) as rank_order from #emp
),temp_table2 as
( select emp_name,dep_name,salary,rank_order,DENSE_RANK() over (partition by dep_name order by rank_order desc) as real_rank_order from temp_table where rank_order <= 3
)
select * from temp_table2 where real_rank_order = 1


--

with cte1 as(
select emp_id,emp_name,salary,dep_id,dep_name,DENSE_RANK() OVER(partition by dep_id order by salary desc) rnk from emp
)
select emp_id,emp_name,salary,dep_id,dep_name from cte1 where rnk=3
UNION ALL
select min(emp_id),min(emp_name),min(salary),dep_id,min(dep_name) from cte1 group by dep_id having count(emp_id)<3

--

with departments as(
  select distinct dep_id, dep_name from emp
), cte as(
	select e.*,d.* from 
	departments d
	cross apply ( 
		select top 3
			emp_id, emp_name, salary
		from emp e
		where e.dep_id = d.dep_id
		order by e.salary desc
	) e
)

select e.*,d.* from 
departments d
cross apply (
	select top 1
  		emp_id, emp_name, salary
  	from cte e
  	where e.dep_id = d.dep_id
  	order by e.salary
) e

--