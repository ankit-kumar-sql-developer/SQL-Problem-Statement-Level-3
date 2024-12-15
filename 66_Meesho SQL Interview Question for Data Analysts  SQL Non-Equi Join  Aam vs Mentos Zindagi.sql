--write an sql to find percentage increase in covid cases versus cumulative cases as of prior month.

create table #covid_cases (record_date date primary key,cases_count int);
insert into #covid_cases (record_date, cases_count) values
('2021-01-01',66),('2021-01-02',41),('2021-01-03',54),('2021-01-04',68),('2021-01-05',16),('2021-01-06',90),('2021-01-07',34),('2021-01-08',84),('2021-01-09',71),('2021-01-10',14),('2021-01-11',48),('2021-01-12',72),('2021-01-13',55),
('2021-02-01',38),('2021-02-02',57),('2021-02-03',42),('2021-02-04',61),('2021-02-05',25),('2021-02-06',78),('2021-02-07',33),('2021-02-08',93),('2021-02-09',62),('2021-02-10',15),('2021-02-11',52),('2021-02-12',76),('2021-02-13',45),
('2021-03-01',27),('2021-03-02',47),('2021-03-03',36),('2021-03-04',64),('2021-03-05',29),('2021-03-06',81),('2021-03-07',32),('2021-03-08',89),('2021-03-09',63),('2021-03-10',19),('2021-03-11',53),('2021-03-12',78),('2021-03-13',49),
('2021-04-01',39),('2021-04-02',58),('2021-04-03',44),('2021-04-04',65),('2021-04-05',30),('2021-04-06',87),('2021-04-07',37),('2021-04-08',95),('2021-04-09',60),('2021-04-10',13),('2021-04-11',50),('2021-04-12',74),('2021-04-13',46),
('2021-05-01',28),('2021-05-02',49),('2021-05-03',35),('2021-05-04',67),('2021-05-05',26),('2021-05-06',82),('2021-05-07',31),('2021-05-08',92),('2021-05-09',61),('2021-05-10',18),('2021-05-11',54),('2021-05-12',79),('2021-05-13',51),
('2021-06-01',40),('2021-06-02',59),('2021-06-03',43),('2021-06-04',66),('2021-06-05',27),('2021-06-06',85),('2021-06-07',38),('2021-06-08',94),('2021-06-09',64),('2021-06-10',17),('2021-06-11',55),('2021-06-12',77),('2021-06-13',48),
('2021-07-01',34),('2021-07-02',50),('2021-07-03',37),('2021-07-04',69),('2021-07-05',32),('2021-07-06',80),('2021-07-07',33),('2021-07-08',88),('2021-07-09',57),('2021-07-10',21),('2021-07-11',56),('2021-07-12',73),('2021-07-13',42),
('2021-08-01',41),('2021-08-02',53),('2021-08-03',39),('2021-08-04',62),('2021-08-05',23),('2021-08-06',83),('2021-08-07',29),('2021-08-08',91),('2021-08-09',59),('2021-08-10',22),('2021-08-11',51),('2021-08-12',75),('2021-08-13',44),
('2021-09-01',36),('2021-09-02',45),('2021-09-03',40),('2021-09-04',68),('2021-09-05',28),('2021-09-06',84),('2021-09-07',30),('2021-09-08',90),('2021-09-09',61),('2021-09-10',20),('2021-09-11',52),('2021-09-12',71),('2021-09-13',43),
('2021-10-01',46),('2021-10-02',58),('2021-10-03',41),('2021-10-04',63),('2021-10-05',24),('2021-10-06',82),('2021-10-07',34),('2021-10-08',86),('2021-10-09',56),('2021-10-10',14),('2021-10-11',57),('2021-10-12',70),('2021-10-13',47),
('2021-11-01',31),('2021-11-02',44),('2021-11-03',38),('2021-11-04',67),('2021-11-05',22),('2021-11-06',79),('2021-11-07',32),('2021-11-08',94),('2021-11-09',60),('2021-11-10',15),('2021-11-11',54),('2021-11-12',73),('2021-11-13',46),
('2021-12-01',29),('2021-12-02',50),('2021-12-03',42),('2021-12-04',65),('2021-12-05',25),('2021-12-06',83),('2021-12-07',30),('2021-12-08',93),('2021-12-09',58),('2021-12-10',19),('2021-12-11',52),('2021-12-12',75),('2021-12-13',48);


select * from #covid_cases

-- Method 1 Non-Equi Join

; with cte as (
select MONTH(record_date) as record_month, SUM(cases_count) as monthly_cases
from #covid_cases group by  MONTH(record_date) )
, cte2 as (
select c.record_month as currentmonth, p.record_month as prevmonth,
c.monthly_cases as currentcount,p.monthly_cases as prevcount
from cte c
left join cte p on p.record_month < c.record_month )

select currentmonth,currentcount, SUM(prevcount) as cum_sum,
Round(currentcount*100.0/SUM(prevcount),1) as perc
from cte2 group by currentmonth,currentcount


-- Method 2 Advance Aggregation

; with cte as (
select MONTH(record_date) as record_month, SUM(cases_count) as monthly_cases
from #covid_cases group by  MONTH(record_date) )

select *, 
SUM(monthly_cases) over (Order by record_month rows between unbounded preceding and 1 preceding),
monthly_cases*100.0/SUM(monthly_cases) over (Order by record_month rows between unbounded preceding and 1 preceding)
from cte


---
CREATE TABLE covid_cases (
    record_date DATE PRIMARY KEY,
    cases_count INT
);

DECLARE @end_date date;
DECLARE @loop_date date;
DECLARE @num INT;
set @end_date = '2021-12-31'
set @loop_date = '2021-01-01'

WHILE @loop_date <= @end_date
BEGIN
	select @num = floor(RAND()*(1000-500)+500);
    insert into covid_cases(record_date, cases_count) values(@loop_date, @num);
    select @loop_date = dateadd(day, 1, cast(@loop_date as date));
END


--
with cte as(
select year(record_date) year, format(record_date, 'MMM') month, 
Datepart(month, record_date) month_no, sum(cases_count) total_cases from covid_cases
group by year(record_date), format(record_date, 'MMM'), Datepart(month, record_date)),
cte2 as(
select year, month, total_cases, coalesce(sum(total_cases) 
over(order by year, month_no rows between unbounded preceding and 1 preceding), 0) as rolling_sum
from cte)
select concat_ws('-', year, month) month, total_cases, 
IIF(rolling_sum = 0, 0, cast(100*total_cases/cast(rolling_sum as float) as decimal(10,1))) as percentage
from cte2

--

