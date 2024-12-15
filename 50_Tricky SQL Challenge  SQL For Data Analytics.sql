
/*Problem statement : we have a table which stores data of multiple sections. every section has 3 numbers
we have to find top 4 numbers from any 2 sections(2 numbers each) whose addition should be maximum
so in this case we will choose section b where we have 19(10+9) then we need to choose either C or D
because both has sum of 18 but in D we have 10 which is big from 9 so we will give priority to D.
*/

create table #section_data
(
section varchar(5),
number integer
)
insert into #section_data
values ('A',5),('A',7),('A',10) ,('B',7),('B',9),('B',10) ,('C',9),('C',7),('C',9) ,('D',10),('D',3),('D',8);

select * from #section_data

--
; with cte as (
select *,
ROW_NUMBER () over (partition by section order by number desc) as rn 
from #section_data )
, cte_sum as (
select *,
SUM(number) over (partition by section) as running_sum,
MAX(number) over (partition by section ) as section_max
from cte where rn <=2 ) 
, cte3 as (
select *,
dense_RANK() over (order by running_sum desc, section_max desc ) as rn2
from cte_sum )

select section,number
from cte3 where rn2<=2



--
; with cte as (
select *,
ROW_NUMBER () over (partition by section order by number desc) as rn 
from #section_data )
, cte_sum as (
select *,
SUM(number) over (partition by section) as running_sum 
from cte where rn <=2 ) 
, cte3 as (
select *,
dense_RANK() over (order by running_sum desc ) as rn2
from cte_sum )

select a.section,a.number
from cte3 a 
inner join cte3 b on a.section= b.section 
and a.number > b.number
where a.rn2<=2 

union all

select a.section,a.number
from cte3 a 
inner join cte3 b on a.section= b.section 
and a.number < b.number
where a.rn2<=2 order by section asc


--

WITH CTE AS
(
SELECT top 2
section, number, 
LEAD(number,1) OVER (PARTITION BY section ORDER BY number DESC) AS lead_number, 
ROW_NUMBER() OVER (PARTITION BY section ORDER BY number DESC) as rn
FROM #Section_data
ORDER BY number + LEAD(number,1) OVER (PARTITION BY section ORDER BY number DESC) DESC, 2 DESC, 4 
)

SELECT section, number FROM CTE WHERE rn = 1
UNION
SELECT section, lead_number FROM CTE WHERE rn = 1;

--
;with cte1 as (
SELECT section,min(number) min FROM #section_data
GROUP by section )
,cte2 as ( SELECT s.section,s.number FROM #section_data s left join cte1 c on s.number=c.min and s.section=c.section
WHERE c.section is null )
,cte3 as ( SELECT section, sum(number) SUM
FROM cte2 GROUP by section )
SELECT top 4 c2.section,c2.number,c3.sum from cte2 c2 inner join cte3 c3 on c2.section=c3.section ORDER by sum, number DESC

--

WITH cte1 AS (
    SELECT 
    	section, number,
    	DENSE_RANK() OVER(PARTITION BY section ORDER BY number desc) AS rn,
    	MAX(number) OVER(PARTITION BY section) AS max_number,
   	(SUM(number) OVER(PARTITION BY section) -  MIN(number) OVER(PARTITION BY section)) AS max2_sum
   FROM #section_data)

 SELECT TOP 4
    	section, number      
    FROM cte1
    	WHERE rn <= 2
   	    ORDER BY max2_sum DESC, max_number DESC
       


 --

 SELECT
t1.section,
t2.section,
t1.number,
t2.number,
t1.number + t2.number AS total
FROM
section_data t1
JOIN
section_data t2 ON t1.section < t2.section
WHERE
(t1.section = 'A' OR t1.section = 'B')
AND (t2.section = 'C' OR t2.section = 'D')
ORDER BY
total DESC
LIMIT
4;

/*Explanation:

First, we join the section_data table with itself using a self-join on section column, where the section value in the left table is less than the section value in the right table. This ensures that we get only unique pairs of sections.

Next, we filter the results to include only the sections we want - either A or B for the first number, and either C or D for the second number.

Then, we calculate the sum of the two numbers for each pair of sections using the + operator and alias it as total.

Finally, we sort the results in descending order of total and limit the output to 4 rows.

This query will give us the top 4 numbers from any 2 sections whose addition should be maximum.
*/


--

with cte1 as(
select section,number,
lead(number) over(partition by section order by number desc) as next_no,
sum(number) over(partition by section order by number desc rows between current row and 1 following) as sum_num
from section_data
),
cte2 as(
select *
from cte1 c
 where sum_num=(select max(sum_num) from cte1 group by section having section=c.section)
 order by sum_num desc,number desc limit 2
)
select section,number from cte2
union 
select section ,next_no from cte2
order by section;


--
with cte as (
select *, 
dense_rank() over(partition by section order by number desc) as dnk
, SUM(number) over(partition by section order by number desc rows between unbounded preceding and current row) as RollingSum
, row_number() over(partition by section order by section) as rn
from section_data)

,filter_sections as (
select a.section as a, b.section as b, a.number as a_no, b.number as b_no, a.RollingSum as a_sum, b.RollingSum as b_sum
from cte a 
inner join cte b on a.dnk = b.dnk and a.number > b.number
where a.rn <=2 and b.rn <=2 and a.dnk = 2 )

,sections as (
select a as section, a_sum as Rolling_sum
from filter_sections 
union
select b, b_sum
from filter_sections )

select A.section, B.number from (
select section, Rolling_sum, dense_rank() over(order by Rolling_sum desc) as dnk
from sections ) A
inner join cte B on A.section = B.section 
where A.dnk <=2 and B.dnk <=2;

--

with cte as
(
(select  distinct section, max(number) number
from section_data
where number <(select distinct max(number) from section_data)
group by section
union all
select section,max(number) number
from section_data
group by section)
)
,cte2 as
(select*,first_value(number) over(partition by section order by number)+first_value(number) over(partition by section order by number desc) total,
first_value(number) over(partition by section order by number desc) sec_mark
from cte)
,cte3 as
(
select *,first_value(number) over(partition by section order by number) first_value
from cte2
)
,cte4 as
(
select *,dense_rank() over(order by total desc, sec_mark desc) ff
from cte3
)
select section,number
from cte4
where ff <= 2

--

with cte as(
select * from #section_data as s where
( select count(*) from #section_data as f
where f.section=s.section and f.number>=s.number)<=2 )
,cte2 as
(select section , sum(number)as s ,max(number)as n 
from cte group by section)
select*from cte where section in ( 
select section from (select*,DENSE_RANK()over(order by s desc,n desc)
as r from cte2)as t where r<=2)

--
with top_two_cte as (
select *
from(
select *, row_number() over(partition by section order by number desc) as num_rank 
from section_data) a
where num_rank=1 or num_rank=2)

select a.section,a.number
from top_two_cte a
join
(
select section,sum(number) as num_sum,max(number) as max_num
from top_two_cte
group by section) b on a.section=b.section
order by b.num_sum desc,b.max_num desc
limit 4;


--

--# This CTE achieves the highest and lowest numbers each group based on dense_ranking. Any repetitive numbers are ignored in any section (will be considered once)

with
    cte
    as
    (
        select section,
            MAX(rnk_1) rank_1, MAX(rnk_2) rank_2
        from
            (select
                section,
                case when rn = 1 then number end as rnk_1
, case when rn = 2 then number end as rnk_2
            FROM
                (select *
, DENSE_RANK() over (PARTITION by section order by number desc) as rn
                from section_data) A
            where rn in (1,2)) B
        group by section
    )

--# this CTE will now take out ranking for those sections which have highest sum of numbers based on results of previous CTE. And select first 2 ranks..
,
    pre_final_qry
    as
    (
        select *
        from
            (select *
, RANK() over (order by (rank_1 + rank_2) desc) as rnk
            from cte) C
        where  rnk in (1,2)
    )

--# finally we break them in form of original table and order them to exactly get result in desired format.

    select section, rank_1 as number
    from pre_final_qry
union ALL
    select section , rank_2 as number
    from pre_final_qry
order by 1, 2 desc


--

with cte as(
 select * from 
(values ('A',5),('A',7),('A',10) ,('B',7),('B',9),('B',10) ,('C',9),('C',7),('C',9) ,('D',10),('D',3),('D',8)) as tb(section,number)) 

,cte2 as( 
select a.section,
 ROW_Number() over(order by sum(c.number) desc,max(c.number) desc) as dn 
from cte a 
cross apply (select top 2 number from cte b where a.section=b.section order by number desc) c 
group by a.Section) 
Select a.Section,c.Number from cte2 a cross apply (select top 2 number from cte b where a.section=b.section order by number desc) c
 where dn<=2

 --

 -lag the number and flag the largest number row of each section with 1
with cte as (select *,
lag(number) over(partition by section order by number) as lagging,
case when row_number() over(partition by section order by number)=count(SECTION) over(partition by section)  then 1 else 0 end as flag
from section_data),

--select only top 2 with cumulativeSum and given number
cte2 as (select top 2 *,number+lagging as cum_sum ,concat(number,lagging) as agg from cte
where flag=1
order by cum_sum desc,number desc)

--unpivot and proper order
select section,number from (
select section,lagging as number,cum_sum from cte2
union all
select section,number,cum_sum from cte2
) a order by cum_sum desc,number desc

