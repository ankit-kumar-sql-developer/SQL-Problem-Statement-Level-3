
--- find cities covid case are increasing  continuosly

create table #covid(city varchar(50),days date,cases int);
delete from #covid;
insert into #covid values('DELHI','2022-01-01',100);
insert into #covid values('DELHI','2022-01-02',200);
insert into #covid values('DELHI','2022-01-03',300);

insert into #covid values('MUMBAI','2022-01-01',100);
insert into #covid values('MUMBAI','2022-01-02',100);
insert into #covid values('MUMBAI','2022-01-03',300);

insert into #covid values('CHENNAI','2022-01-01',100);
insert into #covid values('CHENNAI','2022-01-02',200);
insert into #covid values('CHENNAI','2022-01-03',150);

insert into #covid values('BANGALORE','2022-01-01',100);
insert into #covid values('BANGALORE','2022-01-02',300);
insert into #covid values('BANGALORE','2022-01-03',200);
insert into #covid values('BANGALORE','2022-01-04',400);


select * from #covid

--
; with cte as (
select *,
rank() over (partition by city order by days asc)-
rank() over (partition by city order by cases asc) as diff
from #covid )

select city
from cte group by city
having COUNT(distinct diff) =1 and avg(diff)=0

--
With cte as(
Select *,lag(cases,1,0) over(partition by city order by days asc) as previous_cases from #covid
)
Select city from cte
group by city
having sum(case when cases>previous_cases then 0 else 1 end)=0;

--
select distinct city from #covid where city not in(select distinct city from(
select city,days,cases,
lead(cases) over(partition by city order by days, cases) as rnk
from #covid )temp where cases>=rnk )

--

with cte as
 ( select * , lag(cases,1,0) over(partition by city order by days asc) as lag_cases 
from #covid
 )
select distinct city
from cte
where city not in (select city from cte where lag_cases >= cases);

--
with covidAnalysis as
(
    select city, days, cases, (case when cases - lag(cases) over (partition by city order by days) <=0 then 0 else 1 end) flag
    from covid
)

select city
from covidAnalysis
group by city
having count(flag)=sum(flag);

--
WITH CTE AS(
SELECT *,
ABS(RANK() OVER(PARTITION BY city ORDER BY days)-RANK() OVER(PARTITION BY city ORDER BY cases)) AS diff
FROM #covid)

SELECT city FROM CTE
GROUP BY city HAVING SUM(DIFF)=0

--
SELECT city
FROM
  (SELECT *,
          lag(cases, 1) over(PARTITION BY city
                             ORDER BY days) AS prev_cases,
          (cases - coalesce(lag(cases, 1) over(PARTITION BY city
                                               ORDER BY days), 0)) AS diff
   FROM covid)a
GROUP BY city
HAVING min(diff) > 0;

--
; with cte as(
     select city,case when (cases-lag(cases,1,0) over (partition by city order by days))>0 then 1 else 0 end as prev_case
     from covid)
       select city
     from cte
     GROUP by city
     HAVING sum(prev_case)=count(city)

--
with delta_cte as(
select *,
case when (cases-lag(cases,1,0) over (partition by city order by days))>0 then 0 else 1 end as delta
from  #covid )

select city,sum(delta) as s_delta 
from delta_cte 
group by city
having sum(delta)=0

--
with base as (select *,
case when cases > coalesce(lag(cases) over (partition by city order by days),0) then 1 else 0 end increases
 from #covid)
 select city from base
 group by city having sum(increases) = count(1)

--
with cte as(
select *,
case when cases < lead(cases,1,9999) over(partition by city order by days) then 1 else 0 end as flag
from #covid )
select city
from cte group by city having min(flag) * max(flag) = 1;

--
select city
from(
select *,
lead(cases) over(partition by city order by days) as next_day_cases
from #covid) a
group by city
having count(*) = sum(case when (next_day_cases is null or next_day_cases > cases) then 1 else 0 end)

--

--
; with cte as (select*,lead(cases,1,999) over(partition by city order by days) as l,
lead(cases,1,999) over(partition by city order by days) - cases as p
from #covid)

select city from cte where city not in (select city from cte where p<=0) group by city


--
; with temp as( 
select *, cases - lag(cases)over(partition by city order by days) as lg1
from #covid
)
select distinct city from temp where city not in ( 
select city from temp 
where lg1<=0
)

--
;with cte as(
select *,lead(cases,1,9999) over(partition by city order by days) next_day_case
from #covid)
select city from cte a
where next_day_case>cases
group by city
having count(*)= (select count(*) from #covid where a.city=city group by city)


--

with tmp as(select *,rank() over (partition by city order by days)rn
,lead(cases) over(partition by city order by days)nxt_cases
from #covid)
,tmp1 as (select *,
(case when cases<nxt_cases or nxt_cases is null then 1 else 0 end)a,
(case when cases>nxt_cases  then 1 else 0 end)b
from tmp )
select city from tmp1 group by city having sum(a)=count(1)

--

;with cte as(select *,
case when (cases - lag(cases,1,0) over(partition by city order by days asc)) > 0 then 1 else 0 end as flag
from #covid)

select city from cte group by city
having count(*) = sum(flag)