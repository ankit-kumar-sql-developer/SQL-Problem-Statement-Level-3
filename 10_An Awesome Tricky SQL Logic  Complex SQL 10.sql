
create table #tasks (
date_value date,
state varchar(10)
);

insert into #tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success')

select * from #tasks

--
;with cte as (
select *,
row_number () over (partition by state order by date_value) as rn,
dateadd(day,-1*row_number () over (partition by state order by date_value),date_value) as group_date
from  #tasks )
select group_date,min(date_value) as start_date, max(date_value) as end_date,state
from cte group by group_date,state 
order by start_date

--
;With t1 as(
select date_value as d, state,
Row_number() over(partition by state order by date_value) as r,
Row_number() over(order by date_value) as r2 
from #tasks )
select min(d) as start_date, max(d) as end_date , min(state)
from t1
group by (r2-r) Order by start_date;

--
; with cte as  (
select date_value,state,leaded,
sum(case when state='fail' and leaded='success' then 1 when state='success' and leaded='fail'
then 1 else 0 end) over (order by date_value) as grouped from (
select date_value,state,lag(state,1,state) over(order by date_value) as leaded
from #tasks ) A )
select min(date_value) as start_date,max(date_value) as end_date,state 
from cte  group by grouped;

--
;with cte_1 as 
(
select *,ROW_NUMBER() over (order by date_value) - ROW_NUMBER() over (partition by state order by date_value) differ
from #tasks
)
select min(date_value) start_date,max(date_value) end_date ,state,differ from cte_1
group by state,differ
order by start_date,end_date

--

with cte as (
select *, lag(state, 1,state) over (order by date_value) as prev 
from #tasks)
, cte2 as( -- running total
select *, sum(case when prev = state then 0 else 1 end) over (order by date_value) as flag
from cte
)
select min(date_value) as start, max(date_value) as enddate, min(state) as state
from cte2
group by flag

-- No CT Data
/*
Input table has below data :-

"2019-01-01"	"success"
"2019-01-02"	"success"
"2019-01-10"	"success"
"2019-01-11"	"fail"
"2019-01-12"	"fail"
"2019-01-13"	"success"
*/
--Solution for it is :- 

; with grp_dt as(
SELECT *,row_number() over (partition by state order by date_value) as rn,
dateadd( day,-1*row_number() over (partition by state order by date_value),date_value) as group_date
from #tasks )
SELECT min(date_value) as start_date,max(date_value) as end_date,state from grp_dt
group by state,group_date
order by state,group_date

-- 

;with tmp as (
select *,lag(state) over (order by date_value)lag_st,
lead(state) over (order by date_value) lead_st from #tasks )
,tmp1 as (
select *,lead(dateadd(day,-1,date_value)) over (order by date_value) prev from tmp 
where lag_st is null or lead_st is  null or tmp.state<>lag_st )

select date_value as start_date, coalesce(prev,date_value) as end_date ,state from tmp1

--

; with cte as (
select *,row_number()over(partition by state order by date_value) as rn 
from #tasks )
,b as (
select first_value(date_value)over(partition by datepart(day,date_value)-rn order by date_value) as start_date ,
last_value(date_value)over(partition by datepart(day,date_value)-rn order by date_value ) as end_date,state 
from cte)
select start_date,end_date,state from b group by start_date,end_date,state


--

select min(date_value) as start_date, max(date_value)as end_date, max(state) as state
from
(select date_value, state,prev_state,state_ind , sum(state_ind) over(order by date_value) as state_islands
from
(
select date_value, state,prev_state, (case when prev_state = state then 0 else 1 end) as state_ind  
from
(
select date_value, state,lag(state,1) over(order by date_value) as prev_state
from #tasks
)tmp )tmp2 ) t
group by state_islands

--

; with temp1 as(
SELECT t.*, IIF(LAG(state) OVER (ORDER BY date_value) = state, 0, 1)  AS rk
FROM #tasks t),
temp2 as(
select date_value,state,sum(rk) over (order by date_value) rk1 
from temp1)
select min(date_value) as start_date,max(date_value) as end_date,state
from temp2 
group by rk1,state;

--
with grp_data as(
select *,sum(lag1) over (order by date_value) as grp
from ( 
select *,
case when lag(state) over (order by (select null)) = state then 0 else 1 end as lag1 
from #tasks ) a)
select state, min(date_value) as start_date, max(date_value) as end_date
from grp_data group by state,grp order by start_date

--

with cte
as
(
select *,
sum(1) over (order by date_value) as rn_datewise,
sum(1) over (partition by state order by date_value, state) as rn_datewise_statewise
from #tasks
),
cte1
as
(
select date_value, state, (rn_datewise - rn_datewise_statewise) as state_group
from cte
)
select min(date_value) as start_date, max(date_value) as end_date, state
from cte1
group by state, state_group
order by start_date

--

; With add_lag_lead as (
Select date_value
		,lag(state,1) OVER(order by date_value) as lags
		,state
		,Lead(state,1,state) OVER(order by date_value) as leads
From #tasks
),
add_end_date as (
Select date_value as start_date
		,Lead(date_value,1,date_value) OVER(order by date_value) as end_date
		,lags
		,state
		,leads
From add_lag_lead
Where NOT (coalesce(lags,'0') = state and state = leads)
)

Select start_date,end_date,state
From add_end_date
Where state = leads



--
/*
;with recursive cte as (
 select min(start)as minn , max(end_date) as maxx from  
 (select min(date_value) as start , max(date_value) as end_date , state  from
 (select *,dateadd(date_value , interval -1*cast(row_number() over(partition by state order by date_value) as signed) day) as rn from #tasks) m 
group by rn) n
 union all 
 select dateadd(minn , interval 1 day)  , maxx from cte
 where minn<= maxx 
 )
 select minn as date_value , state from cte
 inner  join 
 (select min(date_value) as start , max(date_value) as end_date , state from
 (select *,dateadd(date_value , interval -1*cast(row_number() over(partition by state order by date_value) as signed) day) as rn from #tasks
)m 
group by rn) k on minn between start and end_date
group by minn , state
order by date_value 
*/

--
/*
; with cte as (
select datediff(lead(date_value) over (order by date_value),date_value) as diff,state,date_value
from #tasks)
select min(date_value),max(date_value),state from cte
group by state,diff; */