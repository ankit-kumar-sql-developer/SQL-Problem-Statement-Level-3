/*--customer retentii and customer churn metrics

--customer retention
Customer retention refers to a company's ability to turn customers into repeat buyers
and prevent them from switching to a competitor.
It indicates whether your product and the quality of your service please your existing customers
reward programs (cc companies) wallet cash back (paytm/gpay) zomato pro / swiggy super


*/

create table #transactions(
order_id int,
cust_id int,
order_date date,
amount int
);
delete from #transactions;
insert into #transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;

select * from #transactions ;

-- retention period
-- Jan  0 , Feb 1 For ID=1,2,3

select month(t1.order_date), count( distinct t2.cust_id)
from #transactions  t1
left join #transactions t2 on t1.cust_id= t2.cust_id
and datediff(month,t2.order_date,t1.order_date) =1
group by month(t1.order_date)

-- Ankit
;with cte as (
select *,
datediff(month,order_date,lag(order_date) over (partition by cust_id order by order_date))
as rn,
datediff(month,order_date,lead(order_date) over (partition by cust_id order by order_date))
as rn2 from #transactions )

select month(order_date),
sum(case when rn=-1 then 1 else 0 end)  as cnt
from cte  
where  rn=-1 or rn2 =1
group by month(order_date) 

--
;with cte as(
select * 
,row_number() over (partition by cust_id order by order_date) as rn
from #transactions)
select month(order_date) as month_date,
count(case when rn=2 then cust_id else null end) as last_mont_cust
from cte
group by month(order_date)

--
;
with cte as (
select * , first_value(order_date) over(partition by cust_id order by order_date) as first_order_date,
last_value(order_date ) over(partition by cust_id order by order_date) as last_order_date
from #transactions )
,cte2 as ( 
select month(order_date) as months, 
sum(case when (order_date < first_order_date) then 1 else 0 end ) as l1,
sum(case when (order_date > first_order_date) then 1 else 0 end ) as l2
from cte 
group by month(order_date) )
select c2.months,(c2.l1+c2.l2) as cx  from cte2 c2 
join cte2 c3 on c2.months = c3.months

--

; with CTE as
(select month(order_date) as month
,month(order_date)-month(coalesce(lag(order_date) over(partition by cust_id order by cust_id), order_date)) as prev_month
from #transactions)
select month, sum(prev_month) as retained_cust
from CTE
group by month

--
;with cte as(
SELECT datepart(month, order_date) as month, 
--lag(cust_id) over (Partition by cust_id order by order_date),
case when lag(cust_id) over (Partition by cust_id order by order_date) = cust_id then 1 else 0 end as retention
from #transactions
  )
SELECT month, sum(retention) as retentions
from cte
GROUP by month

--

select DATENAME(MONTH, order_date), sum(rnk) from (
select *, DENSE_RANK() over(partition by cust_id order by  month(order_date))-1  as rnk
from #transactions) a
group by DATENAME(MONTH, order_date), MONTH(order_date)

--
; with retention_map as (
Select *, count(1) over(partition by cust_id order by order_date rows
between unbounded preceding and current row)  as retention_map 
from #transactions ) 
select  month(  order_date) as month , 
sum( case when  retention_map > 1 then 1 else 0 end)  as retetion_count
from retention_map
group by  month(  order_date)

--
/*

my question to you is: if the same customer returns back in the month of April after Feb so the output should be

01  0
02  3
04  0

and the same customer has an entry in the month of May then the output would look like:

01  0
02  3
04  0
05  1

Is this correct? 


so my query is below :

with cust_check as (
	select cust_id , next_order_date , previous_order_date, case when previous_order_date = 0 then 0 
						  when previous_order_date != 0 then period_diff(date_format(next_order_date, "%Y%m") , date_format(previous_order_date,"%Y%m"))
						  end as month_diff from
	(                      
		select cust_id , order_date as next_order_date , lag(order_date , 1 , 0) 
		over(partition by cust_id order by cust_id) as previous_order_date  from 
        (select * from transactions order by cust_id , order_date) as a
	) as a
) ,
final as (
	select a.cust_id , year(a.next_order_date) as year_of_date , month(a.next_order_date) as month_of_date , 
     a.previous_order_date , a.month_diff 
    from cust_check as a inner join
	(select cust_id , count(cust_id) as c from cust_check group by cust_id having count(cust_id) > 1) as b
	on a.cust_id = b.cust_id and a.month_diff in (0,1)
)
select year_of_date , month_of_date , sum(month_diff) as no_of_returning from final 
group by year_of_date , month_of_date;



with t1 as
(select cust_id,order_date,lead(order_date) over(partition by cust_id order by order_date) as next_order_date,
 date_part('month',lead(order_date) over(partition by cust_id order by order_date)) - date_part('month',order_date) as diff_between_orders
 from transactions)

select date_part('month',next_order_date) as month, 
	coalesce(sum(case when diff_between_orders = 1 then 1 
			 when diff_between_orders = 0 then 0 end),0) as number_retention 
from t1 
where diff_between_orders is not null
group by 1
order by 1 asc;

*/