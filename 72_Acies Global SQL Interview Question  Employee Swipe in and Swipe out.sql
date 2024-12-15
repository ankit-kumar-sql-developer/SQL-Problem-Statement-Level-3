/*
we have	a swipe table which keeps track of the employee login and logout timings.
1. Find	out the time employee person spent in office on a particular day (office hours = last logout time -	first login time)
2. Find	out how productive he was at office on a particular day. (He might have done many swipes per day. I need to find the acti
*/
create table #swipe (
    employee_id int,
    activity_type varchar(10),
    activity_time datetime
);

-- insert sample data
insert into #swipe (employee_id, activity_type, activity_time) values
(1, 'login', '2024-07-23 08:00:00'),
(1, 'logout', '2024-07-23 12:00:00'),
(1, 'login', '2024-07-23 13:00:00'),
(1, 'logout', '2024-07-23 17:00:00'),
(2, 'login', '2024-07-23 09:00:00'),
(2, 'logout', '2024-07-23 11:00:00'),
(2, 'login', '2024-07-23 12:00:00'),
(2, 'logout', '2024-07-23 15:00:00'),
(1, 'login', '2024-07-24 08:30:00'),
(1, 'logout', '2024-07-24 12:30:00'),
(2, 'login', '2024-07-24 09:30:00'),
(2, 'logout', '2024-07-24 10:30:00');

select * from #swipe

-- Q1
; with cte as (
select *,cast(activity_time as date) as  activity_day,
lead(activity_time,1) over (partition by employee_id,cast(activity_time as date)
order by activity_time) as logout_time
from #swipe )

select employee_id,activity_day,
Min(activity_time) as login_time, Max(logout_time) as logout_time,
sum(DATEDIFF(hour,activity_time, logout_time)) as inside_hours 
from cte where activity_type='login'
group by employee_id,activity_day