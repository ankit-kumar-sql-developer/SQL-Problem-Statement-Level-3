-- to find median salary for each company

-- 2 5 7  8 9 -->7
-- 2 5 6 7 8 9 --> avg of 7,8

create table #employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into #employee values (1,'A',2341)
insert into #employee values (2,'A',341)
insert into #employee values (3,'A',15)
insert into #employee values (4,'A',15314)
insert into #employee values (5,'A',451)
insert into #employee values (6,'A',513)
insert into #employee values (7,'B',15)
insert into #employee values (8,'B',13)
insert into #employee values (9,'B',1154)
insert into #employee values (10,'B',1345)
insert into #employee values (11,'B',1221)
insert into #employee values (12,'B',234)
insert into #employee values (13,'C',2345)
insert into #employee values (14,'C',2645)
insert into #employee values (15,'C',2645)
insert into #employee values (16,'C',2652)
insert into #employee values (17,'C',65);

select * from #employee

--
select company,AVG(salary) --1.0*cnt/2,1.0*cnt/2+1
from (
select *,
ROW_NUMBER () over (partition by company order by salary) as rn,
COUNT(1) over (partition by company) as cnt
from #employee) a 
where rn between 1.0*cnt/2 and 1.0*cnt/2+1
group by company


--

;with cte as ( select * , row_number() over(partition by company order by salary desc) as rank  ,
 row_number() over(partition by company order by salary asc) as rank1
from #employee )

select   distinct company ,
sum(salary) over(partition by company)/2 from cte where rank-rank1= 1 or  rank-rank1= -1

--
select distinct company,avg(salary) over (partition by company) as 'Median' from(
select * ,  row_number() over (partition by company order by salary asc) as r_asc , 
row_number() over (partition by company order by salary desc) as r_desc from #employee) t
where r_asc in (r_desc, r_desc-1, r_desc+1)

--

with employee_with_rownum as (
select 
		*,
		row_number() over(partition by company order by salary) as row_num
	from 
		employee
),
-- Companies having even number of employees
salary_med_with_even as (select 
	er.company,
	AVG(er.salary * 1.0) as salary
from
	employee_with_rownum er 
inner join
	(
	select 
		company,
		count(*)/2 + 1 as median_posn
	from
		employee e
	group by
		company
	having 
		count(*) % 2 = 0
	) m
on
	(er.row_num = m.median_posn OR er.row_num = m.median_posn - 1) AND
	er.company = m.company
group by
	er.company),

salary_med_with_odd as (
-- Companies having odd number of employees
select 
	er.company,
	er.salary
from
	employee_with_rownum er 
inner join
	(
	select 
		company,
		count(*)/2 + 1 as median_posn
	from
		employee e
	group by
		company
	having 
		count(*) % 2 <> 0
	) m
on
	er.row_num = m.median_posn AND
	er.company = m.company)
	
select * from salary_med_with_even
union all
select * from salary_med_with_odd