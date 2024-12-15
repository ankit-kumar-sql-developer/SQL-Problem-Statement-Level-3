-- find sachin milestone/innings
; with cte1 as (
select Match,Innings,Runs,
SUM(runs) over (order by match rows between unbounded preceding and current row) as rolling_sum
from sachin_batting_scores )
,cte2 as (
select 1 as milestone_number,1000 as milestones_runs
 union all
select 2 as milestone_number,5000 as milestones_runs
 union all
select 3 as milestone_number,10000 as milestones_runs )
select milestone_number,milestones_runs,MIN(match) as match_no, MIN(innings) as innings_no
from cte1 a
inner join cte2 b on a.rolling_sum > b.milestones_runs
group by milestone_number,milestones_runs
order by milestone_number

--
WITH CTE_RUNNING_SCORE AS(
SELECT Match,Innings,runs,
floor(SUM(runs)OVER(ORDER BY Match)/1000.0)*1000 AS milestone_runs
FROM  sachin_batting_scores)
SELECT ROW_NUMBER()OVER(ORDER BY milestone_runs) AS milestone_number,
min(Match)AS milestone_match,min(Innings) AS milestone_innings,milestone_runs
FROM CTE_RUNNING_SCORE
WHERE milestone_runs IN(1000,5000,10000)
GROUP BY milestone_runs

--


--
; with cte1  as (
select 1 as mile_number , 50 as mile_runs 
union all
select mile_number + 1 , mile_runs + 50 from cte1 where  mile_number <=9
)
, cte as (
select match , sum(runs) over(order by match asc) as sums from sachin_batting_scores)
select mile_number, mile_runs , min(match)
from cte c
join cte1 c1 
on c.sums >= c1.mile_runs 
group by mile_number, mile_runs


--
;with cte1 as (
SELECT 
		CASE 
			WHEN sum(runs) over ( order by Match,Innings) between 1000 and 4999  then 1
			when sum(runs) over ( order by Match,Innings)  between 5000 and 9999 then 2
			when sum(runs) over ( order by Match,Innings)  >= 10000 then 3
		END as milestone_number
		,case 
			when sum(runs) over ( order by Match,Innings)  between 1000 and 4999 then 1000
			when sum(runs) over ( order by Match,Innings)  between 5000 and 9999 then 5000
			when sum(runs) over ( order by Match,Innings)  >= 10000 then 10000
		END as milestone_runs
		,Match as milestone_match_number
		,Innings as milestone_innings

FROM 
	sachin_batting_scores
)
SELECT 
		milestone_number,
		min(milestone_runs) as milestone_runs,
		min(milestone_innings) as milestone_innings,
		min(milestone_match_number) as milestone_match_number
FROM 
	cte1 
WHERE milestone_number IS NOT NULL
GROUP BY milestone_number


--
/*
Year Rank1 Rank2 Rank3
1989 89     72     55
1990 150    54    45 
1991  65    60     56
*/

; WITH CTE AS
(SELECT
	 DATEPART(YEAR,match_date) as match_year
	,match_date
	,runs
	,DENSE_RANK() over ( partition by DATEPART(YEAR,match_date) order by runs desc ) as rnk
FROM
	sachin_batting_scores
)

SELECT 
	  match_year
	, MIN(CASE WHEN rnk =1 THEN match_date END) AS RANK1_match_date
	, MAX(CASE WHEN rnk=1 THEN runs END) AS RANK1
	, MIN(CASE WHEN rnk =2 THEN match_date END) AS RANK2_match_date
	, MAX(CASE WHEN rnk=2 THEN runs END) AS RANK2
	, MIN(CASE WHEN rnk=3 THEN match_date END) AS RANK3_match_date
	, MAX(CASE WHEN rnk=3 THEN runs END) AS RANK3

FROM
	CTE
GROUP BY 
	match_year;