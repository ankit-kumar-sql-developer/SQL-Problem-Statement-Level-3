-- how to create group key 

create table #event_status
(
event_time varchar(10),
status varchar(10)
);
insert into #event_status 
values
('10:01','on'),('10:02','on'),('10:03','on'),('10:04','off'),('10:07','on'),('10:08','on'),('10:09','off')
,('10:11','on'),('10:12','off');

select * from #event_status

--
; with cte as (
select *,
sum(case when status='on' and prev_status='off' then 1 else 0 end ) over (order by event_time)
as group_key
from(
select *,
lag(status,1,status) over (order by event_time asc) as prev_status
from #event_status ) t )

select MIN(event_time) as login, MAX(event_time) as logout, COUNT(1)-1 as cnt
from cte group by group_key

--
; with temp as(
select *,
rank() over( order by event_time) as rnk,
right(event_time,1)-rank() over( order by event_time) as flag 
from #event_status order by event_time)

select min(event_time) as login, max(event_time) as logout, count(status)-1 as cnt from temp
group by flag

--
SELECT
  MIN(event_time) AS start_time,
  off_time AS end_time
FROM #event_status e1
CROSS APPLY (SELECT
                    MIN(e2.event_time) AS off_time
                          FROM #event_status e2
                            WHERE e2.event_time > e1.event_time
                              AND e1.status = 'on'
                              AND e2.status = 'off'

) t
WHERE off_time IS NOT NULL
GROUP BY off_time

--
;with cte as(
select *, sum(new_status) over(order by event_time) as running_sum from(
select *,
case when status = 'on' and lag(status) over(order by event_time) = 'off' then 1 else 0 end as new_status
from #event_status )temp)
select min(event_time) as login, max(event_time) as logout, count(running_sum)-1 as cnt
from cte
group by running_sum;

--
; with cte as (select 
		*,
		rank() over(order by event_time) as rnk,
		cast(DATEADD(MINUTE, -1*rank() over(order by event_time),event_time)as time) as _time 
	from #event_status )

	select 
		min(event_time) as log_in,
		max(event_time) as log_out,
		count(rnk)-1 as cnt
	from cte
	group by _time

--
with cte as
(
Select *, 
cast(SUBSTRING(event_time,4,2) as int) - row_number()over(order by event_time) as grp
from event_status
)
Select  min(event_time)  as login , max(event_time) as logout
,count(case when status='on' then 1 else null end) as cnt 
from cte 
group by grp

--
with cte as (
select * 
,row_number() over(order by event_time) - row_number() over(partition by status order by event_time) grp
,lead(event_time) over(order by event_time) next_event_time
from event_status )
select min(event_time) Log_in, max(next_event_time) Log_out, count(1) Cnt
from cte 
where status  = 'on'
group by grp
order by Log_in;

--

with rank_cte as (
select e.*, s.event_time as next_off,
row_number() over (partition by e.event_time order by e.event_time) as rnk
from #event_status e
left join #event_status s
on e.event_time < s.event_time
and s.status='off'
)
select min(event_time) as login, next_off as logout, count(1) as cnt
from rank_cte
where rnk=1 and status='on'
group by next_off;


--
with cte as(
select *
,row_number() over(order by event_time) as rn
from #event_status)
,cte2 as (
select *,
row_number() over(order by event_time) as rn2
from cte where status='on' )
select min(event_time),
concat(left(replace(max(event_time),':','')+1,2),':',right(replace(max(event_time),':','')+1,2))
,count(*)
from cte2
group by (rn-rn2)

--

with cte as(
select *,minute(event_time)-row_number() over() as rn from #event_status)
select min(event_time) as login,max(event_time) as logout,count(1)-1 as cnt
from cte group by rn;

--

; with cte as(select event_time,
    iif(status='on', event_time, null) login,
    iif(status = 'off', event_time , null) logout,
    lead(event_time) over(order by (select null)) nxt_event_time
    from #event_status )
  
select min(login) login,
    max(nxt_event_time) logout,
    count(cnt) cnt from 
    (select *,count(iif(login is null, 1, null))
    over(order by event_time) cnt from cte) c 
    where login is not null group by cnt

--

;with cte as(
select min(event_time)mtime,max(event_time)mxtime,count(9)-1 total_logins from (
select event_time,
event_time-ROW_NUMBER() over (order by event_time) grp_cl
,status from event_status)ar
group by grp_cl)
select   concat(left(mtime,2),':',right(mtime,2) ) as logintime,
         concat(left(mxtime,2),':',right(mxtime,2) ) as logouttime ,
		 total_l


 --


		 WITH CTE_RANK AS(
SELECT event_time,status,DENSE_RANK() OVER(ORDER BY event_time ASC) AS row_no,
DENSE_RANK()OVER(PARTITION BY status ORDER BY event_time) AS status_rn
FROM event_status
),
CTE_DIFF AS(
SELECT *,CASE WHEN status='on' THEN (row_no-status_rn) ELSE (status_rn-1) END AS diff
FROM CTE_RANK)
SELECT min(event_time)AS login,max(event_time) AS logout,COUNT(*)-1 AS cnt
FROM CTE_DIFF
GROUP BY diff
--

WITH timer_data_1 AS
# CONVERTING TO ACTUAL TIME
(
SELECT
 CAST(CONCAT(CURRENT_DATE(),' ',timer,':00') AS TIMESTAMP) AS timer,
 RANK() OVER (PARTITION BY status ORDER BY timer) -1 AS rnk,
 status,
FROM
 `timer_table`
),

# FINDING RANK BASED DIFFERENCE FOR TIMER TO CREATE COMMON GROUP/BUCKET OF DATA
timer_data_2 AS
(
SELECT 
timer,
timer - CAST(CONCAT(CURRENT_DATE(),' ','10:0',rnk,':00') AS TIMESTAMP) AS timer_diff,
status
FROM timer_data_1 
),

# RANKING AGAIN BASED ON THE GROUPED/BUCKETED DATA
timer_data_3 AS
(
SELECT 
timer,
status,
ROW_NUMBER() OVER (PARTITION BY timer_diff ORDER BY timer) AS rnk,
FROM timer_data_2
)

# EXTRACTING RELEVANT INFORMATION & EXCLUDING NULL RECORDS

SELECT
time_on,
time_off,
TIMESTAMP_DIFF(time_off,time_on, MINUTE) AS running_time
FROM
(
SELECT 
(CASE WHEN status = 'on' THEN timer END) AS time_on,
LEAD((CASE WHEN status = 'off' THEN timer END)) OVER (ORDER BY timer) AS time_off
FROM timer_data_3
WHERE rnk = 1 
)
WHERE time_on IS NOT NULL
ORDER BY 1

--