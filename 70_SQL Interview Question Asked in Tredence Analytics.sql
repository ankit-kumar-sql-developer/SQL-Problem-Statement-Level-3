
create table #cinema (
    seat_id int primary key,
    free int
);
delete from #cinema;
insert into #cinema (seat_id, free) values (1, 1);
insert into #cinema (seat_id, free) values (2, 0);
insert into #cinema (seat_id, free) values (3, 1);
insert into #cinema (seat_id, free) values (4, 1);
insert into #cinema (seat_id, free) values (5, 1);
insert into #cinema (seat_id, free) values (6, 0);
insert into #cinema (seat_id, free) values (7, 1);
insert into #cinema (seat_id, free) values (8, 1);
insert into #cinema (seat_id, free) values (9, 0);
insert into #cinema (seat_id, free) values (10, 1);
insert into #cinema (seat_id, free) values (11, 0);
insert into #cinema (seat_id, free) values (12, 1);
insert into #cinema (seat_id, free) values (13, 0);
insert into #cinema (seat_id, free) values (14, 1);
insert into #cinema (seat_id, free) values (15, 1);
insert into #cinema (seat_id, free) values (16, 0);
insert into #cinema (seat_id, free) values (17, 1);
insert into #cinema (seat_id, free) values (18, 1);
insert into #cinema (seat_id, free) values (19, 1);
insert into #cinema (seat_id, free) values (20, 1);

select * from #cinema

-- Method 1
; with cte as (
select *,
row_number () over (order by seat_id) as rn,
seat_id- row_number () over (order by seat_id) as grp
from #cinema where free=1 )
select * from (
select *,count(*) over (partition by grp) as cnt
from cte  ) t where cnt>1

-- Method 2

; with cte as (
select a.seat_id as s1, b.seat_id as s2
from  #cinema a 
inner join #cinema b  on a.seat_id+1 = b.seat_id
where a.free=1 and b.free=1 )
select s1 from cte union  select s2 from cte

-- Method 3
select * from (
select *,lag(free,1) over (order by seat_id) as prev_free,
lead(free,1) over (order by seat_id) as next_free
from #cinema ) t
where free=1 and (prev_free=1 or next_free=1 )

--
with mycte as
(
select *,
case when (free = 1 and prev_free = 1) or (free = 1 and next_free = 1) then 'Yes' else 'No' end as seat_status
from
(
	select *,
	lag(free,1) over(order by seat_id) as prev_free,
	lead(free,1) over(order by seat_id) as next_free
	from cinema
) as x
)

select seat_id from mycte
where seat_status = 'Yes'



--

WITH cte1 AS (SELECT *,
LEAD(seat_id) OVER(ORDER BY seat_id)-seat_id as lead_seat_diff, 
seat_id-LAG(seat_id) OVER(ORDER BY seat_id) as lag_seat_diff
FROM cinema
WHERE free=1)
SELECT seat_id 
FROM cte1
WHERE lead_seat_diff=1 OR lag_seat_diff=1;

--
with cte as(
select * ,seat_id-sum(free) over(order by seat_id)t 
from cinema
where free = 1)
select seat_id
 from cte 
where t in (select t 
 from cte
group by t
having count(t)>=2)

--
with cte as (
select *,
(lag(free,1) over( order by seat_id)*free) as lde,
(lead(free,1) over( order by seat_id)*free) as rwn
from cinema)

Select * from cte 
where lde =1 or rwn =1

--
select seat_id
from cinema a
where exists (select 1
               from cinema b
			   where a.free=1 and b.free=1 and (a.seat_id+1=b.seat_id or a.seat_id-1=b.seat_id))
another simpler method- 
with cte as
(
	select seat_id
	from cinema 
	where free=1
)
	select seat_id
	from cte
	where seat_id-1 in (select seat_id from cte) or seat_id+1 in (select seat_id from cte);

--