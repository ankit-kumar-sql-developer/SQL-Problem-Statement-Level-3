
--write a sql to find cities where not even a single order was returned
-- Joins,Aggregation, Filters

create table #namaste_orders
(
order_id int,
city varchar(10),
sales int
)

create table #namaste_returns
(
order_id int,
return_reason varchar(20),
)

insert into #namaste_orders
values(1, 'Mysore' , 100),(2, 'Mysore' , 200),(3, 'Bangalore' , 250),(4, 'Bangalore' , 150)
,(5, 'Mumbai' , 300),(6, 'Mumbai' , 500),(7, 'Mumbai' , 800)
;
insert into #namaste_returns values
(3,'wrong item'),(6,'bad quality'),(7,'wrong item');


select * from #namaste_orders
select * from #namaste_returns

---

select a.city, COUNT(b.order_id) as no_of_returned_orders
from #namaste_orders a
left join  #namaste_returns b on a.order_id= b.order_id
group by a.city having COUNT(b.order_id)=0
-- where b.order_id is null is wrong

--
select distinct city from #namaste_orders
where city not in (
select distinct city from #namaste_orders
where order_id in ( select order_id from #namaste_returns ) ) 


--

select e.city from
(select city, sum(case when return_reason is null then 1 else 0 end) as return_status from
(select * from namaste_orders no left join namaste_returns nr 
on no.order_id = nr.order_id)q
group by city)e
join
(select city, count(city) from namaste_orders group by city)d
on e.city = d.city
where return_status = count;


--
with cte as(select city,sales,nr.* from namaste_orders no
left join namaste_returns nr
on no.order_id = nr.order_id)
select city
from cte
group by city 
having sum(order_id) is null

--

select city from namaste_orders
except
select city from namaste_orders where order_id in (select order_id from namaste_returns)

--

select select 
distinct city
from namaste_orders t1
left join namaste_returns t2
on t1.order_id=t2.order_id
group by city
having count(city) = sum(case when return_reason is null then 1 else -1 end)