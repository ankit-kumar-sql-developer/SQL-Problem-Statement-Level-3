
create table #emp(
emp_id int,
emp_name varchar(20),
department_id int,
salary int,
manager_id int,
emp_age int);

insert into #emp
values
(1, 'Ankit', 100,10000, 4, 39);
insert into #emp
values (2, 'Mohit', 100, 15000, 5, 48);
insert into #emp
values (3, 'Vikas', 100, 10000,4,37);
insert into #emp
values (4, 'Rohit', 100, 5000, 2, 16);
insert into #emp
values (5, 'Mudit', 200, 12000, 6,55);
insert into #emp
values (6, 'Agam', 200, 12000,2, 14);
insert into #emp
values (7, 'Sanjay', 200, 9000, 2,13);
insert into #emp
values (8, 'Ashish', 200,5000,2,12);
insert into #emp
values (9, 'Mukesh',300,6000,6,51);
insert into #emp
values (10, 'Rakesh',300,7000,6,50);

select * from #emp
--
; with cte as (
select department_id, AVG(salary) as avg_salary, count(*) as no_of_emp,
SUM(salary) as dep_salary
from #emp group  by department_id )
select * from (
select e1.department_id,e1.avg_salary,--e2.department_id,,e2.dep_salary
SUM(e2.dep_salary)/sum(e2.no_of_emp) as total_salary, sum(e2.no_of_emp) as cnt
from cte  e1 
inner join cte e2 on e1.department_id<> e2.department_id
group by e1.department_id,e1.avg_salary ) t
where total_salary > avg_salary

--
select department_id,avg(salary) as dept_sal
from #emp e
group by department_id
having avg(salary) < (select avg(salary) from #emp f where f.department_id not in (e.department_id))

-- without self-join-
select distinct department_id, dept_salary from (
select *,
count(*) over() as total_count,
count(*) over(partition by department_id) as dept_count,
sum(salary) over() as tot_salary,
sum(salary) over(partition by department_id) as dept_salary,
avg(salary) over(partition by department_id) as dept_avg_salary from emp) as t
where dept_avg_salary<(tot_salary-dept_salary)/(total_count-dept_count)

--
-- CO REALATED
with cte1 as (select * from #emp)
,cte2 as
(select department_id,avg(salary) over(partition by department_id) dep_avg,
(select avg(salary) from cte1 where department_id<>#emp.department_id) av
from #emp)
select distinct department_id department_id from cte2 where dep_avg<av

--
select department_id, avg(salary) as dept_avg,
((select sum(salary) from emp)-sum(salary)) div
((select count(1) from emp)-count(1)) as remaining_avg
from emp group by department_id having dept_avg<=remaining_avg;

--
select

 distinct department_id
from
(
select
    emp_1.department_id as department_id,
    avg(emp_1.salary) over(partition by emp_1.department_id) as department_avg_salary,
    avg(emp_2.salary) over(partition by emp_1.department_id) as avg_salary
from emp emp_1 cross join emp emp_2 
where  emp_1.department_id != emp_2.department_id 
)a 
where department_avg_salary < avg_salary

-- VI

with cte as 
(
Select department_id, SUM(salary) as dept_sum, AVG(salary) as dept_avg, 
count(department_id) as dept_count, (Select SUM(salary) from #emp) as total_sum,
(select COUNT(department_id) from #emp) as total_count
from #emp
group by department_id
)
Select * from 
(Select department_id, dept_avg, (total_sum - dept_sum)/(total_count-dept_count) as company_avg
from cte)A
where dept_avg<company_avg

--

( select department_id as d, avg(salary) as sal from emp group by department_id)
 , t2 as
 ( select t1.d, ((Avg(t1.sal) over(ORDER BY t1.d
    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)) + (Avg(t1.sal) over(ORDER BY t1.d
    ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING))/2) as comp_avg from t1)
  select t2.d from t2 where sal<comp_avg

--
with cte as (
select emp_id,emp_name,department_id, salary  from emps
),
(
select b.department_id,avg(b.salary) as avg_emp_sal,
avg (case when a.department_id != b.department_id then a.salary end)as avg_company_sal
from cte a join cte b on 
a.department_id<>b.department_id
group by b.department_id
)

--