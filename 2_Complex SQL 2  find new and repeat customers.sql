
create table #customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);
insert into #customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)


select * from #customer_orders

-- New customer & repeat cutsomer
;with first_visit as (
Select customer_id,min(order_date) as first_visit_date
from #customer_orders group by customer_id )
,visit_flag as (
select co.*,fv.first_visit_date,
case when  co.order_date= fv.first_visit_date then 1 else 0 end as first_visit_flag,
case when  co.order_date!= fv.first_visit_date then 1 else 0 end as repeat_visit_flag
from #customer_orders co
inner join first_visit fv on co.customer_id=fv.customer_id
)
select order_date, sum(first_visit_flag) as no_of_new_customer, 
sum(repeat_visit_flag) as no_of_repeat,
Sum(case when first_visit_flag = 1 then order_amount end ) as new_revenue,
Sum(case when repeat_visit_flag = 1 then order_amount end ) as old_revenue
from visit_flag group by order_date

--

;with cust_count as (
select *,
count(customer_id) over(partition by customer_id order by order_date) [flag]
from #customer_orders)
select order_date,
count(case when [flag] = 1 then 1 end) [new customers],
count(case when [flag] > 1 then 1 end) [repeat customers]
from cust_count group by order_date

--
;with cte as
(select *, row_number() over (partition by customer_id order by order_date) as order_flag
from #customer_orders)
select order_date,
sum(case when order_flag=1 then 1 else 0 end) as new_customer_count,
sum(case when order_flag>1 then 1 else 0 end) as repeat_customer_count
from cte group by order_date

--

;
with cte as (select order_id , customer_id , order_date ,
lag(customer_id)over(partition by customer_id order by order_date) as statements
from #customer_orders)
select order_date,sum(case when statements is null then 1 else 0 end) as new_customer_count,
sum(case when statements is not null then 1 else 0 end) as old_customer_count 
from cte
group by order_date order by order_date

--

;with A as (
select customer_id,order_date,lag(order_date) over (partition by customer_id) 
as previous_visit from #customer_orders)
select order_date,
sum(case when previous_visit is null then 1 else 0 end) as new_customer,
count(*)-sum(case when previous_visit is null then 1 else 0 end) as repeat_customer from A
group by order_date
order by order_date

--

;with cte as (
select *,first_value(order_date) over (partition by customer_id order by order_date)
as first from #customer_orders ) 

select order_date, sum(case when order_date=first then 1 else 0 end) as new,
sum(case when order_date != first then 1 else 0 end) as old from cte group by order_date

--

select order_date, sum(freq) as new_customer_count, 
count(1)-sum(freq) as repeat_customer_count from
(select order_date,case when num > 1 then 0 else 1 end as freq
from
(select *, row_number() over(partition by customer_id) as num 
from customer_orders order by order_date) tab) fin group by order_date;