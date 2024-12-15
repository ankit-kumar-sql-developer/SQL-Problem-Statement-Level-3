

create table #booking_table(
   booking_id       varchar(3) not null 
  ,booking_date     date not null
  ,user_id          varchar(2) not null
  ,line_of_business varchar(6) not null
);
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b1','2022-03-23','u1','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b2','2022-03-27','u2','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b3','2022-03-28','u1','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b4','2022-03-31','u4','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b5','2022-04-02','u1','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b6','2022-04-02','u2','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b7','2022-04-06','u5','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b8','2022-04-06','u6','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b9','2022-04-06','u2','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b10','2022-04-10','u1','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b11','2022-04-12','u4','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b12','2022-04-16','u1','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b13','2022-04-19','u2','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b14','2022-04-20','u5','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b15','2022-04-22','u6','flight');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b16','2022-04-26','u4','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b17','2022-04-28','u2','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b18','2022-04-30','u1','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b19','2022-05-04','u4','hotel');
insert into #booking_table(booking_id,booking_date,user_id,line_of_business) values ('b20','2022-05-06','u1','flight');
;
create table #user_table(
   user_id varchar(3) not null
  ,segment varchar(2) not null
);
insert into #user_table(user_id,segment) values ('u1','s1');
insert into #user_table(user_id,segment) values ('u2','s1');
insert into #user_table(user_id,segment) values ('u3','s1');
insert into #user_table(user_id,segment) values ('u4','s2');
insert into #user_table(user_id,segment) values ('u5','s2');
insert into #user_table(user_id,segment) values ('u6','s3');
insert into #user_table(user_id,segment) values ('u7','s3');
insert into #user_table(user_id,segment) values ('u8','s3');
insert into #user_table(user_id,segment) values ('u9','s3');
insert into #user_table(user_id,segment) values ('u10','s3');


select * from #booking_table
select * from #user_table

-- Question 1

select u.segment, COUNT(distinct u.user_id) as no_of_users,
count(distinct case when line_of_business='Flight' and b.booking_date between '2022-04-01' 
and '2022-04-30' then b.user_id else null end ) as flight_Apr_2022
from #user_table u
left join  #booking_table b on u.user_id=b.user_id
group by u.segment


-- Q2 Write a query to identify users whose first booking was hotel booking

; with cte as (
select *,RANK() over (partition by user_id order by booking_date asc) as rn
from #booking_table )

select * from cte where rn=1 and line_of_business= 'Hotel'

--
; with cte as (
select *,
FIRST_VALUE(line_of_business) over (partition by user_id order by booking_date asc) as rn
from #booking_table )
select distinct user_id from cte where rn ='Hotel'


-- Q3 Calculate days between first & last booking

select USER_ID,
MIN(booking_date), MAX(booking_date),
DATEDIFF(day,MIN(booking_date), MAX(booking_date)) as diff
from #booking_table group by user_id

-- Q4 write a query to count the number of flight and hotel bookings in each of the user segments for the year 2022

select u.segment,
sum(case when line_of_business='flight' then 1 else 0 end) as flight,
sum(case when line_of_business='Hotel' then 1 else 0 end) as Hotel
from #user_table u
inner join  #booking_table b on u.user_id=b.user_id
group by u.segment

select u.segment,
sum(case when line_of_business='flight' then 1 else 0 end) as flight,
sum(case when line_of_business='Hotel' then 1 else 0 end) as Hotel
from  #booking_table b
inner  join #user_table u on b.user_id=u.user_id
where DATEPART(year,booking_date)='2022'
group by u.segment


--***********************************************************--

-- Q2
with cte as(select User_id,min(Booking_date) as first_booking_date
from booking_table
group by User_id)
select c1.*,bt.Booking_id,bt.Line_of_business 
from cte c1
inner join booking_table bt on c1.first_booking_date=bt.Booking_date and c1.User_id=bt.User_id
where bt.Line_of_business='Hotel'

-- Q1
with cte as (
		select *, if(User_id in (select distinct User_id
								from booking_table
								where Line_of_business = 'Flight' and month(Booking_date) = '04'), 1, 0) as flag
		from user_table)
select Segment, count(User_id) as total_user_count, sum(flag) as distinct_users_who_booked_flight_in_apr2022
from cte
group by 1

-- q1
select a.segment, count(distinct a.User_id) total_user_count , count(distinct b.User_id) users_April
from  user_table a
left join booking_table b on a.User_id=b.User_id
and b.Line_of_business= 'Flight'
and DATEPART(MONTH,b.Booking_date)=4
group by a.segment;

--
with cte as
 (select  User_id,
Line_of_business,
Booking_date,
lag(Booking_date,1) over (partition by User_id order by Booking_date ) as prev_type_booking
from  booking_table order by User_id) 
select * from cte
where Line_of_business='Hotel' and prev_type_booking is null;

