/* 
MARKET ANALYSIS : Write an SQL query to find for each seller, whether the brand Of the 
second item (by date) they sold is their favourite brand
If a seller sold less than two items, report the answer for that seller as no o/p
seller id 2nd item fav brand
1       yes/ no
2       yes/ no */


create table #users (
user_id         int     ,
join_date       date    ,
favorite_brand  varchar(50));

 create table #orders (
 order_id       int     ,
 order_date     date    ,
 item_id        int     ,
 buyer_id       int     ,
 seller_id      int 
 );

 create table #items
 (
 item_id        int     ,
 item_brand     varchar(50)
 );


 insert into #users values (1,'2019-01-01','Lenovo'),(2,'2019-02-09','Samsung'),(3,'2019-01-19','LG'),(4,'2019-05-21','HP');

 insert into #items values (1,'Samsung'),(2,'Lenovo'),(3,'LG'),(4,'HP');

 insert into #orders values (1,'2019-08-01',4,1,2),(2,'2019-08-02',2,1,3),(3,'2019-08-03',3,2,3),(4,'2019-08-04',1,4,2)
 ,(5,'2019-08-04',1,3,4),(6,'2019-08-05',2,2,4);

 select * from #orders
 select * from #items
 select * from #users 

 ---

;with rnk as (
select *,
rank() over (partition by seller_id order by order_date asc) as rn
from #orders )
select user_id as sellerid,--  ro.*,i.item_brand,
--u.favorite_brand,u.user_id,
case when item_brand=favorite_brand then 'yes' else 'no' end as fav
from #users u
left join rnk ro on u.user_id = ro.seller_id and rn=2
left join #items i on i.item_id= ro.item_id
--where rn=2 


--
; with cte as
 (select *,
 row_number() over (partition by seller_id order by order_date) as rn
 from #orders)
 select user_id as seller_id,
 case when u.favorite_brand = i.item_brand then 'Yes' else 'No' end as item_fav_brand
 from #users u left join cte c on c.seller_id = u.user_id
 left join #items i on c.item_id = i.item_id
 where rn = 2 or rn is null
 order by seller_id;

 --

select user_id, 
case when cnt>=2 and temp.favorite_brand=temp.item_brand then 'Yes' else 'No' end 
as "2nd_item_fav_brand"  from (
select u.user_id,u.favorite_brand,i.item_brand,
rank() over(partition by seller_id order by order_date) as rnk,
count(o.item_id) over(partition by seller_id ) as cnt
from #users u 
left join #orders o on o.seller_id = u.user_id 
left join #items i on i.item_id=o.item_id
) temp where rnk=2 or cnt=0

--
select seller_id, case when item_brand = favorite_brand then 'yes' else 'no' end as fav 
from(
select *,row_number() over (partition by seller_id order by order_date asc) as rn 
from #orders)a
inner join #items i      on a.item_id = i.item_id
left outer join #users u on a.seller_id = u.user_id
where rn =2
union
select u.user_id as seller_id,'no' 
from #users u 
left outer join #orders o on u.user_id = o.seller_id 
group by u.user_id having count(1) <2