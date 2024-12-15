
/* find largest order by value for each salesperson and display order details
get result without using sub query,cte,window function,temptable */

create table #int_orders(
 [order_number] [int] not null,
 [order_date] [date] not null,
 [cust_id] [int] not null,
 [salesperson_id] [int] not null,
 [amount] [float] not null
) on [primary];

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (30, cast('1995-07-14' as date), 9, 1, 460);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (10, cast('1996-08-02' as date), 4, 2, 540);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (40, cast('1998-01-29' as date), 7, 2, 2400);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (50, cast('1998-02-03' as date), 6, 7, 600);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (60, cast('1998-03-02' as date), 6, 7, 720);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (70, cast('1998-05-06' as date), 9, 7, 150);

insert into #int_orders ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) values (20, cast('1999-01-30' as date), 4, 8, 1800);

select * from #int_orders
--
select a.order_number,a.order_date,a.cust_id,a.salesperson_id,a.amount--MAX(b.amount)
from #int_orders a
inner join #int_orders b on a.salesperson_id = b.salesperson_id
group by a.order_number,a.order_date,a.cust_id,a.salesperson_id,a.amount
having a.amount >=MAX(b.amount)
--
select o.* from #int_orders o left join #int_orders o1
on o.salesperson_id=o1.salesperson_id
and o.amount<o1.amount
where o1.amount is null
order by 1

-- suubquery
select t1.* from int_orders as t1 
inner join (select salesperson_id, max(amount) as max_amnt 
                   from int_orders group by salesperson_id) t2 
on t1.salerperson_id = t2.salesperson_id and t1.amount = t2.max_amnt


--
select s.* from int_orders as s join(
select salesPerson_id,max(amount) as max_amount from int_orders group by salesperson_id) as b on s.amount = b.max_amount


--

with max_sale as (
select salesperson_id, max(amount) as amt
from int_orders)

select a.order_number,a.order_date, a.cust_id,
b.salesperson_id, b.amt
from int_orders a
inner join 
max_sale b
on b.salesperson_id = a.salesperson
AND b.amt = a.amount;

--
Select a.order_number,
            a.order_date, 
            a.cust_id, 
            a.salesperson_id, 
            b.amount 
from int_orders as a
join
(Select salesperson_id, max(amount) as amount from int_orders group by  salesperson_id) as b
     on a.salesperson_id = b.salesperson_id and a.amount = b.amount
order by a.order_number


--

select * from (SELECT * , ROW_NUMBER() OVER(PARTITION BY salesperson_id ORDER BY amount DESC) AS Ranking from int_orders)a where a.Ranking=1;

--

select max(ORDER_NUMBER) ORDER_NUMBER ,max(ORDER_DATE) ORDER_DATE ,max(CUST_ID) CUST_ID,SALESPERSON_ID,max(AMOUNT) AMOUNT
  from int_orders
group by SALESPERSON_ID
having (count(1)=1)
union all
select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id and a.amount > b.amount
 MINUS
 select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id and a.amount < b.amount