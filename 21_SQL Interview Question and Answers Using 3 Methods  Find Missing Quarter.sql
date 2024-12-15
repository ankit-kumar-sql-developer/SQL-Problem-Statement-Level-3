
drop table if exists #stores
create table #stores (
store varchar(10),
quarter varchar(10),
amount int);

insert into #stores (store, quarter, amount)
values ('s1', 'q1', 200),
('s1', 'q2', 300),
('s1', 'q4', 400),
('s2', 'q1', 500),
('s2', 'q3', 600),
('s2', 'q4', 700),
('s3', 'q1', 800),
('s3', 'q2', 750),
('s3', 'q3', 900);

-- Method 1
select * from #stores

select store, 'Q' + cast(10-sum(cast(right(quarter,1) as int)) as CHAR(2)) as q_no
from #stores
group by store

-- Method 2
; with r_cte as (
select distinct store,1 as q_no from #stores
union all
select store, q_no+1 as q_no
from r_cte
where q_no <4 )
,q as (
select store, 'Q'+ cast(q_no as char(1)) as q_no from r_cte  )
select * 
from q
left join #stores s on q.store=s.store and q.q_no=s.quarter
where s.store is null

-- Method 3 Using cross Join
/*
Cross Join (3rd method) will not give the correct result if all stores are missing 
same quarter example S1 , S2 , S3 store have  Q1,Q2, Q4 but Q3 is missing in all 3
then Cross Join will not return Q3 row.
*/

;with cte as (
select distinct s1.store,s2.quarter
from #stores s1, #stores s2 )
select * 
from cte q
left join #stores s on q.store=s.store and q.quarter=s.quarter
where s.store is null

--

select a.* from
(
select * from (select distinct Store from #STORES)a 
cross apply (
select 'Q1' as Q union select 'Q2' union select 'Q3' union select 'Q4')b
--order by store,Q
)a
left join #STORES S on S.store=a.Store and S.Quarter=a.Q
where S.store is null

--
select s1.store, s2.quarter from #stores s1, #stores s2
group by s1.store, s2.quarter
except
select store, quarter from #stores;

--
; with all_quat as (
select store,'q1' quarter from #stores
union
select store,'q2' from #stores
union
select store,'q3' from #stores
union 
select store, 'q4' from #stores)
select store,quarter  from all_quat
except
select store,quarter from #stores



---

; with cnt_q as (
select store
,count(case when 'q1' in (quarter) then 1 end) as cnt_q1
,count(case when 'q2' in (quarter) then 1 end) as cnt_q2
,count(case when 'q3' in (quarter) then 1 end) as cnt_q3
,count(case when 'q4' in (quarter) then 1 end) as cnt_q4
from #stores group by store )
select store,
  case 
    when cnt_q1 = 0 then 'q1'
    when cnt_q2 = 0 then 'q2'
    when cnt_q3 = 0 then 'q3'
    else 'q4'
  end as result
from cnt_q;

--
select Store,
concat('Q',10-sum(cast(substring(Quarter,2,1) as int)))as q_no
from #STORES
group by Store

--

; with cte1 as (
select store,quarter,
case
when quarter='Q1' then 1
when quarter='Q2' then 2
when quarter='Q3' then 3
when quarter='Q4' then 4
end as num from #STORES
),cte2 as(
select store,sum(num) total,10-sum(num) as missing_Q from cte1 group by store 
)
select store,
case
when missing_Q='1' then 'Q1'
when missing_Q='2' then 'Q2'
when missing_Q='3' then 'Q3'
when missing_Q='4' then 'Q4'
end as missing_quarter from cte2

--

; with cte as(
select *,
lag(quarter,1) over(partition by store order by quarter) prevq,
lead(quarter,1) over(partition by store order by quarter) nextq
from #STORES ),
cte2 as(
select *, 
case 
when quarter='q2' and prevq is null then 'Q1'
when quarter='q3' and prevq='q1' then 'Q2'
when quarter='q4' and prevq='q2' then 'Q3'
when quarter='q3' and nextq is null then 'Q4'
end as missing
from cte)
select store,missing from cte2 where missing is not null