/* prime subscription rate by product action
Given the following two tables, return the fraction Of users, rounded to two decimal places,
who accessed Amzon music and upgred to prime mebership within the first 30 days of signing up.
*/

create table #users
(
user_id integer,
name varchar(20),
join_date date
);
insert into #users
values (1, 'Jon', CAST('2-14-20' AS date)), 
(2, 'Jane', CAST('2-14-20' AS date)), 
(3, 'Jill', CAST('2-15-20' AS date)), 
(4, 'Josh', CAST('2-15-20' AS date)), 
(5, 'Jean', CAST('2-16-20' AS date)), 
(6, 'Justin', CAST('2-17-20' AS date)),
(7, 'Jeremy', CAST('2-18-20' AS date));

create table #events
(
user_id integer,
type varchar(10),
access_date date
);

insert into #events values
(1, 'Pay', CAST('3-1-20' AS date)), 
(2, 'Music', CAST('3-2-20' AS date)), 
(2, 'P', CAST('3-12-20' AS date)),
(3, 'Music', CAST('3-15-20' AS date)), 
(4, 'Music', CAST('3-15-20' AS date)), 
(1, 'P', CAST('3-16-20' AS date)), 
(3, 'P', CAST('3-22-20' AS date));

select * from #events
select * from #users

--

select --u.*, e.type,e.access_date,DATEDIFF(day,u.join_date,e.access_date) as no_of_days
count(distinct u.user_id) as total_users,
count(case when DATEDIFF(day,u.join_date,e.access_date) <=30 then u.user_id end),
Round(1.0*count(case when DATEDIFF(day,u.join_date,e.access_date) <=30 then u.user_id end)/
count(distinct u.user_id)*100,1) as ratio
from #users  u
left join #events e on e.user_id = u.user_id and e.type ='P'
where u.user_id in ( 
select user_id from #events where type='Music')

--

select
sum(case when type = 'P' and 
datediff(day,join_date,access_date) <=30 then 1 else 0 end)*1.0/sum(case when type = 'Music' then 1 else 0 end) as ratio
from #users a join #events b on a.user_id = b.user_id

--
; With CTE as
(Select 
        count(case 
	           when (e.type = 'P' and datediff(day, u.join_date, e.access_date)<=30) then 1 
			   else null 
			end) as  prime_users
     ,  count(case when e.type = 'Music' then 1 else null end) as total_users
from #users u join #events e
on u.user_id = e.user_id)

Select *, (1.0*prime_users/total_users)*100 from CTE

--
;with cte as (
select sum(case when type = 'music' then 1 end) music_users, 
sum(case when type = 'p' and datediff(day, join_date, access_date) < 30 then 1 end) p_sub
from #users u 
left join #events e on u.user_id = e.user_id)
select round(cast(p_sub as float)/music_users, 2) as ratio
from cte

--

select 
cast(sum(case when datediff(dd,u.join_date,p.access_date)<=30 and e.type is not null then 1 else 0 end) as float)
/ sum(case when e.type is not null then 1 else 0 end)*100
from #users u
left join #events e on u.user_id=e.user_id and e.type='music'
left join #events p on u.user_id=p.user_id and p.type='p'

--

; with t1 as
		(select count(1) amazon_music_accessed
		from #events
		where type='music'),
     t2 as
       (select cast(count(1) as decimal) as no_of_upgraded
		from #users u
		join #events e on u.user_id=e.user_id and e.access_date between u.join_date and u.join_date+30 
		where type ='p')


select round((t2.no_of_upgraded*100)/t1.amazon_music_accessed,2)
from t1,t2


--

/*
with events_cte as (
    select   user_id, 
             access_date,
             count(*) filter(where type='music') as music_members, 
             count(*) filter(where type='p') as prime_members
    from     events
    group by 1, 2
)
select 100.0 * round(sum(music_members) / sum(prime_members), 2) as fraction
from     events_cte e join users u using(user_id)
where  access_date <= join_date + interval '30 day'
*/