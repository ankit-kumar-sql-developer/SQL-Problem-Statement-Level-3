--business_city table has data from the day udaan has started operation
--write a SQL to identify yearwise count of new cities where udaan started their operations


create table #business_city (
business_date date,
city_id int
);
delete from #business_city;
insert into #business_city
values(cast('2020-01-02' as date),3),(cast('2020-07-01' as date),7),(cast('2021-01-01' as date),3),(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3),(cast('2022-12-15' as date),3),(cast('2022-02-28' as date),12);

select * from #business_city

--
;with cte as (
select DATEPART(year,business_date) as yr, city_id
from #business_city )
select a.yr,COUNT(distinct case when b.city_id is null then a.city_id end) as newcity
from cte a 
left join  cte b on a.yr>b.yr and a.city_id=b.city_id
group by a.yr


--
; WITH cte1 AS(
SELECT MIN(YEAR(business_date)) as "year", city_id FROM #business_city
GROUP BY city_id )

SELECT year, COUNT(city_id) AS no_of_city FROM cte1
GROUP BY year;

--
select YEAR(business_date),count(city_id)
from(select *,DENSE_RANK()over(partition by city_id order by business_date) rn 
from #business_city) x
where x.rn=1
group by year(business_date)

--

With CTE AS ( 
Select *,
Year(business_date)  AS Year_business,
row_number() over (partition by city_id order by business_date) AS rn
from business_city
)
Select Year_business,Count(1) as new_cities
from CTE
where rn=1
group by Year_business

--

with city_count as (select *,
							COUNT(city_id) over(partition by city_id order by year(business_date)) [new city count per year]
						from business_city)

select YEAR(business_date), SUM([new city count per year])
from city_count
where [new city count per year] = 1
group by YEAR(business_date)

--

; with cte as(select *,
lag(business_date,1) over(partition by city_id order by business_date) as prev_city_date
from #business_city )
select datepart(year,business_date) as year,count(city_id) as new_cities
from cte
where prev_city_date is null
group by datepart(year,business_date)
order by datepart(year,business_date)

--
with cte as (select distinct city_id, min(business_date) as first_date from #business_city
group by city_id)
select year(first_date) as year, count(city_id) as cnt from cte
group by year(first_date)

--


select year(min_date), count(*) from 
(select min(business_date) min_date, city_id from #business_city 
group by city_id) s 
group by year(min_date);

--
select a.year,
sum(case when a.rn = 1 then 1 else 0 end) new_cities from
(select year(business_date) year, city_id, row_number() over (partition by city_id) rn
from business_city) a 
group by 1

--
select YEAR(business_date) as Year, count(city_id) as New_Cities_Cnt from (
Select *, count(*) over(partition by city_id order by business_date) as cnt
from #business_city) A
where cnt = 1
Group by YEAR(business_date)
order by YEAR(business_date)

--
select businessdate,count(cities) from 
(
select year(business_date) as businessdate,city_id as cities,
lag(city_id,1,999) over (order by city_id) as lg
from #business_city
) p
where p.lg<>p.cities
group by businessdate

--

with cte as(
select  distinct city_id , year(business_date) year, lag(city_id, 1) over(order by city_id) prev_city from business_city)

select 
counT(case when prev_city is null or city_id <> prev_city then 1 else null end ) city_count, year
from 
cte group by year;

--
with cte AS
(select *,datepart(year,business_date) as year,
row_number() over(partition by city_id order by business_date) as rn
from business_city)



select year,sum(rn) from cte
where rn=1
group by year;

--

with cte1 as (select *,
row_number() over(partition by city_id order by business_date) as rn
from business_city)

select datepart(year, business_date) as year, count(1) 
from cte1 where rn=1
group by datepart(year, business_date)

--

with cte as(
select business_date,city_id from Business_city where city_id
not in(
select city_id from Business_city where business_date in
(select min(business_date) from Business_city))
union 
select business_date,city_id from Business_city where business_date in
(select min(business_date) from Business_city)
)

select business_date,count(city_id) from cte group by business_date


-- ###corelated subquery solution

select business_date,
sum(case when city_id in(select city_id from business_city b2 where b2.business_date<b1.business_date) then 0 else 1 end) as new_cities
from business_city b1
group by business_date

--