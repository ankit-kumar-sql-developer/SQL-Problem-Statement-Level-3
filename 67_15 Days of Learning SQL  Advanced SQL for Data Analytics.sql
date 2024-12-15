/*write a query to print total number of unique hackers who made at least 1 submission each day 
starting on the first day of the contest and find the hacker id and name of the hacker who made
maximum number of submissions each day.
if more than one such hacker has a maximum number of submissions, print the lowest hacker id.
the query should print this information for each day of the contest, sorted by the date.*/


create table #submissions (
    submission_date date,
    submission_id int primary key,
    hacker_id int,
    score int
);

insert into #submissions (submission_date, submission_id, hacker_id, score) values
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 15),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

select * from #submissions

--
; with cte as (
select submission_date,hacker_id,COUNT(*) as no_of_submission,
DENSE_RANK() over (order by submission_date) as day_number
from #submissions group by submission_date,hacker_id )
, cte2 as (
select *,
COUNT(*) over (partition by hacker_id order by submission_date ) as till_date_submissions,
case when day_number= COUNT(*) over (partition by hacker_id order by submission_date ) then 1 else 0 end as Flag
from cte )
, cte3 as (
select *,
SUM(Flag) over (partition by submission_date) as cnt,
ROW_NUMBER() over (partition by submission_date order by no_of_submission desc, hacker_id) as rn 
FROM cte2)

select * 
from cte3 where rn=1 order by submission_date