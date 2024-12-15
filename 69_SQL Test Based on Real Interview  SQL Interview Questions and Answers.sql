

create table #users (
    user_id int primary key,
    user_name varchar(20) not null,
    user_status varchar(20) not null
);

create table #logins (
    user_id int,
    login_timestamp datetime not null,
    session_id int primary key,
    session_score int,
    foreign key (user_id) references #users(user_id)
);

-- #users table
insert into #users values (1, 'alice', 'active');
insert into #users values (2, 'bob', 'inactive');
insert into #users values (3, 'charlie', 'active');
insert into #users  values (4, 'david', 'active');
insert into #users  values (5, 'eve', 'inactive');
insert into #users  values (6, 'frank', 'active');
insert into #users  values (7, 'grace', 'inactive');
insert into #users  values (8, 'heidi', 'active');
insert into #users values (9, 'ivan', 'inactive');
insert into #users values (10, 'judy', 'active');

-- #logins table 

insert into #logins  values (1, '2023-07-15 09:30:00', 1001, 85);
insert into #logins values (2, '2023-07-22 10:00:00', 1002, 90);
insert into #logins values (3, '2023-08-10 11:15:00', 1003, 75);
insert into #logins values (4, '2023-08-20 14:00:00', 1004, 88);
insert into #logins  values (5, '2023-09-05 16:45:00', 1005, 82);

insert into #logins  values (6, '2023-10-12 08:30:00', 1006, 77);
insert into #logins  values (7, '2023-11-18 09:00:00', 1007, 81);
insert into #logins values (8, '2023-12-01 10:30:00', 1008, 84);
insert into #logins  values (9, '2023-12-15 13:15:00', 1009, 79);


-- 2024 q1
insert into #logins (user_id, login_timestamp, session_id, session_score) values (1, '2024-01-10 07:45:00', 1011, 86);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (2, '2024-01-25 09:30:00', 1012, 89);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (3, '2024-02-05 11:00:00', 1013, 78);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (4, '2024-03-01 14:30:00', 1014, 91);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (5, '2024-03-15 16:00:00', 1015, 83);

insert into #logins (user_id, login_timestamp, session_id, session_score) values (6, '2024-04-12 08:00:00', 1016, 80);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (7, '2024-05-18 09:15:00', 1017, 82);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (8, '2024-05-28 10:45:00', 1018, 87);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (9, '2024-06-15 13:30:00', 1019, 76);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (10, '2024-06-25 15:00:00', 1010, 92);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (10, '2024-06-26 15:45:00', 1020, 93);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (10, '2024-06-27 15:00:00', 1021, 92);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (10, '2024-06-28 15:45:00', 1022, 93);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (1, '2024-01-10 07:45:00', 1101, 86);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (3, '2024-01-25 09:30:00', 1102, 89);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (5, '2024-01-15 11:00:00', 1103, 78);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (2, '2023-11-10 07:45:00', 1201, 82);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (4, '2023-11-25 09:30:00', 1202, 84);
insert into #logins (user_id, login_timestamp, session_id, session_score) values (6, '2023-11-15 11:00:00', 1203, 80);


select * from #logins
select * from #users

-- Q1 Management wants to see all the users that did not login in the past 5 months — return: username.

select user_id,max(login_timestamp)   
from #logins
group by user_id
having  max(login_timestamp)  <  dateadd(month,-10,getdate())

select distinct user_id from #logins where user_id not in	(
select user_id from #logins
where login_timestamp > dateadd(month,-10,getdate()) )

-- Q2 For the business units' quarterly analysis, calculate how many users and how many sessions were at each quarter
-- order by quarter from newest to oldest. --Return: first day of the quarterl user_cnt, session_cnt.

select DATEPART(quarter,login_timestamp) as Quarter_number, COUNT(*) as total_sessions,
COUNT(distinct user_id) as cnt, MIN(login_timestamp) as qtr_first_login,
DATETRUNC(quarter,MIN(login_timestamp)) as first_qtr_date
from #logins group by DATEPART(quarter,login_timestamp) 


-- Q3 Display user id's that Log-in in January 2024 and did not Log-in on November 2023.
--Return: User id

select * from #logins
where login_timestamp between '2024-01-01' and '2024-01-31'
and user_id not in (
select user_id from #logins
where login_timestamp between '2023-11-01' and '2023-11-30')


-- Q4 Add to the query from 2 the percentage change in	sessions from last quarter.
--Return: first day of the quarter, session cnt, session cnt prev, Session percent change

; with cte as (
select datetrunc(quarter, min(login_timestamp) )as first_quarter_date,
count(*) as session_cnt,count (distinct user_id) as user_cnt
from #logins group by datepart(quarter, login_timestamp) )

select *,
lag(session_cnt,1) over (order by first_quarter_date)as prev_session_cnt,
(session_cnt - lag(session_cnt,1) over (order by first_quarter_date))*100.0/
lag(session_cnt,1) over (order by first_quarter_date)
from cte

-- --5. Display the user that had thehighest session score (max) for each day -
--Return: Date, username, score
; with cte as (
select user_id login_timestamp,cast(login_timestamp as date ) as login_date,
sum(session_score) as score
from #logins
group by user_id, cast(login_timestamp as date ) )
select * from (
select *, ROW_NUMBER() over (partition by login_date order by score desc) as rn
from cte ) t where rn=1

-- Q6. To identify our	best users- Return the users that had a session on every single day since their first login
select user_id, min(cast(login_timestamp as date)) as first_login,
count(distinct cast(login_timestamp as date)) as no_of_login_day,
datediff(day,min(cast(login_timestamp as date)), getdate())+1 as no_of_login_req
from #logins group by user_id
having datediff(day,min(cast(login_timestamp as date)), getdate())+1= 
count(distinct cast(login_timestamp as date))
order by user_id 

-- Q7 What dates there were no login at all ? -- 2023-07-15 and 2024-06-28
-- Method 1
select * from calendar_dim c
inner join 
(select min(cast(login_timestamp as date)) as first_date,
cast(GETDATE() as date) as last_date
from #logins) d on c.cal_date between first_date and last_date
where cal_date not in (
select distinct cast(login_timestamp as date) from #logins )

-- Method 2
; with cte as (
select min(cast(login_timestamp as date)) as first_date,
cast(GETDATE() as date) as last_date
from #logins
union all

select DATEADD(day,1,first_date) as first_date,last_date from cte
where first_date < last_date
)

select * from cte 
where first_date not in (
select distinct cast(login_timestamp as date) from #logins )
option (maxrecursion 500)