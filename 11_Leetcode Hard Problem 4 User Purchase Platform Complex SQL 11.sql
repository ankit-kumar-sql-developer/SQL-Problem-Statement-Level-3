
create table #spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into #spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);

select * from #spending

--
; with cte as (
select spend_date,user_id,max(platform) as platform,sum(amount) as amount
from #spending
group by spend_date,user_id
having count(distinct platform) =1
union all
select spend_date,user_id,'both' as platform,sum(amount) as amount
from #spending
group by spend_date,user_id
having count(distinct platform) =2 
union all
select distinct spend_date,null as user_id,'both' as platform,0 as amount
from #spending
)
select spend_date,platform,sum(amount) as total_amount,
count(distinct user_id) as total_users
from cte
group by spend_date,platform
order by spend_date,platform desc 

--

;with cte as(
 select case when string_agg(platform,',')='mobile,desktop' then 'both' else string_agg(platform,',') end
 as pf,spend_date,user_id,sum(amount) total,count(distinct user_id ) cnt
 from #spending group by spend_date,user_id )
 ,cte2 as (
 select * from cte 
 union all
 select distinct 'both' as pf,spend_date,null as user_id, 0 as total,0 as cnt
 from #spending )

 select pf,spend_date, sum(total)totalamount,count(distinct user_id)totalusers from cte2 
 group by spend_date,pf 
 order by  spend_date,pf desc 

 --

 ; with A as ( 
 select spend_date, platform, user_id, amount, 
 count(platform) over(partition by spend_date, user_id) as c from #spending ) 
 , B as ( 
 select spend_date, case when c > 1 then 'both' when c = 1 and platform = 'mobile'
 then 'mobile' when c = 1 and platform = 'desktop' then 'desktop' else platform end as new_platform,
 user_id, amount 
 from A 
 union 
 select distinct spend_date, 'both' as new_platform, null as user_id, 0 as amount 
 from A ) 

 select spend_date, new_platform, sum(amount) as total_amount,
 count(distinct user_id) as no_of_users 
 from B group by spend_date, new_platform 
 order by spend_date, new_platform


--

select count(distinct user_id) as total_users, spend_date, 
case when count(distinct platform) = 2 then 'both' else max(platform) end as platfrom, 
sum(amount) as total_amount from #spending
group by user_id,spend_date
union
select 0,spend_date,'both',0 from #spending
group by spend_date
having count(distinct user_id) = count(user_id)
order by spend_date, total_users desc

--

;with cte as
(
select spend_date,string_agg(platform,',') 'platform',sum(amount) 'amount',user_id
from #spending
group by spend_date,user_id
union all
select spend_date,'both',0,null
from #spending
)

select spend_date,case when platform='mobile,desktop' then 'both' else platform end platform,
sum(amount) 'total_amt',count(distinct user_id) 'total_users'
from cte
group by spend_date,case when platform='mobile,desktop' then 'both' else platform end
order by 1 

--

;with cte as (
select * , count(1) over (partition by user_id ,spend_date) as 'ct'  from #spending)
select * from (
select spend_date , platform , sum(amount) as 'total amount', 
count(distinct user_id) as 'total_users' from cte where ct=1
group by spend_date , platform

union all 
select spend_date,'both' as 'platform', sum(amount) as 'total amount' , 
count(distinct user_id) as 'total_users' from cte where ct <> 1
group by spend_date ) as x
order by 1

--

select a.spend_date, 'both' platform, 
sum(case when a.user_id=b.User_id then b.amount else 0 end) total_amount,
count(distinct b.user_id) total_users
from #spending  a
left join #spending  b on a.user_id=b.user_id
and a.spend_date=b.spend_date and a.platform<>b.platform
group by a.spend_date

union
select a.spend_date, a.platform, sum(a.amount) total_amount, count(a.user_id) total_users
from #spending  a
left join #spending  b on a.user_id=b.user_id and a.spend_date=b.spend_date and a.platform<>b.platform
where b.user_id is null
group by a.spend_date, a.platform
order by 1,2 desc


--
;with cte as (
select spend_date,count(1) as total_users_per_date,
sum(amount) as total_amount_per_date_from_both 
from #spending group by spend_date )
,cte2 as (
select spend_date,sum(case when platform = 'mobile' then 1 else 0 end) as mobile_user,
sum(case when platform = 'mobile' then amount else 0 end) as mobile_amount,
sum(case when platform = 'desktop' then 1 else 0 end) as desktop_user,
sum(case when platform = 'desktop' then amount else 0 end) as desktop_amount
from #spending group by spend_date )
select cte.spend_date,total_users_per_date,total_amount_per_date_from_both,
mobile_user,mobile_amount,desktop_user,desktop_amount
from cte join cte2 on 
cte.spend_date= cte2.spend_date

--

select spend_date,platform_1 as platform, sum(amount) as amount,count(distinct user_id)
from
(select spend_date,user_id,platform,lead_pl,lag_pl,amount,
case when platform like 'mobile' and lead_pl like 'desktop' then 'both'
when platform like 'desktop' and lag_pl like 'mobile' then 'both'  
else platform end
as platform_1
from
(select spend_date,user_id,platform,amount,
lead(platform) over(partition by spend_date,user_id order by platform desc) as lead_pl,
lag(platform) over(partition by spend_date,user_id order by platform desc) as lag_pl
from #spending )x)y
group by spend_date, platform_1

--

; with cte1 as (
select spend_date,platform,user_id,amount,
count(1) over(partition by spend_date,user_id) rn from #spending)
,cte2 as (
select spend_date,platform,sum(amount) total_amount,count(1) total_users 
from cte1 where rn=1 group by spend_date,platform
union all
select spend_date,'both' as platform,sum(amount) total_amount,
count(distinct user_id) total_users
from cte1 where rn=2 group by spend_date
),
cte3 as (select spend_date,'both' platform,0 total_amount,0 total_users from cte2 group by spend_date having count(1)!=3)
select * from cte2 
union all 
select * from cte3 order by 1,2 desc;


--


with cte1 as(
select spend_date, sum(amount) as amount, count(distinct user_id) as users_count,
case 
    when count(user_id)>1 then 'both' else max(platform) end as platformname
from #spending
group by user_id, spend_date
union
select spend_date, 0 as amount, 0 as users_count,'both' as platformname
from #spending
group by user_id, spend_date )
select spend_date, sum(amount) as amount, sum(users_count) as userscount, platformname
from cte1
group by spend_date, platformname


--
;with bothuser as (
select user_id,spend_date,sum(total) as total from(
select platform,spend_date,user_id,sum(amount) as total from #spending
group by platform,spend_date,user_id ) a group by user_id,spend_date
having count(1) > 1 )
--find different dates so that we can add 0 entry where we dont have any customer with both purchase
,distdates as ( select distinct spend_date from #spending)
select s.spend_date,'both' as platform,isnull(sum(b.total),0)  as total,
count(distinct b.user_id) as totalusers
from distdates s inner join bothuser b on s.spend_date = b.spend_date
group by s.spend_date

union
select s.spend_date, platform, sum(amount)  as total,count(distinct s.user_id) as totalusers
from #spending s 
left outer join bothuser b on s.user_id = b.user_id and s.spend_date = b.spend_date
where b.user_id is null
group by s.spend_date,platform

--

select spend_date,platform,sum(tot_amount),sum(tot_users) from (
select spend_date,
case when string_agg(platform, ',') like '%,%' then 'both' else string_agg(platform, ',') end as platform,
sum(amount) as tot_amount,count(distinct user_id) as tot_users
from #spending group by spend_date,user_id

union

select distinct spend_date,'both' as platform,0 as tot_amount,0 as tot_users
from #spending) a
group by spend_date,platform
order by spend_date, platform desc

--

;with cte as(
select *,
coalesce(lead(platform) over(partition by user_id order by user_id, spend_date), lag(platform) over(partition by user_id order by user_id, spend_date))  as platform_2
from #spending),
cte1 as(
select spend_date,'both' as platform,sum(amount) as amt,
count(distinct user_id) as num  from cte
where platform != platform_2
group by 1),
cte2 as(
select
user_id, 
count(distinct platform) as num_platform
from #spending
group by user_id),
cte3 as(
select spend_date, platform, sum(amount) as amt, count(#spending.user_id) as num
 from #spending inner join cte2
 on cte2.user_id = #spending.user_id
 where cte2.num_platform = 1
 group by 1,2,#spending.user_id
 union
 select * from cte1
 union
 select distinct spend_date, 'both' as platform, 0 as amt, 0 as num
 from #spending)
 select spend_date, platform, max(amt), max(num)
 from cte3 group by 1,2;

--

with temp as
(
	select spend_date, min(platform) platform,  sum(amount) total_amount, count(distinct user_id) total_users
	from spending
	group by spend_date, user_id
	having count(platform) = 1
	union all
	select spend_date, 'both' ,  sum(amount) , count(distinct user_id) 
	from spending
	group by spend_date, user_id
	having count(platform) > 1
	union all
	select spend_date, platform, 0, 0
	from spending
	group by spend_date, platform
	union all
	select spend_date, 'both', 0, 0
	from spending
	group by spend_date
)
select spend_date, platform, sum(total_amount) total_amount, sum(total_users) total_users
from temp
group by spend_date, platform
order by spend_date, platform desc

--
WITH cte AS
 (select user_id, spend_date,
 case 
 WHEN COUNT(DISTINCt platform) =2 then 'Both'
 WHEN max(platform) = 'desktop' then 'desktop'
 else 'mobile'
END AS platform,
sum(amount) as total_amount
from spending
group by user_id, spend_date

 )
 Select
	spend_date,platform,SUM(total_amount) AS total_amount, COUNT(user_id) as total_users
from cte
 GROUP BY spend_date, platform

UNION ALL


SELECT
    DISTINCT spend_date, 'Both', 0 AS total_amount, 0 AS total_users
FROM 
    spending
WHERE
    spend_date NOT IN (
        SELECT DISTINCT spend_date
        FROM cte
        WHERE platform = 'Both'
    )

ORDER BY 
    spend_date;
--


---
/*
when we have only mobile platform record for one spend_date in the Spending table, like this
insert into spending values (1,TO_DATE('2019-07-03','YYYY-MM-DD'),'mobile',100);
then in the output
we are getting two records for Spend_date = '2019-07-03'
they are 'mobile' and 'both' platform but not 'Desktop' platform.
how to get 'dummy 'Desktop' record in the output?
*/
; with all_spend as (
Select spend_date, user_id , max(PLATFORM) as platform ,count(1) as total_users , sum(amount) as Total_amount
from #Spending group by spend_date, user_id  Having  count(distinct platform) = 1 
union
Select spend_date, user_id , 'Both' as platform ,count(distinct user_id) as total_users , sum(amount) as Total_amount
from #Spending group by spend_date, user_id  Having  count(user_id) = 2
union
Select distinct spend_date,null as user_id ,'Both' as platform ,0 as amount  , 0 as total_users
from #Spending 
union
Select distinct spend_date,null as user_id ,'mobile' as platform ,0 as amount  , 0 as total_users
from #Spending 
union
Select distinct spend_date,null as user_id ,'desktop' as platform ,0 as amount  , 0 as total_users
from #Spending 
)

Select spend_date , platform , sum(Total_amount) as amount, count(distinct user_id) as total_users
from all_spend group by spend_date , platform 
order by spend_date, platform


--
/*
-----
user_id spend_date      plat_f  amount
1	2019-07-01	mobile	100
1	2019-07-01	desktop	100
2	2019-07-01	mobile	100
3	2019-07-01	desktop	100
5	2019-07-01	mobile	100
6	2019-07-01	desktop	100
2	2019-07-02	mobile	100
3	2019-07-02	desktop	100
7	2019-07-02	mobile	100
8	2019-07-02	desktop	100
9	2019-07-03	desktop	100
10	2019-07-04	mobile	100


output
------
spend_date      plat_f  total  count_user
2019-07-01	mobile	200	2
2019-07-01	desktop	200	2
2019-07-01	both	200	1
2019-07-02	mobile	200	2
2019-07-02	desktop	200	2
2019-07-02	both	0	0
2019-07-03	mobile	0	0
2019-07-03	desktop	100	1
2019-07-03	both	0	0
2019-07-04	mobile	100	1
2019-07-04	desktop	0	0
2019-07-04	both	0	0


Query
-----
*/
with cte as(
select spend_date, 
case when count(distinct platform) > 1 then 'both' 
when platform = 'mobile' then 'mobile' 
when platform = 'desktop' then 'desktop' 
end plat_f,
sum(amount) sum_amt
from spending
group by spend_date,user_id
)
,cte2 as (
select spend_date,
case 
when (count(distinct plat_f) < 2 or count(distinct plat_f) < 3) and plat_f not in ('both') then  'both' 
end flag, 0 total , 0 count_user
from cte group by spend_date
)
, cte3 as (
select spend_date,
case 
when count(distinct plat_f) < 2 and plat_f not in ('desktop') then  'desktop' 
when count(distinct plat_f) < 2 and plat_f not in ('mobile') then  'mobile' 
end flag, 0 total , 0 count_user
from cte group by spend_date
)

select * from (
select distinct c1.spend_date,c1.plat_f
, sum(sum_amt) over(partition by spend_date,plat_f) total
, count(*) over(partition by spend_date,plat_f) count_user
from cte c1
union all
select * from cte2 where flag is not null
union all
select * from cte3 where flag is not null
)A order by spend_date asc,plat_f desc;