
--write a query to display the records which have 3 or more consecutive rows
--with the amount of people more than 100(inclusive) each day

create table #stadium (
id int,
visit_date date,
no_of_people int
);

insert into #stadium
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);


select * from #stadium

--
;with cte as (
select *,
ROW_NUMBER() over (order by visit_date) as rn,
id-rOW_NUMBER() over (order by visit_date) as grp
from #stadium
where no_of_people>=100) 
select * from cte where grp in (
select grp from cte group by grp 
having COUNT(1) >=3 )

--
with CTE AS (
SELECT *,
lead(no_of_people,1) over(order by visit_date) AS lead_1st_day,
lead(no_of_people,2) over(order by visit_date) AS lead_2nd_day,
lag(no_of_people,1) over(order by visit_date) AS lag_1st_day,
lag(no_of_people,2) over(order by visit_date) AS lag_2nd_day
FROM #STADIUM )
--select * from cte
SELECT id,visit_date,no_of_people FROM cte WHERE no_of_people>=100 and 
((lead_1st_day>=100 AND lead_2nd_day>=100) OR 
(lag_1st_day>=100 and lag_2nd_day>=100) or (lag_1st_day>=100 and lead_1st_day>=100))

--

;with 
cte as(
select id,visit_date,no_of_people,
lag(no_of_people) over() as previous_day,
lead(no_of_people) over () as next_day
from #stadium 
),
cte2 as
(select id from cte
where no_of_people>100 and previous_day>100 and next_day>100)

select  
id,visit_date,no_of_people from #stadium
where id in(
select id from cte2
union
select id-1 from cte2
union
select id+1 from cte2
);


--
with cte as(
select *,
sum(case when no_of_people >= 100 then 1 else 0 end) over(order by visit_date rows between 2 preceding and current row) as Prev_2,
sum(case when no_of_people >= 100 then 1 else 0 end) over(order by visit_date rows between 1 preceding and 1 following) as Prev_next_1,
sum(case when no_of_people >= 100 then 1 else 0 end) over(order by visit_date rows between current row and 2 following) as next_2
 from #stadium)
 select id, visit_date, no_of_people
 from cte
 where Prev_2 >=3
 or Prev_next_1 >=3 
 or next_2 >= 3

 --
; with CTE as
(Select *,
count(id-rn) over(partition by (id-rn)) as dif
from
(Select *,
row_number() over(order by visit_date) as rn
from #stadium
where no_of_people>=100) as F)
Select id,visit_date,no_of_people from 
CTE where dif>3

--
;with cte as(
select *,dateadd(dd,-ROW_NUMBER()over(order by visit_date),visit_date) as rwdate from stadium where no_of_people>=100
)
,ctegrp as
(select *,count(rwdate)over(partition by rwdate) as cnt from cte)
select id,visit_date,no_of_people from ctegrp where cnt>=3

--

;WITH CTE AS (SELECT S.*,
SUM(CASE WHEN no_of_people >= 100 THEN 1 ELSE 0 END) OVER(ORDER BY visit_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as prev_day_count, 
SUM(CASE WHEN no_of_people >= 100 THEN 1 ELSE 0 END) OVER(ORDER BY visit_date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as curr_day_count,
SUM(CASE WHEN no_of_people >= 100 THEN 1 ELSE 0 END) OVER(ORDER BY visit_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as next_day_count
FROM #Stadium S )
--SELECT * FROM CTE;
SELECT id, visit_date, no_of_people FROM CTE
WHERE curr_day_count >= 3 OR prev_day_count >= 3 OR next_day_count >= 3
ORDER BY visit_date ASC;

--

with cte as(
select id,visit_date,no_of_people as curr_row,lag(no_of_people) over(order by visit_date asc) as prev_row,
lag(no_of_people,2) over(order by visit_date) as prev_two_row,
lead(no_of_people) over(order by visit_date) as next_row,
lead(no_of_people,2) over(order by visit_date) as next_two_row
from stadium)
select visit_date,curr_row as no_of_people
from cte
where (curr_row>=100 and next_row>=100 and next_two_row>=100) or
(curr_row>=100 and prev_row>=100 and next_row>=100) or
(curr_row>=100 and prev_row>=100 and prev_two_row>=100)

--

select id,visit_date,no_of_people from
(
select a.id,a.visit_date,a.no_of_people
from stadiums a inner join stadiums b
on a.id=b.id+1 
and a.no_of_people>=100 and b.no_of_people>=100
inner join stadiums c
on a.id=c.id+2 and a.no_of_people>=100 and c.no_of_people>=100
union
select a.id,a.visit_date,a.no_of_people
from stadiums a inner join stadiums b
on a.id=b.id-1 
and a.no_of_people>=100 and b.no_of_people>=100
inner join stadiums c
on a.id=c.id-2 and a.no_of_people>=100 and c.no_of_people>=100
union
select a.id,a.visit_date,a.no_of_people
from stadiums a inner join stadiums b
on a.id=b.id-1 
and a.no_of_people>=100 and b.no_of_people>=100
inner join stadiums c
on a.id=c.id+1 and a.no_of_people>=100 and c.no_of_people>=100
) A 
order by id;


--

with cte as (select *, 
lag(visit_date) over( order by visit_date) as first_date,
lag(visit_date,2) over( order by visit_date) as second_date,
lag(visit_date,3) over( order by visit_date) as third_date
from stadium),
cte2 as (
select 
case 
when visit_date-first_date=1 and visit_date-second_date=2 and visit_date-third_date=3
then  id  end as win
from cte)
select a.id,a.visit_date,a.no_of_people from cte a join cte2 b on
a.id=b.win
where a.no_of_people>100