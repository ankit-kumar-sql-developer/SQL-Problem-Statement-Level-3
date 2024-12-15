
-- activity table shows app installed and app purchase activites for spotify app along with country details

CREATE table #activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from #activity;
insert into #activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

select * from #activity

/*Question 1: 
find total active users each day
event date		total active users
2e22-e1-e1		3
2e22-e1-e2		1
2e22-e1-e3		3
2e22-01-04	    1 */

select event_date, COUNT(distinct user_id) as cnt 
from #activity group by event_date

/*Question 2: find total active users each week
week number   total active users
1            3
2            5 */
select DATEPART(week,event_date) ,COUNT(distinct user_id) as cnt 
from #activity
group by DATEPART(week,event_date) 

/*Question 3:
date wise total number of users who made the purchare same day they installed the app
event date	  no_of_users same_day_purchase
2022-01-01	  0
2022-01-02    0
2022-01-03    2
2022-01-04    1 */

--
select event_date, count(new_user) as no_of_users from (
select user_id,event_date,
case when count(distinct event_name)=2 then user_id else null end as new_user
from #activity group by user_id,event_date
--having count(distinct event_name) =2 
) t group by event_date

-- Ankit
; with cte as (
select *,
ROW_NUMBER() over (partition by user_id,event_date order by event_date) as rn
from #activity )
, cte2 as (
select a.user_id from cte  a
group by a.user_id  having COUNT(distinct a.rn) =2 )

select event_date, COUNT(distinct user_id) as cnt 
from #activity 
where user_id in (select user_id from cte2)
group by event_date

/*Question 4: 
percentage Of paid users in India,	USA and any other country should be tagged as others
country  percentage_users
India  40
USA    20
others 40 */

;with cte as (
select count(distinct user_id) as cnt_user,
case when country in ('india','usa') then country else 'others' end as new_country
from #activity  where event_name in ('app-purchase')
group by case when country in ('india','usa') then country else 'others' end )
,total as (
select sum(cnt_user) as total_users from cte )

select new_country , cast(Round(1.0*cnt_user/total_users*100,2) as numeric(36,2))
from cte,total

/*Question 5:	
Among all the users who installed the app on a given day, how many did in app purchases on the very next day 
--day wise result
event date	cnt users
2022-01-01  0
2022-01-02  1
2022-01-03  0
2022-01-04  0 */

; with prev_data as (
select *,
lag(event_name,1) over (partition by user_id order by event_date ) as prev_event_name,
lag(event_date,1) over (partition by user_id order by event_date ) as prev_event_date
from #activity )

select event_date, COUNT(distinct user_id) as cnt from prev_data
where event_name='app-purchase' and prev_event_name ='app-installed'
and DATEDIFF(day,prev_event_date,event_date) =1
group  by event_date

----
select event_date, SUM(cnt) from (
select event_date,
case when datediff(day,event_date ,
LAG(Dateadd(day,1,event_date)) over (partition by user_id order by event_date)) =0 then '1' else 0 end
as cnt from #activity ) t
group by event_date

---
;with prev_data as
(select *,
lag(event_date,1) over(partition by user_id order by event_date) as prev_event_date,
lag(event_name,1) over(partition by user_id order by event_date) as prev_event_name 
from #activity)

select event_date,
count(case when event_name='app-purchase' and prev_event_name='app-installed' and datediff(day,prev_event_date,event_date)=1 then user_id else null end) as user_cnt
from prev_data
group by event_date

--

select event_date,count(user_id1) as count from (
select a.*,
b.event_date as event_date1,
b.user_id as user_id1
from #activity a left join #activity b
on a.user_id=b.user_id and DATEDIFF(day,b.event_date,a.event_date)=1)a
group by event_date

--

select a2.event_date,
sum(case when datediff(day,a1.event_date, a2.event_date) = 1 then 1 else 0 end)cnt_users

from Activity a1

join activity a2 on a1.user_id = a2.user_id and a1.event_name <> a2.event_name

group by a2.event_date

--
select a.event_date,count(b.user_id) as cnt_users
from(
select *,date_sub(event_date,interval 1 day) as prev_day from activity) a
left join activity b on a.prev_day=b.event_date and a.user_id=b.user_id and a.event_name='app-purchase' and b.event_name='app-installed'
group by a.event_date

--

/* Question 5 :- Among all users who installed the app on given day, how many did app purchased very next day */

Select count(a2.user_id) as tot_cnt 
,case when a1.event_date = dateadd(day,-1,a2.event_date) then a2.event_date else a1.event_date end as eventdate
from  activity a1 left outer join activity a2
on a1.user_id=a2.user_id and a1.event_name='app-installed' and a2.event_name='app-purchase' 
and a1.event_date = dateadd(day,-1,a2.event_date)
group by case when a1.event_date = dateadd(day,-1,a2.event_date) then a2.event_date else a1.event_date end

---- approach 2 , with single table 

with cte1 as 
(select * 
,lag(event_name,1) over ( partition by user_id order by event_date) as prev_event_name
,lag(event_date,1) over ( partition by user_id order by event_date) as prev_event_date
from activity)
select sum(case when event_date = dateadd(day,1,prev_event_date) then 1 else 0 end) as total_cnt ,event_date  
from cte1
group by event_date

--

1. select  event_date,count (distinct user_id) from activity
group by event_date
order by 1;

2. select date_part('week',event_date) as week_num,count(distinct user_id) from activity
group by week_num
order by 1;

3. select a.event_date,sum(case when a.event_name <> b.event_name and a.event_name='app-installed' then 1 else 0 end) as case_total  
from activity a inner join activity b
on a.user_id=b.user_id
and a.event_date=b.event_date
group by a.event_date;


4. 
select a.country_flag,round(cast(active_user as decimal)/total_user,2) from 
(
(select country_flag,count(1) as active_user from(
select *,case when country='India' then 'India' when country='USA' then 'USA' else 'Others' end as country_flag
from activity
where event_name='app-purchase')b
group by country_flag) a 
inner join

(select country_flag,count(1) as total_user from(
select *,case when country='India' then 'India' when country='USA' then 'USA' else 'Others' end as country_flag

from activity)b
group by country_flag) b
on a.country_flag=b.country_flag)
order by 1


5. select a.event_date,count(b.user_id) as next_day_purchase 
from activity a left join activity b
on a.user_id=b.user_id
and a.event_date-b.event_date=1
group by a.event_date
order by 1

--

with set1 as 
(
	select t.event_date,t.user_id,
	count(t.event_name) as Cnt 
	from activity as t
	group by t.event_date,t.user_id
)
select t.event_date,
sum(iif(t.cnt>1,1,0)) as usrCnt
from set1 as t


group by t.event_date