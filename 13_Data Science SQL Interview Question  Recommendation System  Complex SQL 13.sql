
create table #orders
(
order_id int,
customer_id int,
product_id int,
);

insert into #orders values 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

create table #products (
id int,
name varchar(10)
);
insert into #products values 
(1, 'a'),
(2, 'b'),
(3, 'c'),
(4, 'd'),
(5, 'e');


select * from #orders
select * from #products

--- product pairs most commonly purchased together

select --a1.product_id as P1,a2.product_id as P2,
pr1.name + ' '+pr2.name as pair ,count(1) as freq
from #orders a1
inner join  #orders a2 on a1.order_id= a2.order_id
inner join #products Pr1 on Pr1.id= a1.product_id
inner join #products Pr2 on Pr2.id= a2.product_id
where --a1.order_id=1 and a1.product_id<>a2.product_id
a1.product_id>a2.product_id
--group by  a1.product_id,a2.product_id
group by  pr1.name + ' '+pr2.name

--
;with cte as (
select o1.product_id as p1,o2.product_id as p2,count(*) as purchase_freq
from #orders as o1
inner join #orders as o2 on o1.order_id = o2.order_id
where o1.product_id < o2.product_id
group by o1.product_id ,o2.product_id 
)
select STRING_AGG(name,' ') as product_pair,A.purchase_freq from cte as A
inner join #products as B
on B.id = A.p1 or b.id = A.p2
group by A.p1,A.p2,A.purchase_freq

--

; with cte1 as(
select *,row_number() over(order by order_id,customer_id,product_id) as rn 
from #orders join #products on product_id=id)
,cte2 as (
select name,lead(name) over(order by rn) as leaded from cte1)

select concat(name,' ',leaded) as combo,count(*) as prod_freq from cte2
group by concat(name,' ',leaded) having len(concat(name,' ',leaded))>1

--

with cte as
(
select o.*,p.name from #orders o
join #products p
on o.product_id = p.id
)
select CONCAT(a.name,b.name) as va,count(CONCAT(a.name,b.name))  from cte a
join cte b
on a.product_id < b.product_id
where a.customer_id = b.customer_id
and a.order_id = b.order_id
group by CONCAT(a.name,b.name)

--
;with cte as (
select id,order_id,name,isnull(lag(name) over(partition by order_id order by name),
last_value (name) over(partition by order_id order by name  rows between current row and  unbounded following))as l
from #orders join #products on #orders.product_id = #products.id )
,cte1 as(
select case when name != l then concat(name,l) 
else null end as concatcols from cte )
select *,count(concatcols) as countcols 
from cte1 group by concatcols
having count(concatcols) != 0
order by countcols desc ;

--

