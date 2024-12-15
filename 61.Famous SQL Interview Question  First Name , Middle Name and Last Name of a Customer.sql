
create table #customers  (customer_name varchar(30))
insert into #customers values ('Ankit Bansal'),('Vishal Pratap Singh'),('Michael'); 

select * from #customers

--
; with cte as (
select *, 
LEN(customer_name)-len(REPLACE(customer_name,' ','')) as no_of_spaces,
CHARINDEX(' ',customer_name) as f_space_position,
CHARINDEX(' ',customer_name,CHARINDEX(' ',customer_name)+1) as s_space_position
from #customers )
select *,
case when no_of_spaces= 0 then customer_name
else SUBSTRING(customer_name,1,f_space_position-1) end as first_name,
case when no_of_spaces<=1 then null
else SUBSTRING(customer_name,f_space_position+1,s_space_position-f_space_position) end as Middle_name,
case when no_of_spaces=0 then null
when no_of_spaces=1 then 
substring(customer_name,f_space_position+1,LEN(customer_name)- f_space_position) 
when no_of_spaces=2 then 
substring(customer_name,s_space_position+1,LEN(customer_name)- s_space_position) 
end as Last_name from cte


--
with cte as(
select * from #customers
cross apply string_split(customer_name,' ') 
)
,cte2 as(
select *,
ROW_NUMBER() over(partition by customer_name order by(select null)) as rn,
count(*) over (partition by customer_name) as cnt
from cte
)
select customer_name,
max(case when rn=1 then value end) as firstname,
max(case when rn=2 and cnt=3  then value end) as middlename,
max(case when (rn=2 and cnt=2) or rn=3  then value end) as lastname
from cte2 
group by customer_name





--

SELECT string_split(customer_name,' ',1) as first_name
,case when string_split(customer_name,' ',3) ='' then  '' else string_split(customer_name,' ',2) end  as second_name
,case when string_split(customer_name,' ',3) ='' then  string_split(customer_name,' ',2)  else string_split(customer_name,' ',3)  end  as third_name
from 
#customers