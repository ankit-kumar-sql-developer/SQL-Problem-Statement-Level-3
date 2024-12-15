

create table #sku 
(
sku_id int,
price_date date ,
price int
);
delete from #sku;
insert into #sku values 
(1,'2023-01-01',10)
,(1,'2023-02-15',15)
,(1,'2023-03-03',18)
,(1,'2023-03-27',15)
,(1,'2023-04-06',20)

select * from #sku

-- Method 1 Without Date Table

--select *  from #sku where datepart(day,price_date) =1

; with cte as (
select *,
row_number() over (partition by datepart(month,price_date),datepart(year,price_date),sku_id 
order by price_date desc ) as rn
from #sku )
select
datetrunc(month,dateadd(month,1,price_date)) as next_month,price,sku_id
from cte where rn=1 and datetrunc(month,dateadd(month,1,price_date)) not in (select price_date from #sku where datepart(day,price_date) =1)
union all
select price_date,price,sku_id from #sku where datepart(day,price_date) =1
order by next_month asc


-- Method 2

select * from calendar_dim

; with cte as (
select *, 
isnull( dateadd(day,-1,LEAD(price_date,1) over (partition by  sku_id order by price_date)),
dateadd(month,1,price_date)) as valid_date
from 
#sku )

select * from cte 
inner join calendar_dim c on c.cal_date between  cte.price_date and cte.valid_date
where cal_month_day=1


--

with RECURSIVE t1 as 
(
  SELECT date_trunc('month', MIN(price_date)) as month_date
  from sku
  UNION ALL
  SELECT month_date+interval '1 month' as month_date
  from t1
  where month_date<(select max(price_date) from sku)
), 
t2 as 
(SELECT 
	t1.month_date,
    sku.price_date,
    price as month_price,
    rank() over(PARTITION by t1.month_date ORDER by sku.price_date desc) as price_rnk
from t1 left join sku
on t1.month_date>=sku.price_date)
SELECT
	month_date,
    month_price
from t2
where price_rnk=1
ORDER by 1;

--

with recursive cte1 as
(Select min(price_date) pd from sku
union all
select date_add(pd,interval 1 day) pd from cte1 where 
pd<=(select date_add(max(price_date),interval 1 month) from sku)
),cte2 as
(select *,lead(price_date,1,"2023-12-31") over(order by price_date) pd2 from sku)

SELECT sku_id,pd price_date,price,price-LAG(price,1,price) over(order by price_date) diff 
FROM cte1 join cte2 on pd between 
price_date and pd2 WHERE dayofmonth(pd)=1 order by pd


--
with cte as(
select *,
    lead(price_date) over(order by price_date) next_date,
    lag(price) over(order by price_date) pre_price,
    row_number() over(partition by sku_id) rn
    from sku
    ),
cte_month as(
select *,date(concat(year(price_date),"-",rn,"-","1")) month_date from cte
)
select *,
    coalesce(price-lag(price) over(order by month_date),0) dif
    from (
    select sku_id, 
    month_date,if(price_date<=month_date,price,pre_price) price from cte_month) s

--

