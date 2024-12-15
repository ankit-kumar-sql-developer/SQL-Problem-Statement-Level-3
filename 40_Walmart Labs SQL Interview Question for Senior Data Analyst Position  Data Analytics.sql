
create table #phonelog(
    Callerid int, 
    Recipientid int,
    Datecalled datetime
);

insert into #phonelog(Callerid, Recipientid, Datecalled)
values(1, 2, '2019-01-01 09:00:00.000'),
       (1, 3, '2019-01-01 17:00:00.000'),
       (1, 4, '2019-01-01 23:00:00.000'),
       (2, 5, '2019-07-05 09:00:00.000'),
       (2, 3, '2019-07-05 17:00:00.000'),
       (2, 3, '2019-07-05 17:20:00.000'),
       (2, 5, '2019-07-05 23:00:00.000'),
       (2, 3, '2019-08-01 09:00:00.000'),
       (2, 3, '2019-08-01 17:00:00.000'),
       (2, 5, '2019-08-01 19:30:00.000'),
       (2, 4, '2019-08-02 09:00:00.000'),
       (2, 5, '2019-08-02 10:00:00.000'),
       (2, 5, '2019-08-02 10:45:00.000'),
       (2, 4, '2019-08-02 11:00:00.000');


select * from #phonelog

--
; with cte as (
select callerid,
cast(Datecalled as date) as Datecalled,
MIN(Datecalled) as first_call,MAX(Datecalled) as last_call
from #phonelog
group by callerid,cast(Datecalled as date) )
, cte2 as (
select a.*, b.Recipientid as first_r,c.Recipientid as last_r,
case when b.Recipientid=c.Recipientid then 1 else 0 end as flag
from cte a
inner join #phonelog b on a.Callerid=b.Callerid
and a.first_call= b.Datecalled 
inner join #phonelog c on a.Callerid=c.Callerid
and a.last_call= c.Datecalled )
select * from cte2 where flag=1

--

;WITH cte AS (
SELECT Callerid, Recipientid, CAST(Datecalled AS DATE) as Datecalled FROM #phonelog)
,cte2 AS (
SELECT *,
FIRST_VALUE(Recipientid) OVER(PARTITION BY Datecalled ORDER BY Datecalled) as first_value,
LAST_VALUE(Recipientid) OVER(PARTITION BY Datecalled ORDER BY Datecalled) as last_value
FROM cte )

SELECT Callerid, Datecalled, MAX(first_value) AS Recipientid 
FROM cte2
WHERE first_value = last_value
GROUP BY Callerid, Datecalled;

--
with cte as
(
select *
, row_number() over(partition by cast(datecalled as date) order by datecalled) as rn_d
, row_number() over(partition by cast(datecalled as date) order by datecalled desc) as rn_a
,cast(datecalled as date) as  only_dt
from bmssdstg.phonelog
)

select Callerid,Recipientid,  only_dt from cte
where (rn_d = 1 or rn_a =1)
group by 1, 2,3
having count(*)  = 2


--
with cte as (select *,ROW_NUMBER()over(partition by callerid,cast(datecalled as date) order by Datecalled) as rn,
ROW_NUMBER()over(partition by callerid,cast(datecalled as date) order by Datecalled DESC) as rnk
from  phonelog),

cte2 as (select * from cte
where rn=1 or rnk=1)

select callerid,recipientid
from cte2
group by callerid,recipientid
having count(*)>1


--

with cte as (
select *, min(Datecalled) over(partition by date(Datecalled)) as first_call, max(Datecalled) over(partition by date(Datecalled)) as last_call from phonelog),
cte1 as(
select *, lag(Recipientid) over() as lags from cte where Datecalled=first_call or Datecalled=last_call)
select Callerid, Recipientid, Datecalled, first_call, last_call from cte1 where Recipientid=lags;

--
--- caller with only one call per day is not to be displayed ) 
with cte as 
(SELECT 
*, CAST (Datecalled as date) as calling_date
,COUNT(Datecalled) over (partition by Callerid,CAST (Datecalled as date) order by Datecalled range between unbounded preceding and unbounded following) as call_count ---- Get caller/call per day count
,FIRST_VALUE(Recipientid) over (partition by Callerid,CAST (Datecalled as date) order by Datecalled) as first_outgoing_recpt
,LAST_VALUE(Recipientid) over (partition by Callerid,CAST (Datecalled as date) order by Datecalled range between unbounded preceding and unbounded following) as last_outgoing_recpt
FROM #phonelog
)

SELECT Callerid,first_outgoing_recpt As Recipientid , max(calling_date) as calling_date
FROM cte  
WHERE first_outgoing_recpt =last_outgoing_recpt AND call_count>1   --- filter caller/one call per day
GROUP BY Callerid, first_outgoing_recpt, last_outgoing_recpt

--
;with cte as (

    SELECT * 
      , fcall = first_value(recipientid) over(partition by cast(datecalled as date) order by datecalled)
      , lcall = first_value(recipientid) over(partition by cast(datecalled as date) order by datecalled desc)
	from #phonelog
)

select distinct
	  callerid
	, called_date = cast(datecalled as date)
	, fcall as recipientid
from cte 
where fcall = lcall
--

select callerid,recipientid,to_char(datecalled,'yyyy-mm-dd'),count(*)  from (
select callerid,recipientid ,datecalled,
rank() over(partition by callerid,to_char(datecalled,'yyyy-mm-dd')  order by datecalled asc ) as call_rank from phonelog
union 
select callerid,recipientid ,datecalled,
rank() over(partition by callerid,to_char(datecalled,'yyyy-mm-dd') order by datecalled desc) as call_rank  from phonelog 
) a where call_rank=1
group by 1,2,3
having count(*) =2
--

/*
what happens when there is only one call in the day for the one caller? (add the following to the data) excluding or including that record would be in error as an undefined state by the requester even though the grammar of the question implies there is at least 2 calls.

insert into phonelog(Callerid, Recipientid, Datecalled)
values(3, 2, '2019-01-01 12:00:00.000');

I prefer a partition window.

select callerid, recipientid, datecalled from (
select *, row_number() over win as r, first_value(recipientid) over win as a, last_value(recipientid) over win as b, count(*) over win as c
from phonelog 
window win as (partition by callerid, date(datecalled) order by datecalled RANGE BETWEEN UNBOUNDED PRECEDING AND unbounded following )
) x where c>1 and r=1 and a=b;


The answer provided is better than mine for two reasons... [a] depending on the sql engine the internal performance tuning is data dependent  [b] the joins are likely to work on most sql engines where partitions are questionable (thanks oracle)

Looking at this data it's clear upfront that it's going to result in at exactly one scan.
(think: select * from phonelog order by callerid, datecalled, and then write some perl or 
even SQL code to iterate over the results a row at a time) but that's what the partition does.
Also testing the number of rows in the partition is pretty simple. The only challenge is
understanding the "range")

*/