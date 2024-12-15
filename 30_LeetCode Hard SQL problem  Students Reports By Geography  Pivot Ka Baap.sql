
create table #players_location
(
name varchar(20),
city varchar(20)
);
delete from #players_location;
insert into #players_location
values ('Sachin','Mumbai'),('Virat','Delhi') , ('Rahul','Bangalore'),('Rohit','Mumbai'),('Mayank','Bangalore');

select * from #players_location

--
select player_groups,
Max(case when city='Bangalore' then name end) as Bangalore,
max(case when city='Mumbai' then name end) as Bangalore,
max(case when city='Delhi' then name end) as Bangalore
from
(
select *,
ROW_NUMBER() over (partition by city order by name asc ) as player_groups
from #players_location ) a
group by player_groups


--

DECLARE @cols AS NVARCHAR(MAX);
DECLARE @query AS NVARCHAR(MAX);

-- Get distinct cities
SELECT @cols = STRING_AGG(QUOTENAME(city), ',') WITHIN GROUP (ORDER BY city)
FROM (SELECT DISTINCT city FROM #players_location) AS Cities;
--print @cols;


SET @query = '
SELECT *
FROM (
    SELECT name, city, ROW_NUMBER() OVER (PARTITION BY city ORDER BY name) AS rn
    FROM #players_location
) AS SourceTable
PIVOT
(
    MAX(name) FOR city IN (' + @cols + ')
) AS PivotTable
ORDER BY rn;
';

EXECUTE(@query);

--

SELECT Bangalore, Mumbai, Delhi
FROM (
SELECT *
      ,ROW_NUMBER() OVER(PARTITION BY city ORDER BY name ASC) AS rnk
FROM #players_location
) AS a
PIVOT(MIN(name) FOR city in (Bangalore, Mumbai, Delhi)) AS b
ORDER BY rnk;

--