--wrlte a query to print toota rides and profit rides or each  driver
--profit ride is when the end location of current ride is same as start location on next ride

create table #drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
insert into #drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e');
insert into #drivers values('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h');
insert into #drivers values('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');

select * from #drivers

-- Method 1
; with cte as (
select *,
LEAD(start_loc) over (partition by id order by start_time ) as next_start_loc
from #drivers )
select id,COUNT(1) as cnt,
sum(case when end_loc= next_start_loc then 1 else 0 end) as profit_rides
from cte group by id

-- Method 2
; with rides as (
select *,
ROW_NUMBER() over (partition by id order by start_time asc ) as rn 
from #drivers a )

select r1.id,COUNT(1) totalrides,
COUNT(r2.id) as profit_rides
from rides r1
left join  rides r2  on r1.id=r2.id and r1.end_loc=r2.start_loc
and r1.rn+1=r2.rn group by r1.id

--

; with cte as
(select *, (case when lead(start_loc,1,start_loc) over 
(partition by id order by id) = end_loc then 1 else 0 end)as new_loc
from #drivers)

select id, count(*)as total_rides, sum(new_loc)as profit_rides from cte
group by id

--
