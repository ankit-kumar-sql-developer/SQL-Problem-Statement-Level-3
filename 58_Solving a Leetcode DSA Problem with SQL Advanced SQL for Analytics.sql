-- to get start city and end city of each customer
create table #travel_data (
    customer varchar(10),
    start_loc varchar(50),
    end_loc varchar(50)
);

insert into #travel_data (customer, start_loc, end_loc) values
    ('c1', 'new york', 'lima'),
    ('c1', 'london', 'new york'),
    ('c1', 'lima', 'sao paulo'),
    ('c1', 'sao paulo', 'new delhi'),
    ('c2', 'mumbai', 'hyderabad'),
    ('c2', 'surat', 'pune'),
    ('c2', 'hyderabad', 'surat'),
    ('c3', 'kochi', 'kurnool'),
    ('c3', 'lucknow', 'agra'),
    ('c3', 'agra', 'jaipur'),
    ('c3', 'jaipur', 'kochi');


select * from #travel_data

-- Method 1

; with cte as (
select customer,start_loc as loc,'start loc' as column_name from #travel_data
union all
select customer,end_loc as loc,'end' as column_name from #travel_data )
,cte2 as (
select *, COUNT(*) over (partition by customer,loc) as cnt
from cte  )
select customer,
MAX(case when column_name='start loc' then loc else null end )as start_loc,
MAX(case when column_name='end' then loc else null end) as end_loc
from cte2  Where cnt=1 group by customer


-- Method 2 

select td.customer,
max(case when td1.end_loc is null then td.start_loc end)  as starting_location,
max(case when td2.start_loc is null then td.end_loc end) as end_location
from #travel_data td
left join #travel_data td1 on td.customer=td1.customer and td.start_loc= td1.end_loc
left join #travel_data td2 on td.customer=td2.customer and td.end_loc= td2.start_loc
group by td.customer

--
select A.customer, start_loc,end_loc from 
 (select customer ,start_loc from cte 
	except
 select customer ,end_loc from cte 
 )A,
 (
 select customer ,end_loc from cte 
	except
 select customer ,start_loc from cte 
 )B
 where A.customer = B.customer

 --
 select customer,
min(case when start_loc not in(select end_loc from travel_data) then start_loc end )as start_point
,max(case when end_loc not in(select start_loc from travel_data) then end_loc end )as destination
from travel_data group by customer ;

--

select coalesce(a.customer,b.customer),max(a.start_loc),max(b.end_loc) from 
#travel_data a full join 
#travel_data b  on a.customer=b.customer and a.start_loc=b.end_loc
where a.start_loc is null or b.end_loc is null
group by coalesce(a.customer,b.customer)


--

;with start_location as (
select customer,start_loc
from travel_data
except
select customer,end_loc
from travel_data
)
,end_location as (
select customer,end_loc
from travel_data
except
select customer,start_loc
from travel_data
)
select sl.*,el.end_loc from start_location sl
inner join end_location el  on sl.customer=el.customer

--
with cte as(

select customer, start_loc as Initial_loc, Null as end_loc  from travel_data where start_loc not in (select end_loc from travel_data)

union

select customer, Null as Initial_loc, end_loc from travel_data where end_loc not in (select start_loc from travel_data)

)
 
select customer, MAX(Initial_loc) as Initial_loc,MAX(end_loc) as end_loc from cte 
group by customer

--

--
with recursive cte1 as
(select customer,start_loc,end_loc,0 as sot from travel_data
union all
SELECT cte1.customer,cte1.start_loc,t.end_loc,sot+1 as sot from cte1 join travel_data t on cte1.customer = t.customer
and cte1.end_loc = t.start_loc)
,cte2 as
(select customer,max(sot) st from cte1 group by customer)

select customer,start_loc,end_loc from cte1 join cte2 using(customer) where sot=st order by customer



--using co-related subqueries):

with cte1 as(
	select customer, start_loc as initial_loc
	from travel_data t1
	where t1.start_loc not in (select end_loc from travel_data t2 where t1.customer = t2.customer)),
	cte2 as(
	select customer, end_loc as last_loc
	from travel_data t1
	where t1.end_loc not in (select start_loc from travel_data t2 where t1.customer = t2.customer))

	select cte1.customer, cte1.initial_loc, cte2.last_loc 
	from cte1 join cte2 on cte1.customer = cte2.customer

--
with cte1 as 
(select td1.customer, td1.start_loc, td1.end_loc from travel_data td1
left join travel_data td2 on td1.start_loc = td2.end_loc
where td2.customer is null
),
cte2 as(
select td1.customer, td1.start_loc, td1.end_loc from travel_data td1
left join travel_data td2 on td1.end_loc = td2.start_loc
where td2.customer is null
)

select cte1.customer, cte1.start_loc,  cte2.end_loc from 
cte1 cte1 inner join cte2 cte2 on cte1.customer = cte2.customer


--

sELECT a.customer,a.start_loc,b.end_loc
from
(
select a.customer,a.start_loc  as start_loc from #travel_data a
left join #travel_data b on(a.start_loc=b.end_loc)
where b.end_loc IS NULL
)a

INNER JOIN
(
select a.customer,a.end_loc  as end_loc from #travel_data a
left join #travel_data b on(a.end_loc=b.start_loc)
where b.start_loc IS NULL
)b on(a.customer=b.customer)



--
with a as (
select customer, start_loc start
from travel_data
except 
select customer, end_loc start
from travel_data),

bb as (
select b.customer, b.start_loc, b.end_loc, start
from travel_data b left join a on b.customer=a.customer and b.start_loc=a.start
)

,rec as (
select customer, 1 level, start_loc, end_loc
from bb where start is not null
union all
select bb.customer, level +1 level, bb.start_loc, bb.end_loc
from rec
inner join bb on rec.customer=bb.customer and rec.end_loc=bb.start_loc
)

select distinct customer
, first_value(start_loc) over(partition by customer order by level) sl
,first_value(end_loc) over(partition by customer order by level desc) fl
from rec
order by 1, 2