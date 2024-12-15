
drop table if exists #tbl_orders
create table #tbl_orders (
order_id integer,
order_date date
);
insert into #tbl_orders
values (1,'2022-10-21'),(2,'2022-10-22'),(3,'2022-10-25'),(4,'2022-10-25');

-- copy of table eod 
select * into #tbl_orders_copy from  #tbl_orders;

select * from #tbl_orders;
select * from #tbl_orders_copy

-- perform operation next day insert/delete
/*
insert into #tbl_orders values (5,'2022-10-26'),(6,'2022-10-26');

delete from #tbl_orders where order_id=1;
*/

-- Solution 

select coalesce(o.order_id,c.order_id) as order_id,
case when c.order_id is null then 'I'
when o.order_id is null then 'D' end as flag
from #tbl_orders  o
full outer join  #tbl_orders_copy  c on o.order_id = c.order_id
where c.order_id is null or o.order_id is null

--

with cte as (
		select oc.order_id, ifnull(o.order_id, 'D') as flag
		from #tbl_orders_copy as oc
		left join #tbl_orders as o using(order_id)
		union
		select o.order_id, ifnull(oc.order_id, 'I') as flag
		from #tbl_orders as o
		left join #tbl_orders_copy as oc using(order_id))
select * from cte where flag in ('D', 'I') 