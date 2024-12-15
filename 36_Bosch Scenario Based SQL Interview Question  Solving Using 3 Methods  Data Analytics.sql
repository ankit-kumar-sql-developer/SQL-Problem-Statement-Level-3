
/* write a sql to determxne phone numbers that satisfy below conditions:
1- the numbers have both incoming and outgoing calls
2- the sum of duration of outgoing calls should be greater than sum of duration of incoming calls * /
*/



create table #call_details  (
call_type varchar(10),
call_number varchar(12),
call_duration int
);

insert into #call_details
values ('OUT','181868',13),('OUT','2159010',8)
,('OUT','2159010',178),('SMS','4153810',1),('OUT','2159010',152),('OUT','9140152',18),('SMS','4162672',1)
,('SMS','9168204',1),('OUT','9168204',576),('INC','2159010',5),('INC','2159010',4),('SMS','2159010',1)
,('SMS','4535614',1),('OUT','181868',20),('INC','181868',54),('INC','218748',20),('INC','2159010',9)
,('INC','197432',66),('SMS','2159010',1),('SMS','4535614',1);

select * from #call_details

-- cte and filter clause
; with cte as (
select call_number,
sum(case when call_type='OUT' then call_duration else null end) as out_duration,
sum(case when call_type='INC' then call_duration else null end) as in_duration
from #call_details
group by call_number )
select * from cte where out_duration is not null and in_duration is not null
and out_duration > in_duration

--using having clause
select call_number
from #call_details
group by call_number
having 
sum(case when call_type='OUT' then call_duration else null end)>0
and sum(case when call_type='INC' then call_duration else null end) >0
and sum(case when call_type='OUT' then call_duration else null end) >
sum(case when call_type='INC' then call_duration else null end)


--using cte and join
; with cte as (
select call_number,
sum(call_duration) as out_duration
from #call_details where call_type='OUT'
group by call_number )
,cte2 as (
select call_number,
sum(call_duration) as out_duration
from #call_details where call_type='INC'
group by call_number )

select *
from cte a
inner join cte2 b on a.call_number= b.call_number
where a.out_duration > b.out_duration

--
with cte as
(
select call_number, [OUT],[INC],[SMS] from #call_details
PIVOT
(
sum(call_duration) for call_type IN ([OUT],[INC],[SMS])
)as pivotTbl
)
select * from cte
where OUT > INC


--
with cte1 as (
select call_number,call_type , sum(call_duration) as duration
,rank() over ( partition by call_number order by call_type) as rnk
from #call_details 
where call_type <> 'SMS' group by call_number,call_type)

, cte2 as (Select * ,
lead(duration,1,0) over ( partition by call_number order by call_type ) as out_duration from cte1 )

Select * from cte2 where out_duration > duration;

--
with cte as (
        select call_type, call_number, sum(call_duration) call_duration 
        from call_details
        where call_type <> 'SMS'
        group by 1,2)
select call_number
from cte a
where exists (select 1 from cte b where (b.call_type = 'INC') and (b.call_number = a.call_number) and (b.call_duration < a.call_duration))

--