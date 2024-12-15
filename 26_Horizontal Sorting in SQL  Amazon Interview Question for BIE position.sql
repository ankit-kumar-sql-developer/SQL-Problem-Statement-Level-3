
-- FIND TOTAL NO OF MESSAGES EXCHANGES BETWEEN EACH PERSON PER DAY
create table #subscriber (
 sms_date date ,
 sender varchar(20) ,
 receiver varchar(20) ,
 sms_no int
);
-- insert some values
insert into #subscriber values ('2020-4-1', 'avinash', 'vibhor',10);
insert into #subscriber values ('2020-4-1', 'vibhor', 'avinash',20);
insert into #subscriber values ('2020-4-1', 'avinash', 'pawan',30);
insert into #subscriber values ('2020-4-1', 'pawan', 'avinash',20);
insert into #subscriber values ('2020-4-1', 'vibhor', 'pawan',5);
insert into #subscriber values ('2020-4-1', 'pawan', 'vibhor',8);
insert into #subscriber values ('2020-4-1', 'vibhor', 'deepak',50);

select * from #subscriber

--
select sms_date,p1,p2,SUM(sms_no) as total from (
select sms_date,
case when  sender < receiver then sender else receiver end as P1,
case when  sender > receiver then sender else receiver end as P2
,sms_no
from #subscriber ) t
group by sms_date,p1,p2

--

;with cte1 as (select sender,receiver,sms_no 
from subscriber where sender>receiver)

, cte2 as (select sender,receiver,sms_no 
from subscriber where sender<receiver)

select a.sender,a.receiver,sum(a.sms_no)+coalesce(sum(b.sms_no),0) as total_msg
from cte1 a left join cte2 b on a.sender=b.receiver and b.sender=a.receiver
group by a.sender,a.receiver;

--
WITH CTE AS (
SELECT *, (CASE WHEN sender < receiver THEN CONCAT(sender,' ',receiver) ELSE CONCAT(receiver,' ',sender) END) AS couple 
FROM subscriber );
SELECT sms_date, max(sender) as Person1,min(receiver) as Person2,
SUM(sms_no) as sms_count
FROM CTE
GROUP BY sms_date,couple;

--
with cte as (
Select sms_date, sender, receiver, sms_no 
from subscriber 
where sender>receiver 
union all 
Select sms_date, receiver,sender, sms_no 
from subscriber 
where sender<receiver 
)
Select sender, receiver, sum(sms_no) as total_sms, sms_date
from cte 
group by sender,receiver,sms_date

--
select s1.sms_date,s1.sender,s1.receiver,s1.sms_no+s2.sms_no  as sms_count,
row_number() over (partition by s1.sms_date order by s1.sms_date) as rn
from subscriber s1 inner join subscriber s2
on s1.sender=s2.receiver and s1.receiver=s2.sender)
select * from cte where rn%2=0

--

select sms_date,greatest(sender,receiver),least(sender,receiver),sum(sms_no) 
from subscriber group by sms_date,greatest(sender,receiver),least(sender,receiver);

--
select sms_date,
case when LOWER(sender)<LOWER(receiver) then sender+' '+receiver else receiver+' '+sender end as sorted,sum(sms_no) as no_sms
from subscriber
group by sms_date,case when LOWER(sender)<LOWER(receiver) then sender+' '+receiver else receiver+' '+sender end

--


select sms_date,concat(sender," ",receiver) pair,sum(sms_no) sms_no from 
(select * from subscriber
union all
select sms_date,receiver,sender,sms_no from subscriber) a
where sender < receiver group by sms_date,pair order by sms_no desc

--
WITH CTE AS(
SELECT S1.*,S2.sms_no AS sms_to_sender,COALESCE((S2.sms_no+S1.sms_no),S1.sms_no) AS total_messages 
FROM subscriber S1
LEFT JOIN subscriber S2
ON S1.sender=S2.receiver AND S1.receiver=S2.sender)
SELECT sms_date,sender,receiver,total_messages
FROM CTE
WHERE sender<receiver
OR sms_to_sender IS NULL;

--

