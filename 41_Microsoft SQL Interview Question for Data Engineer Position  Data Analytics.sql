
/*A company wants to hire new employees. The budget of the company for the salaries is $70000.	The company's criteria for hiring are:
Keep hiring the senior with the smallest salary until you cannot hire any more seniors.
Use the remaining budget to hire the junior with the smallest salary.
Keep hiring the junior with the smallest salary until you cannot hire any more juniors.
Write an SQL query to find the seniors anp juniors hired under the mentioned criteria.*/

create table #candidates (
emp_id int,
experience varchar(20),
salary int
);
delete from #candidates;
insert into #candidates values
(1,'Junior',10000),(2,'Junior',15000),(3,'Junior',40000),(4,'Senior',16000),(5,'Senior',20000),(6,'Senior',50000);

select * from #candidates

--
; with cte as (
select *,
SUM(salary) over (partition by experience order by salary asc
rows between unbounded preceding and current row) as running_sal
from #candidates )
, senior as (
select * 
from cte 
where experience='Senior' and running_sal < 70000 )

select * from cte 
where experience='Junior' and running_sal < 70000 - 
(select SUM(salary) from senior) 
union all
select * from senior

--

with cte as(
  select emp_id,experience,salary,SUM(salary) over (partition by  experience order by experience desc,salary asc rows between unbounded preceding and current row)-salary AS CUM_SUM FROM CANDIDATES order by experience desc),
  senior_cte as(
  SELECT emp_id,experience,salary,CUM_SUM,(70000-CUM_SUM) as remaining,case when (70000-CUM_SUM)>=salary then 'select' else 'reject' end as status FROM CTE where experience like 'Senior'),
  junior_cte as(
  SELECT emp_id,experience,salary,CUM_SUM,case when experience='Junior' then (select min(remaining) from senior_cte) END -CUM_SUM as remaining,case when (select min(remaining) from senior_cte)-CUM_SUM >=salary then 'select' else 'reject' end as status FROM cte where experience like 'Junior'
  )
  select emp_id,experience,salary from senior_cte where status='select'
  UNION
  select emp_id,experience,salary from junior_cte where status='select'
  order by emp_id

--
with cte as 
	(select *,
	sum(salary) over (partition by experience order by salary) running_sum from candidates),

cte2 as
	(
	select t.*,
	sum(t.salary) over (order by experience desc, t.salary asc) final_running_sum from 
	(select * from cte
	where running_sum <= 70000)t)

select emp_id, experience, salary from cte2
where final_running_sum <= 70000
order by emp_id

--

with cte1 as
(Select *,sum(salary) over(partition by experience order by salary) as d,
 70000 as budget from Candidates)
Select emp_id,experience,Salary from cte1  
where d<=
(
Select 
sum(salary) as remaining
from cte1 where d<=budget and experience='Senior')

--
with recursive base as (select *,rank() over (partition by experience order by salary asc) as rnk_within from candidates)
,base_senior_recruitment as (
select emp_id,salary,experience,salary as budget, rnk_within as rnk  from base where experience = 'Senior' and rnk_within = 1
UNION ALL
select t2.emp_id,t2.salary,t2.experience,t1.budget + t2.salary as budget,t2.rnk_within as rnk
from base_senior_recruitment t1 join base t2
on t2.rnk_within = t1.rnk+1 and t1.budget + t2.salary < 70000
and t2.experience = 'Senior'
and t1.emp_id != t2.emp_id
),
budget_left as (
select 76000 - sum(salary) as budget_left from base_senior_recruitment
),
base_junior_recruitment as (
select emp_id,salary,experience,budget_left - salary as left_money, rnk_within as rnk  from base,budget_left where experience = 'Junior' and rnk_within = 1
and salary < budget_left
UNION ALL
select t2.emp_id,t2.salary,t2.experience,t1.left_money -  t2.salary as left_money,t2.rnk_within as rnk
from base_junior_recruitment t1 join base t2
on t2.rnk_within = t1.rnk+1 and  t2.salary < t1.left_money
and t2.experience = 'Junior'
and t1.emp_id != t2.emp_id
)
select emp_id,salary,experience from base_senior_recruitment
UNION ALL
select emp_id,salary,experience from base_junior_recruitment

--

WITH cands AS
(
	SELECT e.emp_id,e.salary,e.experience,e.SumCumulative,MAX(e.BudgetRemainder) OVER () AS BudgetRemainder
	FROM
	(
		SELECT t.emp_id,t.salary,t.experience,t.SumCumulative,70000-MAX(t.SumCumulative) OVER() AS BudgetRemainder
		FROM
		(
			SELECT  c.emp_id,
					c.salary,
					c.experience,
					SUM(c.salary) OVER(PARTITION BY c.experience ORDER BY (SELECT NULL) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SumCumulative
			FROM candidates c
			WHERE 1=1
					AND c.experience='Senior'
		) t
		WHERE 1=1
				AND t.SumCumulative<=70000
		UNION
		SELECT  c.emp_id,
				c.salary,
				c.experience,
				SUM(c.salary) OVER(PARTITION BY c.experience ORDER BY (SELECT NULL) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SumCumulative,
				'' AS BudgetRemainder
		FROM candidates c
		WHERE 1=1
				AND c.experience='Junior'
	) e
)
SELECT *
FROM cands c
WHERE 1=1
      AND c.experience='Senior'
	  OR (c.experience='Junior' AND c.SumCumulative<=c.BudgetRemainder)