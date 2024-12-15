-- find companies who have atleast 2 users and speaks english & german both 

create table #company_users 
(
company_id int,
user_id int,
language varchar(20)
);

insert into #company_users values (1,1,'English')
,(1,1,'German')
,(1,2,'English')
,(1,3,'German')
,(1,3,'English')
,(1,4,'English')
,(2,5,'English')
,(2,5,'German')
,(2,5,'Spanish')
,(2,6,'German')
,(2,6,'Spanish')
,(2,7,'English');

select * from #company_users

--
select company_id,COUNT(1) from (
select company_id,user_id,count(1) as cnt
from #company_users where language in ('English','German')
group by company_id,user_id
having count(1) =2  ) a
group by company_id having COUNT(1) >=2

--
;with cte_agg as 
(
	select company_id,user_id,STRING_AGG(language,'-') within group 
	(order by language) as all_language
	from #company_users group by company_id,user_id) 
,cte2 as (
	select * from cte_agg
	where all_language like '%English%German%')
select company_id from cte2
cross apply string_split(all_language,'-') 
group by company_id
having count(distinct user_id) >=2

--

;with cte as(
select distinct company_id, user_id from #company_users
group by company_id,user_id
having 
sum( case when language in ('English','German') then 1 else 0 end )=2
)
select company_id
from cte
group by company_id
having count(user_id)>=2

--

;with CTE as (
	select company_id,user_id, ROW_NUMBER() over(partition by company_id,user_id order by company_id) as RN
	from #company_users
	where language in ('English','German')
)
select company_id,COUNT(user_id) from CTE 
	where RN=2
	group by company_id
	having COUNT(user_id)>=2;

--

;with cte as (
  select a.company_id, a.user_id, a.language, b.language  
  from #company_users a 
  inner join #company_users b 
  on a.user_id = b.user_id
  and a.language = 'English' and b.language = 'German'
  )
 select company_id from cte
  group by company_id
  having count(user_id) >= 2;

 --

; with temp as (
    select *, row_number() over (partition by user_id order by user_id) as rn
    from #company_users
    where language in('English','German')
)
select company_id, count(user_id) as num_of_users
from temp
where rn > 1
group by company_id
having count(user_id) > 1;

--
select company_id, count(company_id) as [no. of companies] from(
select company_id, user_id, sum(case when language in ('English','German') then 1 else 0 end) as s
from #company_users group by company_id, user_id ) as t1
where s=2
group by company_id
having count(company_id)>1;

--

;with cte as (
select company_id,user_id,language
,case when language='English' then 1
      when language='German' then 2
	  else 0 end as flag
from #company_users)
,cte2 as (
select company_id,user_id,sum(flag)sflag from cte 
group by company_id,user_id
having  sum(flag)=3)
select company_id companyId from cte2
group by company_id
having count(1)>1

--

with cte1 as (
Select * from #company_users where language = 'English'),
cte2 as (
select * from #company_users where language = 'German')
select a.company_id from cte1 a join cte2 b on a.user_id = b.user_id
group by a.company_id having count(*)=2

--