/* trips-and-users
Write a SQL query to find the cancellation rate of requests with unbanned users
(both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03".
Round Cancellation Rate to two decimal points.

The cancellation rate is computed by dividing the number of canceled (by client or driver)
requests with unbanned users by the total number of requests with unbanned users on that day.
*/

Create table  #Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table #Users (users_id int, banned varchar(50), role varchar(50));
Truncate table #Trips;
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into #Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table #Users;
insert into #Users (users_id, banned, role) values ('1', 'No', 'client');
insert into #Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into #Users (users_id, banned, role) values ('3', 'No', 'client');
insert into #Users (users_id, banned, role) values ('4', 'No', 'client');
insert into #Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into #Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into #Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into #Users (users_id, banned, role) values ('13', 'No', 'driver');

select * from #Trips
select * from #Users
--

select request_at,
count(case when status in( 'cancelled_by_driver','cancelled_by_client') then  1 else null end)
as cancelled_trips,
count(1) as total_trips,
1.0*count(case when status in( 'cancelled_by_driver','cancelled_by_client') then  1 else null end)/count(1)*100
as cancelled_per
from #Trips t
inner join  #Users c on t.client_id = c.users_id
inner join  #Users d on t.driver_id = d.users_id
where c.banned = 'No' and d.banned ='No'
group by request_at


--
;with unbanned_users_drivers as (select * from #Users where banned ='No') 
    select request_at 
	, round(100.0*sum(case when status='completed' then 1 else 0 end)/count(*),2) as comp_perc
	, round(100.0*sum(case when status<>'completed' then 1 else 0 end)/count(*),2) as ncomp_perc  
	from  #Trips  
	where client_id in  (select distinct users_id from unbanned_users_drivers where role ='client'  ) 
	and driver_id in  (select distinct users_id from unbanned_users_drivers where role ='driver'  )
	and cast(request_at as date) >= cast('2013-10-01'as date) and cast(request_at as date)<= cast('2013-10-03' as date)
	group by request_at