
/*write a SQL query to find out supplier_id, product_id,no of days and starting date of record _ date 
for which stock quantity is less than 50 for two or more consecutive days. */


create table #stock (
    supplier_id int,
    product_id int,
    stock_quantity int,
    record_date date
);


delete from #stock;
insert into #stock (supplier_id, product_id, stock_quantity, record_date) values
 (1, 1, 60, '2022-01-01'),
 (1, 1, 40, '2022-01-02'),
 (1, 1, 35, '2022-01-03'),
 (1, 1, 45, '2022-01-04'),
 (1, 1, 51, '2022-01-06'),
 (1, 1, 55, '2022-01-09'),
 (1, 1, 25, '2022-01-10'),
 (1, 1, 48, '2022-01-11'),
 (1, 1, 45, '2022-01-15'),
 (1, 1, 38, '2022-01-16'),
 (1, 2, 45, '2022-01-08'),
 (1, 2, 40, '2022-01-09'),
 (2, 1, 45, '2022-01-06'),
 (2, 1, 55, '2022-01-07'),
 (2, 2, 45, '2022-01-08'),
 (2, 2, 48, '2022-01-09'),
 (2, 2, 35, '2022-01-10'),
 (2, 2, 52, '2022-01-15'),
 (2, 2, 23, '2022-01-16');

 select * from #stock

 --
; with cte as (
select supplier_id,product_id,record_date,
lag(record_date,1,record_date) over (partition by supplier_id, product_id order by record_date) as prev_record_date
,datediff(day, lag(record_date,1,record_date) over (partition by supplier_id, product_id order by record_date), record_date) as diff
from #stock where stock_quantity < 50)
, cte2 as (
select *,
case when diff<=1 then 0 else 1 end as flag,
SUM(case when diff<=1 then 0 else 1 end) over(partition by supplier_id, product_id order by record_date) as g_id
from cte )

select supplier_id, product_id,g_id,
COUNT(*) as no_of_records,MIN(record_date) as first_date
from cte2 group by supplier_id, product_id,g_id having COUNT(*) >=2


--

with cte as 
(
SELECT *,datepart(day,record_date)-row_number() over (partition by supplier_id, product_id order by record_date) as rows_diff 
FROM #stock WHERE stock_quantity <= 50
)
Select supplier_id, product_id, count(*) as no_of_records,min(record_date) as first_date from cte
group by supplier_id, product_id, rows_diff
having count(*) >= 2


--
select * from (
select supplier_id,product_id,count(*) as cnt,min(record_date) as record_date from (
select  *, datediff(day,rw,record_date) as id  from (
select *, row_number () over (partition by supplier_id,product_id order by record_date) as rw

from  stock 
where stock_quantity<50) a ) b 
group by supplier_id,product_id,id ) c  
where cnt>1

-- Easy solution:  with cte as (
 select *, lead(record_date, 1) over (partition by supplier_id, product_id order by record_date) as next_date,
 lead(record_date, 2) over (partition by supplier_id, product_id order by record_date) as next_to_date
 from stock 
 where stock_quantity < 50
 )
 
 select supplier_id, product_id, record_date as first_date from cte
 where datediff(next_date, record_date) = 1 and datediff( next_to_date, record_date) = 2

--

with cte as(
select *,
row_number()over(partition by product_id,supplier_id order by record_date ) as dd
from stock where stock_quantity<50
)--,cte1 as(
select supplier_id,product_id,min(record_date) as firstdate,
COUNT( DATEPART(DAY, record_date) - dd) as consecutive_days  
from cte
group by supplier_id,product_id,
( DATEPART(DAY, record_date) - dd) 
having COUNT( DATEPART(DAY, record_date) - dd)  >= 2


--

with cte as(
select supplier_id,product_id,record_date
,row_number() over (partition by supplier_id,product_id order by record_date) as rn
,day(record_date) - row_number() over (partition by supplier_id,product_id order by record_date) as group_id
from stock
where stock_quantity < 50)

select supplier_id,product_id, count(*) as no_of_records, min(record_date) as first_date
from cte 
group by supplier_id,product_id,group_id


--
with cte as(
select *,row_number() over(partition by supplier_id,product_id order by record_date) as rn from stock),
cte2 as(
select *,abs(day(record_date)-rn) as diff from cte where stock_quantity < 50)
select supplier_id,product_id,count(1) no_of_days,min(record_Date) record_date 
from cte2 group by diff,supplier_id,product_id
having count(1) >= 2;



--

with cte as
    (SELECT *,
    LAST_VALUE(case when prev <> -1 then record_date end) ignore nulls over(PARTITION BY supplier_id, product_id ORDER BY record_date) as starting_date
    from  (SELECT *,
    DATEDIFF(day, record_date, lag(record_date,1,record_date)over(PARTITION BY supplier_id,product_id ORDER BY record_date )) as prev,
    DATEDIFF(day, lead(record_date,1,record_date)over(PARTITION BY supplier_id,product_id ORDER BY record_date), record_date) as next
    from stock
    where stock_quantity < 50) a
    where prev = -1 or next = -1)
    SELECT supplier_id,product_id,count(starting_date) as no_of_days, starting_date from cte
    GROUP by supplier_id,product_id, starting_date

	--

	with stock50 as (
select supplier_id, product_id, record_date ,
lag(record_date, 1, record_date) over(partition by supplier_id, product_id order by record_date) as prev_date
from stock
where stock_quantity < 50
)
, grouped_stock as (
select
supplier_id, product_id, record_date
, sum(case when datediff(day, prev_date, record_date)<=1 then 0 else 1 end ) over(partition by supplier_id, product_id order by record_date) as grp
from stock50
)

select
supplier_id, product_id, count(grp) as num_days ,min(record_date) as first_date
from grouped_stock
group by supplier_id, product_id, grp
having count(grp) >=2


--
with rec as (
select record_date
from stock where record_date = '2022-01-01'
union all
select dateadd(day,1,record_date) record_date
from rec
where dateadd(day,1,record_date)<='2022-01-16'
)
,a as(select supplier_id, product_id, r.record_date, 
day(r.record_date)-row_number() over(partition by supplier_id, product_id order by DAY(r.record_date)) rn2
from rec r left join stock s on r.record_date=s.record_date
where stock_quantity<50)

select supplier_id, product_id, count(rn2), min(record_date)
from a
group by supplier_id, product_id, rn2
having count(rn2)>=2


--

SELECT supplier_id, product_id, COUNT(*) AS total_consecutive_count, MIN(record_date) AS first_date
FROM(
SELECT supplier_id, product_id, stock_quantity, record_date,
ROW_NUMBER() OVER(PARTITION BY supplier_id, product_id ORDER BY record_date) AS rn,
DATEDIFF(DAY, ROW_NUMBER() OVER(PARTITION BY supplier_id, product_id ORDER BY record_date), DAY(record_date)) AS difference
FROM stock
WHERE stock_quantity < 50
) subquery
GROUP BY difference, supplier_id, product_id  HAVING COUNT(difference) >= 2



having count(*)>=2