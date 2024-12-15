-- Merge Overllaping events in same hall

create table #hall_events
(
hall_id integer,
start_date date,
end_date date
);
delete from #hall_events
insert into #hall_events values 
(1,'2023-01-13','2023-01-14')
,(1,'2023-01-14','2023-01-17')
,(1,'2023-01-15','2023-01-17')
,(1,'2023-01-18','2023-01-25')
,(2,'2022-12-09','2022-12-23')
,(2,'2022-12-13','2022-12-17')
,(3,'2022-12-01','2023-01-30');

select * from #hall_events

--
; with cte as (
select *,ROW_NUMBER() over (order by hall_id,start_date) as event_id
from #hall_events )

,r_cte as (
select hall_id, start_date,end_date,event_id,1 as Flag
from cte where event_id=1 

union all
select c.hall_id, c.start_date,c.end_date,c.event_id,
case when c.hall_id=r.hall_id and (c.start_date between r.start_date and r.end_date
or r.start_date between c.start_date and c.end_date) then 0 else 1 end + Flag as Flag
from r_cte r
inner join cte c on r.event_id+1= c.event_id
)
select hall_id, Flag, MIN(start_date) as start_date, 
MAX(end_date) 
from r_cte group by hall_id, Flag

--

; with cte as(
select *,
lag(end_date,1,start_date) over(partition by hall_id order by start_date) as prev_end_date,
case when lag(end_date,1,start_date) over(partition by hall_id order by start_date) >= start_date
then 0 else 1 end  as flag
from #hall_events )
select hall_id,min(start_date),max(end_date)
from cte 
group by hall_id,flag

--

;with cte as(
select hall_id,start_date,end_date,lag(end_date) over(partition by hall_id order by start_date) as prev_end_date
from hall_events
)
select hall_id,min(start_date) as start_date,max(end_date) as end_date
from cte
where prev_end_date is null or start_date < prev_end_date
group by hall_id
union 
select hall_id,start_date,end_date
from cte where start_date>prev_end_date
order by hall_id,start_date;

-- replace the recursion with a case statement but my case here is the death of performace:

;with flo as (select a.*, row_number()over(order by start_date, hall_id) as rownum from hall_events a),
flo1 as (select a.* , sum(case when exists(select * from flo 
where hall_id=a.hall_id and (a.start_date between start_date and end_date or
 start_date between a.start_date and a.end_date) and rownum <a.rownum)  then 0 else 1 end)
over(partition by hall_id order by start_date) as flag
from flo a)
select hall_id, min(start_date)as start_date, max(end_date)as end_date 
from flo1 
group by hall_id, flag
order by 1,2;

--

with cte as (	
select *, case when start_date > lag_end_dt then 1 else 0 end as flg from 
(select *, lag(end_date,1, start_date) over (partition by hall_id ) lag_end_dt from #hall_events he)t
),
cte2 as (
select * , sum(flg) over(partition by hall_id rows between unbounded preceding and current row) grp from cte
)
select hall_id , grp,  min(start_date) as start_dt , max(end_date) as end_dt
from cte2
group by hall_id , grp

--
1. Get next start date
2. Get last end date
3. Check if next start date is equal or less than end date
4. Check if last end date is more or equal to end date
5. If either 3 or 5 is true then group then
______________________________________________________________

WITH cte1 AS 
(
SELECT 
	a.*
	,LAG(end_date,1,'01-01-2000') OVER(PARTITION BY hall_id ORDER BY start_date ASC) AS end_prev
	,LEAD(start_date,1,'01-01-2099') OVER(PARTITION BY hall_id ORDER BY start_date ASC) AS next_start
FROM hall_events AS a
)


,cte2 AS 
(
SELECT a.*
	,CASE WHEN end_prev>=end_date THEN 1 ELSE 0 END AS flag_1,
	,CASE WHEN next_start<=end_date THEN 1 ELSE 0 END AS flag_2
FROM cte1 AS a
)
,
cte3 AS 
(
SELECT a.*
      ,CASE WHEN flag_1 = 1 or flag_2 = 1 THEN 1 ELSE 0 END AS final_flag
FROM cte2 AS a
)
----------------------------

SELECT 
	hall_id
	,final_flag
	,MIN(start_date) AS start_date
	,MAX(end_date) AS end_date
FROM cte3
GROUP BY hall_id,final_flag
ORDER BY 1 ASC, 3 ASC;


--

with cte as (select *, lead(start_date,1) over(partition by hall_id order by start_date) as lg
from #hall_events
),
cte1 as (select * ,
case
when lg between start_date and end_date then 1 end as dat_cal
from cte)
select hall_id, start_date, end_date from cte1 where dat_cal is null

--

With cte as (
SELECT *,
CASE WHEN start_date <= LAG(end_date) OVER (PARTITION BY hall_id ORDER BY start_date) 
     OR end_date >= LEAD(start_date) OVER (PARTITION BY hall_id ORDER BY start_date) 
     THEN 0 ELSE 1 END AS rn
FROM #hall_events)

Select hall_id, min(start_date), max(end_date)
From cte
Group by hall_id, rn
Order by hall_id