
-- MEESHO HACKERRANK ONLINE SQL TEST
-- find how many roducts falls into customer budget along with list of products
-- In case of clash choose the less costly product


create table #products
(
product_id varchar(20) ,
cost int
);
insert into #products values ('P1',200),('P2',300),('P3',500),('P4',800);

create table #customer_budget
(
customer_id int,
budget int
);

insert into #customer_budget values (100,400),(200,800),(300,1500);

select * from #customer_budget
select * from #products

--
; with cte as (
select *, SUM(cost) over (order by cost) as r_cost
from #products p )

select customer_id, budget,COUNT(1) as cnt, STRING_AGG(product_id,',') as list
from  #customer_budget b 
left join cte a  on a.r_cost< b.budget
group by customer_id, budget

--

  ;with cte as(
  SELECT *, sum(cost) over (Partition by customer_id order by cost) as running_cost FROM
  #customer_budget c cross join #products p
 )
 SELECT customer_id, budget, String_agg(product_id, ',') as list_of_products, 
 COUNT(1) as no_of_products
 FROM cte
 where running_cost<=budget
 GROUP by customer_id, budget

 -- In case of clash choose highest product
  select * from #products
  select * from #customer_budget

  -- 3rd Budget
; with cte as (
select *, SUM(cost) over (order by cost desc) as r_cost
from #products p )

select customer_id, budget,COUNT(1) as cnt, STRING_AGG(product_id,',') as list
from  #customer_budget b 
left join cte a  on a.r_cost< b.budget
group by customer_id, budget

 select * from #products

-- 1st Budget

select distinct customer_id, budget,COUNT(1) as cnt, 
STRING_AGG( a.product_id,',') as list
from  #customer_budget b 
left join   #products a  on a.cost< b.budget
inner  join #products c  on a.cost > c.cost
where b.budget = 800
group by customer_id, budget

-- 1st Budget

select distinct customer_id, budget,COUNT(1) as cnt, 
STRING_AGG( a.product_id,',') as list
from  #customer_budget b 
left join   #products a  on a.cost< b.budget
inner  join #products c  on a.cost > c.cost
where b.budget = 400
group by customer_id, budget

