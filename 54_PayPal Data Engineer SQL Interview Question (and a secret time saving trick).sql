--Write an sql code to find output table as below
-- employeeid,employee_default_phone_number,totalentry,totallogin,totallogout,latestlogin,latestlogout

-- Create the employee_checkin_details table
CREATE TABLE #employee_checkin_details (
    employeeid INT,
    entry_details VARCHAR(10),
    timestamp_details DATETIME2
);

-- Insert data into employee_checkin_details
INSERT INTO #employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES
(1000, 'login', '2023-06-16 01:00:15.34'),
(1000, 'login', '2023-06-16 02:00:15.34'),
(1000, 'login', '2023-06-16 03:00:15.34'),
(1000, 'logout', '2023-06-16 12:00:15.34'),
(1001, 'login', '2023-06-16 01:00:15.34'),
(1001, 'login', '2023-06-16 02:00:15.34'),
(1001, 'login', '2023-06-16 03:00:15.34'),
(1001, 'logout', '2023-06-16 12:00:15.34');

-- Create the employee_details table
CREATE TABLE #employee_details (
    employeeid INT,
    phone_number VARCHAR(20),
    isdefault BIT
);

-- Insert data into employee_details
INSERT INTO #employee_details (employeeid, phone_number, isdefault) VALUES
(1001, '9999', 0),
(1001, '1111', 0),
(1001, '2222', 1),
(1003, '3333', 0);

select * from #employee_checkin_details
select * from #employee_details

-- method 1

--employeeid,employee_default_phone_number,totalentry,totallogin,totallogout,latestlogin,latestlogout

; with login as (
select employeeid,COUNT(*) as total_login,MAX(timestamp_details) as latestlogin
from #employee_checkin_details 
where entry_details='login' group by  employeeid)
, logout as (
select employeeid,COUNT(*) as total_logout,MAX(timestamp_details) as latestlogout
from #employee_checkin_details 
where entry_details='logout' group by  employeeid )

select l1.employeeid,l1.total_login,l1.latestlogin,
l2.total_logout, l2.latestlogout, l1.total_login + l2.total_logout as totalentry,
e1.phone_number,e1.isdefault
from login l1
inner join logout l2 on l1.employeeid= l2.employeeid
left join #employee_details e1 on l1.employeeid= e1.employeeid and e1.isdefault = 1
--where e1.isdefault = 1   or e1.isdefault is null not correct 


-- Method 2

select l1.employeeid,COUNT(*) as total_entry,
count(case when entry_details='login' then timestamp_details else null end) as totallogins,
count(case when entry_details='logout' then timestamp_details else null end) as totallogout,
max(case when entry_details='login' then timestamp_details else null end) as  latestlogins,
max(case when entry_details='logout' then timestamp_details else null end) as latestlogout,
e1.phone_number
from #employee_checkin_details l1
left join #employee_details e1 on l1.employeeid= e1.employeeid and e1.isdefault = 1
group by l1.employeeid,e1.phone_number


-- Twist
drop table if exists #employee_details
CREATE TABLE #employee_details (
    employeeid INT,
    phone_number VARCHAR(20),
    isdefault BIT,
	Added_on Date
);

-- Insert data into employee_details
INSERT INTO #employee_details (employeeid, phone_number, isdefault,Added_on) VALUES
(1001, '9999', 0,'2023-01-01'),
(1001, '1111', 0,'2023-01-02'),
(1001, '2222', 1,'2023-01-03'),
(1000, '3333', 0,'2023-01-01'),
(1000, '4444', 0,'2023-01-02');

-- get default number - if there is no default number add latest added default number

; with phone as (
select * from (
select *,
ROW_NUMBER () over (partition by employeeid order by added_on desc ) as rn 
from #employee_details where isdefault = 0  ) t where rn=1 )
,login as (
select employeeid,COUNT(*) as total_login,MAX(timestamp_details) as latestlogin
from #employee_checkin_details 
where entry_details='login' group by  employeeid)
, logout as (
select employeeid,COUNT(*) as total_logout,MAX(timestamp_details) as latestlogout
from #employee_checkin_details 
where entry_details='logout' group by  employeeid )

select l1.employeeid,l1.total_login,l1.latestlogin,
l2.total_logout, l2.latestlogout, l1.total_login + l2.total_logout as totalentry,
coalesce(e1.phone_number ,e2.phone_number),e2.isdefault
from login l1
inner join logout l2 on l1.employeeid= l2.employeeid
left join #employee_details e1 on l1.employeeid= e1.employeeid and e1.isdefault = 1
left join phone e2 on l1.employeeid= e2.employeeid  and e2.isdefault = 0


--
with default_ph_num as (
	select distinct employeeid, 
	case when count(case when isdefault='false' then isdefault else null end) = count(isdefault)
	then FIRST_VALUE(phone_number) over(partition by employeeid order by added_on desc) else
	phone_number end default_phone
	from employee_details_twist
	group by employeeid, phone_number, added_on	
)
select cte.employeeid, dp.default_phone, count(entry_details) totalentry,
	sum(case when entry_details='login' then 1 else 0 end) as totallogin,
	sum(case when entry_details='logout' then 1 else 0 end) as totallogout,
	max(case when entry_details='login' then timestamp_details else null end) as latestlogin,
	max(case when entry_details='login' then timestamp_details else null end) as latestlogout
from employee_checkin_details cte
inner join default_ph_num dp
on cte.employeeid=dp.employeeid
group by cte.employeeid, dp.default_phone

--
with base as(

select employeeid,phone_number as default_number 
from tableName1 
where isdefault='true'),base1 as(
select employeeid,count(entry_details) as total_entry,
sum(case when entry_details='login' then 1  else 0 end) as total_logins,
sum(case when entry_details='logout' then 1  else 0 end) as 
total_logouts,
max(case when entry_details='login' then timestamp_details end) as latest_login,
max(case when entry_details='logout' then timestamp_details end) as latest_logout 
from tableName 
group by employeeid)
select ifnull(e.default_number,'none') as default_number,c.* from base as e  right join base1 as c on e.employeeid=c.employeeid


--Solution for TWIST statement Using Ranking

;
WITH cte as (
Select e2.employeeid, e2.isdefault,e2.phone_number,e2.added_on
, COUNT(entry_details)  as totalentry
, COUNT(CASE WHEN entry_details = 'login' THEN timestamp_details END)  as totallogin
, COUNT(CASE WHEN entry_details = 'logout' THEN timestamp_details END) as totallogout
, MAX(CASE WHEN entry_details = 'login' THEN timestamp_details END) as latestlogin
, MAX(CASE WHEN entry_details = 'logout' THEN timestamp_details END) as latestlogout
, DENSE_RANK() over(PARTITION BY e2.employeeid ORDER BY e2.added_on DESC) as RNK
from employee_checkin_details as e1 LEFT JOIN employee_details_twist as e2
on e1.employeeid = e2.employeeid 
group by  e2.employeeid,e2.isdefault,e2.phone_number,e2.added_on )

select *
from cte
where RNK = 1