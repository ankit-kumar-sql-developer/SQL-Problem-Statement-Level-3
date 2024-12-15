/*--1 TC Infotech SQL Interview Question - > 3 solutions
--remove duplicate in case of source, destination, distance are same and keep the first value only
--first 2 solution i will not guarantee first row will come first */


create table #city_distance
(
    distance int,
    source varchar(512),
    destination varchar(512)
);

delete from #city_distance;
insert into #city_distance(distance, source, destination) values ('100', 'new delhi', 'panipat');
insert into #city_distance(distance, source, destination) values ('200', 'ambala', 'new delhi');
insert into #city_distance(distance, source, destination) values ('150', 'bangalore', 'mysore');
insert into #city_distance(distance, source, destination) values ('150', 'mysore', 'bangalore');
insert into #city_distance(distance, source, destination) values ('250', 'mumbai', 'pune');
insert into #city_distance(distance, source, destination) values ('250', 'pune', 'mumbai');
insert into #city_distance(distance, source, destination) values ('2500', 'chennai', 'bhopal');
insert into #city_distance(distance, source, destination) values ('2500', 'bhopal', 'chennai');
insert into #city_distance(distance, source, destination) values ('60', 'tirupati', 'tirumala');
insert into #city_distance(distance, source, destination) values ('80', 'tirumala', 'tirupati');


select * from #city_distance

-- Method 1
select a1.* ,a2.*
from #city_distance a1
left join #city_distance a2  on a1.source= a2.destination
and a1.destination= a2.source
where a2.distance is null or a1.distance<>a2.distance
or a1.source<a1.destination

-- Method 2

; with cte as (
select *,
case when source<destination then source else destination end as city1,
case when source<destination then destination else source end as city2
from #city_distance a1)
, cte2 as (
select *, COUNT(*) over (partition by city1,city2,distance) as cnt 
from cte)

select distance,source,destination 
from cte2 where cnt=1 or (source<destination)


-- Method 3

; with cte as (
select *,ROW_NUMBER() over (order by (select null)) as rn
from  #city_distance ) 

select a1.*
from cte a1
left join cte a2  on a1.source= a2.destination
and a1.destination= a2.source
where a2.distance is null or a1.distance<>a2.distance
or a1.rn<a2.rn

--
with cte as (
select *, lag(source, 1,1) over (order by (select null)) as prev_source, lag(distance, 1,1) over (order by (select null)) as prev_distance
from #city_distance)
select distance, source, destination
from cte
where NOT(destination = prev_source and distance = prev_distance)

--
select distance,source,destination from (
select *, rank() over(partition by distance order by source desc ) as rnk from #city_distance ) a 
where rnk = 1

--
select * from (
select t1.*,ROW_NUMBER() over(partition by t1.distance order by t1.distance) as rnk
from city_distance as t1
left join
#city_distance  as t2
on t1.source = t2.destination and t1.destination = t2.source ) as t
where rnk =1;

--

with cte as
(
	select *,
	row_number() over(order by (select null)) as rn
	from _66_city_distance
),
cte2 as
(
	select a.distance as adist, a.source as asrc, a.destination as adest, a.rn as arn
	from cte as a
	join cte as b
	on a.source = b.destination
	and a.destination = b.source 
	and a.distance = b.distance
	where a.rn%2 = 0
)
select *
from cte
except
select * from cte2
order by rn

--

select *, ROW_NUMBER() OVER (PARTITION BY distance ORDER BY distance) as rnk FROM city_distance
)

select c.source,c.destination,c.distance FROM cte1 LEFT JOIN city_distance c
WHERE c.source =cte1.source AND c.destination=cte1.destination AND rnk=1;

--
with cte as 
(select *, lag(source,1) over (partition by distance order by distance)prev_source,
lead(source,1) over (partition by distance order by distance)next_source,
count(*) over (partition by distance)cnt_dist
from 
city_distance)


select distance, source, destination from cte
where cnt_dist = 1 or source < destination



--
with mycte as 
(
	select *,
	case when source < destination then concat(distance, source, destination) else concat(distance, destination, source) end as keyvalue
	from city_distance
)
select distance, source, destination from
(
select *,
row_number() over(partition by keyvalue order by source, destination) as rn
from mycte
) as x
where rn = 1

--
with cte as(
select *,
case when source=lead(destination) OVER(order by (select 1)) and 
destination=lead(source) OVER(order by (select 1)) then 1 
when source=lag(destination) OVER(order by (select 1)) and
destination=lag(source) OVER(order by (select 1)) and 
distance=lag(distance) OVER(order by (select 1)) then 2
else 0 end as val
from city_distance)
select distance, source, destination
from cte
where val=0 or val=1;

-- solved it without ascii value or lag:
with cte as (select *,row_number()over() from city_distance)

select * from cte c1
full outer join cte c2 on
c1.source=c2.destination and c1.destination=c2.source and c1.distance=c2.distance 
where c1.row_number is not null and coalesce(c1.row_number,0)>coalesce(c2.row_number,0)

--

with cte as(
Select *
, ROW_NUMBER() over(order by (select null)) as rn
from city_distance 
)
SELECT * FROM city_distance
EXCEPT
select t1.distance, t1.source, t1.destination
from cte t1 inner join cte t2
on t1.source = t2.destination and t1.destination = t2.source and t1.distance = t2.distance and t1.rn > t2.rn;



--
with cte as (
select *, 
case when lower(source) > lower(destination) then source else destination end as city1, 
case when lower(source) > lower(destination) then destination else source end as city2
from city_distance
), 
cte2 as (
select city1, city2, distance, 
row_number() over(partition by city1, city2,distance order by source) as rn
from cte 
)
select * from cte2 where rn = 1; 

--

with cte as (
select *, 
case when lower(source) > lower(destination) then concat(source, ' ', destination) 
else concat(destination, ' ', source) end as concat_col
from #city_distance),
cte2 as (
select *, row_number() over(partition by concat_col, distance) rn
from cte
)
select cte2.distance, cte2.source, cte2.destination 
from cte2 where rn = 1;

--

with cte as (
select distance,source,destination,
row_number() over(partition by distance order by distance asc) as rn 
from #city_distance )

select distinct(distance), case when rn=2 then destination else source end as source,
case when rn=2 then source else destination end as destination
from cte group by distance,source,destination,rn
order by distance asc;

--

WITH RankedCities AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY distance, 
	CONCAT(CASE WHEN source < destination THEN source ELSE destination END,
    CASE WHEN source < destination THEN destination ELSE source END,',')
    ORDER BY distance) AS rnk
    FROM #city_distance
)
SELECT distance,source,destination
FROM RankedCities
WHERE rnk = 1;

--
WITH RankedCities AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY distance
    ORDER BY distance) AS rnk
    FROM #city_distance
)
SELECT distance,source,destination
FROM RankedCities
WHERE rnk = 1;


--

with cte as (
select *, ROW_NUMBER() over (partition by least(source, destination) , 
greatest(source, destination), DISTANCE order by distance) as rn
from #city_distance)

SELECT * FROM cte
WHERE rn = 1

--

with cte as (select distance,FIRST_VALUE(source)over(partition by distance order by (select 1 )) as source,FIRST_VALUE(destination)over(partition by distance order by (select 1 )) destination from city_distance)
select distinct distance,source,destination from cte;

--

SELECT *
FROM 
(SELECT *, LAG(destination) OVER(PARTITION BY distance ORDER BY distance ) as lagg

FROM #city_distance) city_d
WHERE lagg is NULL

--

