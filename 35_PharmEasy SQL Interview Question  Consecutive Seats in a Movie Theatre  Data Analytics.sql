
--there are 3 rows in a movie hall each with 10 seats in each row
--write a SQL to find 4 consecutive empty seats




create table #movie(
seat varchar(50),occupancy int
);
insert into #movie values('a1',1),('a2',1),('a3',0),('a4',0),('a5',0),('a6',0),('a7',1),('a8',1),('a9',0),('a10',0),
('b1',0),('b2',0),('b3',0),('b4',1),('b5',1),('b6',1),('b7',1),('b8',0),('b9',0),('b10',0),
('c1',0),('c2',1),('c3',0),('c4',1),('c5',1),('c6',0),('c7',1),('c8',0),('c9',0),('c10',1);

select * from #movie

--
; with cte as (
select *, LEFT(seat,1) as row_id,cast(SUBSTRING(seat,2,2) as int) as seat_id from #movie)
,cte2 as (
select *, MAX(occupancy) over (partition by row_id order by seat_id
rows between current row and 3 following) as is_4empty,
count(occupancy) over (partition by row_id order by seat_id
rows between current row and 3 following) as cnt from cte )
,cte3 as (select * from cte2 where is_4empty=0 and cnt=4 )

select * from cte2 a
inner join cte3 b on a.row_id= b.row_id
and a.seat_id between b.seat_id and b.seat_id+3

--
;with cte as (
select *,LEFT(seat,1) as row_id,cast(SUBSTRING(seat,2,2)as int) as seat_no
from #movie)
,final as (
select *,row_number()over(order by row_id,seat_no) as rn ,
abs(seat_no-row_number()over(order by row_id,seat_no)) as diff
from cte 
where occupancy =0)
select seat from (select *,
count(1)over(partition by row_id,diff) as cnt
from final)a where cnt=4


--
with cte as(
select seat, 
	cast(
	cast(substring(seat,2,3) as int)
	-row_number() over(partition by left(seat,1) order by cast(substring(seat,2,3) as int)) as varchar(2)) + left(seat,1)as grp 
	from #movie where occupancy =0)
select seat from cte where grp in(
select grp from cte group by grp having count(*)>=4)

--

with cte as(select *,left(seat,1) as seat_row,cast(right(seat,len(seat)-1) as int) as seat_no 
from #movie),
cte2 as (select *,
sum(case when occupancy=0 then 1 else 0 end) 
over(partition by seat_row order by seat_no rows between 3 preceding and current row) as prev_3,
sum(case when occupancy=0 then 1 else 0 end) 
over(partition by seat_row order by seat_no rows between 2 preceding and 1 following) as prev_2_next_1,
sum(case when occupancy=0 then 1 else 0 end) 
over(partition by seat_row order by seat_no rows between 1 preceding and 2 following) as prev_1_next_2,
sum(case when occupancy=0 then 1 else 0 end) 
over(partition by seat_row order by seat_no rows between current row and 3 following) as next_3
from cte)
select * 
from cte2
where prev_3=4 or prev_2_next_1=4 or prev_1_next_2=4 or next_3=4

--

with cte as (
select *, left(seat,1) Row , cast (substring(seat,2,2) as int) S_No 
from #movie where occupancy = 0)
,cte2 as(
 select *,  [row] + cast(S_No-row_number() over(partition by row order by S_no asc) as varchar) diff from cte)
 select seat from cte2
 where diff in ( select diff from cte2 group by diff having count(*)>=4)

 --

 with cte1 as (select * , ntile(3) over(order by (select null)) as group1 
from #movie)
 ,cte2 as (select seat, occupancy as oc, lead(occupancy,1) over(partition by group1 order by (select null)) nxt1 ,
 lead(occupancy,2) over(partition by group1 order by (select null)) nxt2,
 lead(occupancy,3) over(partition by group1 order by (select null)) nxt3,
 lag(occupancy,1) over(partition by group1 order by (select null)) prev1,
 lag(occupancy,2) over(partition by group1 order by (select null)) prev2,
 lag(occupancy,3) over(partition by group1 order by (select null)) prev3
 from cte1)
 select seat, oc from cte2
 where (oc=0 and nxt1=0 and nxt2=0 and nxt3=0) or (oc=0 and nxt1=0 and nxt2=0 and prev1=0) or 
 (oc=0 and nxt1=0 and prev1=0 and prev2=0) or (oc=0 and prev1=0 and prev2=0 and prev3=0)
 --
 
with cte as(
select seat, occupancy,
lag(occupancy, 1, 1) over(partition by left(seat, 1)) as lg,
row_number() over() as rn from #movie),

cte2 as
(select *, sum(case when occupancy = lg then 0 else 1 end) over(order by rn) as grp from cte)

select seat from cte2
where grp in (select grp from cte2 where occupancy = 0 group by grp having count(*) > 3);

--

with CTE1 as (
Select *
, row_number() over(partition by left(seat, 1) order by CAST(RIGHT(seat, LEN(seat) - 1) AS INT)) as Rows_Seats_Number 
from #movie)
, cte2 as (
Select *
, ROW_NUMBER() 
over(partition by left(seat, 1) order by CAST(RIGHT(seat, LEN(seat) - 1) AS INT) asc) as rn
from CTE1
where occupancy =0 )
, cte3 as (
Select *, left(seat,1) + cast ((Rows_Seats_Number - rn) as varchar(3)) as c_group 
from cte2 
)
, cte4 as (
Select c_group from cte3
group by c_group
having count(1) >=4
)
Select seat from cte3
inner join cte4
on cte3.c_group = cte4.c_group