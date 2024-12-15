-- 3 or more consecutive empty seats
create table #bms (seat_no int ,is_empty varchar(10));
insert into #bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');

select * from #bms

-- Method 1 lead lag
select * from (
select *,
LAG(is_empty,1) over (order by seat_no) as prev_1,
LAG(is_empty,2) over (order by seat_no) as prev_2,
lead(is_empty,1) over (order by seat_no) as next_1,
lead(is_empty,2) over (order by seat_no) as next_2
from #bms ) a
where is_empty='Y' and prev_1='Y' and Prev_2='Y'
or (is_empty='Y' and prev_1='Y' and next_1='Y')
or (is_empty='Y' and next_1='Y' and next_2='Y')

-- Method 2 advance aggergation
select * from (
select *,
sum(case when is_empty='Y' then 1 else 0 end ) over (order by seat_no rows between 2 preceding and current row) as Prev_2,
sum(case when is_empty='Y' then 1 else 0 end ) over (order by seat_no rows between 1 preceding and 1 following) as Prev_next_1,
sum(case when is_empty='Y' then 1 else 0 end ) over (order by seat_no rows between current row and 2 following) as next_2
from #bms ) t
where Prev_2= 3 or Prev_next_1 = 3 or next_2=3

-- Method 3
;with cte as (
Select *,
row_number() over(order by seat_no) as rn,
seat_no-row_number() over(order by seat_no) as diff
from #bms where is_empty='Y' )
, cte2 as (
select diff 
from cte group by diff having COUNT(1) >=3 )

select * 
from cte where diff in (select diff from cte2)

---
select * from
(select * , 
count(is_empty) over (order by seat_no rows between 2 preceding and 2 following) counter
from #bms) sub

where is_empty = 'Y' and counter = 5

---
WITH cte as (
select *
, CASE WHEN is_empty = 'Y' then 1 END as RNK
, LAG(is_empty,3)over(order by  CASE WHEN is_empty = 'Y' then 1 END) as LAGS
from #bms )
select seat_no, LAGS
from cte
where LAGS = 'Y'
order by seat_no


--


-- ===== Method 1 ==========
with cte as 
(select seat_no,
lag(seat_no) over ( order by seat_no) as prev_seat_no,
lead(seat_no) over ( order by seat_no) as next_seat_no,
is_empty as current_seat,
lag(is_empty) over ( order by seat_no) as prev_seat,
lead(is_empty) over ( order by seat_no) as next_seat
from bookmyshow ),
cte2 as (
Select prev_seat_no,seat_no,next_seat_no from cte where prev_seat='Y' and current_seat='Y' and next_seat='Y')   // Since the requirement is in one single column but unknowingly this  too be question 
Select distinct prev_seat_no as seat_no from cte2 
union
Select distinct seat_no as seat_no from cte2 
union
Select distinct next_seat_no as seat_no from cte2 

-- ===== Method 2 ==========

with method2 as (
Select * ,
sum( case when is_empty='Y' then 1 else 0 end) over ( order by seat_no rows between 2 preceding and current row) as prev_row2,
sum( case when is_empty='Y' then 1 else 0 end) over ( order by seat_no rows between current row and 2 following ) as next_row2,
sum( case when is_empty='Y' then 1 else 0 end) over ( order by seat_no rows between 1 preceding and 1 following ) as current_row
from bookmyshow)

Select seat_no from method2 where 3 in ( prev_row2,current_row,next_row2)

