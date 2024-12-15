-- get most recent acitvity, if there is only one activity return one
create table #UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);

insert into #UserActivity values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');


select * from #UserActivity

--
;with cte as (
select *,
count(1) over (partition by username) as total_activites,
rank() over (partition by username order by startdate desc) as rnk
from #useractivity )
select * from cte where total_activites=1 or rnk=2

--
select * from #useractivity where username in 
(select username from #useractivity group by username having count(username) = 1)
union
select username,activity,startdate,enddate from (
select *, dense_rank() over (partition by username order by startdate)rnk from 
#useractivity)a 
where rnk =2;

--

with cte as(
select *, ROW_NUMBER() over (partition by username order by startDate asc) as rnk  from #UserActivity
),
ttp as (
select *,
LAST_VALUE(rnk) over (partition by username order by startDate asc rows between unbounded preceding and unbounded following) as rnk_2 from cte
)
select * from ttp where rnk = 2 or rnk_2 = 1;

--
;with cte as(
select *,rank() over(partition by username order by enddate desc) as rn,
lag(enddate) over(partition by username order by enddate) as prev_activity,
lead(enddate) over(partition by username order by enddate) as next_activity
from #useractivity)
select username,activity,startdate,enddate
from cte where rn=2 or (prev_activity is null and next_activity is null)

--
with t1 as (
Select *,row_number() over(partition by username order by startDate asc) as rnk
from #useractivity
)
,t2 as 
(
Select username,count(rnk) as num_activity
from t1
group by username
)

select t1.username,t1.activity,t1.startDate,t1.endDate
from t1
left join t2 on t1.username = t2.username
where rnk=2 or num_activity=1
order by 1 asc

--

; with cte as (
select t.* ,row_number() over (partition by username order by enddate desc) rn,count(1) over (partition by username) ct
from #UserActivity t
)
select * from (
select t1.*,(ct-rn) diff from cte t1
) t
where (rn=2 ) or (diff=0 and rn=1)

--
with cte as (
select username,activity,startDate,endDate, 
RANK() over(partition  by username order by endDate desc) rnk_desc,
RANK() over(partition  by username order by endDate) rnk_asc
from #UserActivity  )
select * from cte where rnk_desc=2 or rnk_asc=rnk_desc

--

with cte AS
(
select *,
row_number() over(partition By username order by enddate) as rn,
count(1) over(partition by username order by username) as cnt
from #UserActivity
  )
  select username,Activity,startdate,enddate from cte where rn = 2 and cnt > 1
  union all
  select username,Activity,startdate,enddate from cte where cnt = 1

  --
  WITH cte AS
(SELECT * ,
CASE
WHEN (count(1) OVER (PARTITION BY username )) = 1 THEN activity
ELSE
(CASE
	WHEN (rank() OVER (PARTITION BY username ORDER BY enddate DESC )) = 2 THEN activity
END)
END AS second_most
FROM #useractivity)
SELECT username, activity, startdate, enddate
FROM cte
WHERE second_most IS NOT NULL

--

WITH CTE AS(
SELECT username,activity,startDATE,endDate,DENSE_RANK()OVER(PARTITION BY username ORDER BY startDate) AS rn,LEAD(endDate)OVER(PARTITION BY username ORDER BY startDate) AS IND_Nxt_Activity
FROM #UserActivity
)
SELECT username,activity,startDate,endDate FROM CTE
WHERE rn=2 OR (rn=1 AND IND_Nxt_Activity IS NULL)

--

;WITH CTE AS
(
select U.username AS USER_, U.activity AS ACTI_, U.startDate AS S_DATE, U.endDate AS E_DATE
, RANK() OVER(PARTITION BY U.username ORDER BY U.endDate DESC) AS RN from #UserActivity as U
) 
SELECT 
USER_, ACTI_, S_DATE, E_DATE
FROM CTE 
WHERE RN= 2 OR USER_ IN
						(select U.username from #UserActivity as U
						GROUP BY U.username
						HAVING COUNT(U.username) =1
						)

--

WITH cte as 
(SELECT *,ROW_NUMBER() OVER(PARTITION BY username ORDER BY enddate) as rn FROM #UserActivity)
SELECT username,activity,startDate,enddate FROM CTE WHERE rn=2
UNION ALL
SELECT username,activity,startDate,enddate FROM CTE 
WHERE username in (SELECT username FROM CTE GROUP BY username HAVING COUNT(*) = 1 );

--

;with temp as(
select *,
count(*) over(partition by username) as total_act,
rank() over(partition by username order by startDate desc) as rn
from #useractivity )

select * from temp
where total_act>1 and rn=2

union 

select * from temp 
where total_act=1
