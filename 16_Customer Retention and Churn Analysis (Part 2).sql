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
-- customer chunk

select month(t2.order_date), count( distinct t2.cust_id)
from #transactions  t2
left join #transactions t1 on t1.cust_id= t2.cust_id
and datediff(month,t2.order_date,t1.order_date) =1
where t1.cust_id is null
group by month(t2.order_date)



/*
select month(t2.order_date),*,datediff(month,t2.order_date,t1.order_date)
from #transactions  t2
left join #transactions t1 on t1.cust_id= t2.cust_id
and datediff(month,t2.order_date,t1.order_date) =1

select month(t2.order_date),*,datediff(month,t2.order_date,t1.order_date)
from #transactions  t2
left join #transactions t1 on t1.cust_id= t2.cust_id
*/


--

select MONTH(order_date) as retained_month,
sum(case when datediff(month,order_date,next_mon)=1 then 1 else 0 end) as retention_count,
sum (case when next_mon is null then 1 else 0 end) as churn_count
from 
(select *,
lead(order_date) over(partition by cust_id order by order_date) as next_mon
from #transactions
)o
group by MONTH(order_date);

--

; with temp1 as(
select * , lead(order_date,1,order_date) over (partition by cust_id order by order_date) as lastdate from #transactions
)
select month(order_date), sum(case when month(order_date)-month(lastdate)=0 then 1 else 0 end) as custtt 
from temp1 group by month(order_date)

--Retention Query: 
; with retention_map as (
Select *, count(1) over(partition by cust_id order by order_date rows between unbounded preceding and current row)  as retention_map 
from #transactions ) 
select   month(  order_date) as month , sum( case when  retention_map > 1 then 1 else 0 end)  as retetion_count
from retention_map
group by  month(  order_date) 

--Churn query: 
; with churn_map as (
Select *, count(1) over(partition by cust_id order by order_date rows between current row and unbounded following)  as churn_map 
from #transactions ) 
select   month(  order_date) as month , sum( case when  churn_map > 1 then 0 else 1 end)  as churn_count
from churn_map
group by  month(  order_date) ;


--
with ctre as (
select *,lead(order_date) over(partition by cust_id order by order_date) as nxt_mnth 
from #transactions )
select month(order_date),count(1),Count(nxt_mnth),
count(1)-count(nxt_mnth) as churn_cust from ctre
group by month(order_date)

--

select month(order_date),count(cust_id) from
(
select cust_id, order_date, 
lead(order_date,1) over(partition by cust_id order by order_date)  as next_date
from #transactions
) z where next_date is null
group by month(order_date)

--
; with cte as(
select *,
       DATEDIFF(month,order_date,lead(order_date) over(partition by cust_id order by order_Date)) as diff 
from #transactions)
select month(order_Date) as month,
       sum(case when diff is null then 1 else 0 end) as cnt 
from cte 
group by MONTH(order_date);

--

select 
	month(t1.order_date),
    100 - (count(case when (month(t2.order_date) - month(t1.order_date) =  1) then t1.cust_id else null end) * 100 /
    count(distinct t1.cust_id)) as one_month_churn
from 
	#transactions t1
    join
    #transactions t2 on t1.cust_id = t2.cust_id
group by month(t1.order_date)
order by month(t1.order_date)

--

with cte_retention as 
	(
		Select *,
		lead(order_date) over(partition by cust_id order by order_date) as next_order
		from transactionsT
	)
Select 
Datename(month,order_date) as Order_month
,sum(case when next_order is null then 1 else 0 end ) as Count_of_Retention
from cte_retention c
group by Datename(month,order_date)
order by Order_month desc

--

--Using joins
CHURN:

select  month(current.order_date ) as months, 
        sum( case when current.cust_id = next.cust_id then 0 else 1 end ) as churn
from transactions current
left join transactions next 
on  current.cust_id = next.cust_id and month(next.order_date)- month(current.order_date) =1 
group by month(current.order_date )
order by month(current.order_date );

--RETENTION: 
select month(current.order_date) months, 
       sum(case when current.cust_id = next.cust_id then 1 else 0 end) as retention 
from transactions current 
left join transactions next 
on current.cust_id =next.cust_id and month(current.order_date)- month(next.order_date) = 1
group by month(current.order_date)
order by month(current.order_date);

--
/* Customer retention and churn analysis */
/* Part 1 */



/* hints 

> first, I have extract the month from current order date for order id and then take the month of previous order if available otherwise it will give 'null' 

> then took difference of the current order month and previous order month. If the difference is 1, that means the customer is retained (means he shopped last month and also current month)

> then I have used case statement if month_diff = 1 then 1 and If null (means no previous month shopping) then 0 and then take summation over month_diff to take out the no_customer_retention

*/




/*Solution */ part 1





select * from transactions ;



with t1 as

	(select order_id,cust_id, date_part('month',order_date) as current_order_month,

		lag(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as prev_order_month,

	 	date_part('month',order_date) - lag(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as month_diff

	 from transactions)



select current_order_month,

	sum(case when month_diff = 1 then 1  

		when month_diff is null then 0 end) as no_retention 

from t1 

group by current_order_month

order by current_order_month asc  ;







/* Part 2 */




-
-customer churn by month (churn is something,suppose cust A bought something in Jan but not in Feb that means in Jan, there is a churn cause cust A didn't buy anything in feb. 

here my result is 

month no_churn

  1       1

  2       4

 -- that's because cust 4 has bought in jan but no in february (next month after jan) so it's a churn

  and as well as, we have no data for march that means there no_churn is 4. there might be a question that we have 5 customers. but think concisely, cust 4 didn't buy anything in feb, so that means in march for cust 4 that won't be counted as churn.

    retention related to purchase in next month after purchase something in previous month

    churn related to purchase in current month but not in next month.

    

with t1 as

	(select order_id,cust_id, date_part('month',order_date) as current_order_month,

		lead(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as next_order_month,

	 	lead(date_part('month',order_date)) over (partition by cust_id order by order_date asc) - date_part('month',order_date) as month_diff

	 from transactions)



select current_order_month,

	sum(case when month_diff > 1 then 1  

		when month_diff is null then 1 end) as no_churn	

from t1 

group by current_order_month

order by current_order_month asc 