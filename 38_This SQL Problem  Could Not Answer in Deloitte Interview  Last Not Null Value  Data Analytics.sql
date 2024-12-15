


create table #brands 
(
category varchar(20),
brand_name varchar(20)
);
insert into #brands values
('chocolates','5-star')
,(null,'dairy milk')
,(null,'perk')
,(null,'eclair')
,('Biscuits','britannia')
,(null,'good day')
,(null,'boost');

select * from #brands

--
; with cte1 as (
select *,
ROW_NUMBER() over ( order by (select null)) as rn
from #brands )
,cte2 as (
select *,
LEAD(rn,1) over (order by rn) as next_rn
from cte1 
where category is not null )
select b.category,a.brand_name
from
cte1 a
inner join cte2 b on a.rn >= b.rn and (a.rn <= b.next_rn-1 or b.next_rn is null)



--
;with cte as(
select *,row_number() over(order by (select null)) as rn from #brands)
,cte1 as (
select *,count(category) over(order by rn) cnt from cte)
select first_value(category) over(partition by cnt order by rn) as category ,
brand_name from cte1;

--
select * 
, MIN(category)over(order by (select NULL) rows between unbounded preceding and current row) as NEW_CATEGORY
from #brands;
--
--
select *, coalesce(category ,lead(category) IGNORE NULLS over(order by (select null))) 
from brands

--
with cte1 as (
select * , 
row_number() over(order by (select null)) rn  
from #brands
)
select *, min(category) over(order by rn rows
between unbounded preceding and current row) category, 
brand_name from cte1

--

;with cte1 as
(select *,
row_number() over(order by (select null)) as id,
case when category is null then 0 else 1 end as rn
from #brands 
)
,cte2 as
(select *
,sum(rn) over(order by id) as roll_sum
from cte1
)
select brand_name,
max(category) over(partition by roll_sum) as category
from cte2

--
with cte as(

select *,ROW_NUMBER() over(order by (select null)) rn
from brands)
,cte1 as(
select *,lead(rn-1,1,9999) over(order by rn) btw
from cte 
where category is not null
)
select c1.category,c.brand_name
from cte c inner join cte1 c1 on c.rn between c1.rn and c1.btw

--


-- loop

select *,row_number() over(order by (select null)) as rw  into #brands1 from #brands
--drop table #brands
select * from #brands1
declare @rw int
set @rw=1
while (@rw<=6)
begin
declare @rw1 varchar(20),@rw2 varchar(20)
set @rw1=(select isnull(category,'X') from #brands1 where rw=@rw)
set @rw2=(select isnull(category,'X') from #brands1 where rw=(@rw+1))
if( @rw1 != @rw2 and @rw2='X')
begin
update #brands1 set Category=@rw1 where rw=(@rw+1)
end;
if( @rw1 != @rw2 and @rw2 !='X')
begin
update #brands1 set Category=@rw2 where rw=(@rw+1)
end;
set @rw=@rw+1
end;
select * from #brands1

--
with a as (
select *
,case when category is not null then row_number() over(order by (select null)) end crn
,row_number() over(order by (select null)) cn
from brands),

b as (
select max(cn) mxcn
from a),

c as (
select category, crn mn, lead(crn,1, (select mxcn from b)+1) over(order by crn)-1 mx
from a 
where category is not null),

rec as (
select category, mn, mx
from c
union all
select category, mn+1, mx
from rec
where mn<mx)

select rec.category, a.brand_name
from a join rec on a.cn=rec.mn
order by 1 desc

--

with recursive filled_categories as (
select id, category, brand_name
from brands
where id = 1
union all
select 
	b.id,
	case when b.category is not null then b.category else fc.category end as category,
	b.brand_name
    from brands b
join filled_categories fc on b.id = fc.id + 1
)
select 
    category,
    brand_name
from filled_categories
order by id;