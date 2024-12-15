

create table #students(
 [studentid] [int] null,
 [studentname] [nvarchar](255) null,
 [subject] [nvarchar](255) null,
 [marks] [int] null,
 [testid] [int] null,
 [testdate] [date] null
)
data:
insert into #students values (2,'max ruin','subject1',63,1,'2022-01-02');
insert into #students values (3,'arnold','subject1',95,1,'2022-01-02');
insert into #students values (4,'krish star','subject1',61,1,'2022-01-02');
insert into #students values (5,'john mike','subject1',91,1,'2022-01-02');
insert into #students values (4,'krish star','subject2',71,1,'2022-01-02');
insert into #students values (3,'arnold','subject2',32,1,'2022-01-02');
insert into #students values (5,'john mike','subject2',61,2,'2022-11-02');
insert into #students values (1,'john deo','subject2',60,1,'2022-01-02');
insert into #students values (2,'max ruin','subject2',84,1,'2022-01-02');
insert into #students values (2,'max ruin','subject3',29,3,'2022-01-03');
insert into #students values (5,'john mike','subject3',98,2,'2022-11-02');

select * from #students

-- list of students who score above avg marks in each subject
; with avg_cte as (
select subject, avg(marks) as avg
from #students group by subject)

select * 
from  #students a 
inner join avg_cte b on a.subject = b.subject
where a.marks > b.avg


--to get % of students who score more than 90 in any subject amongest total students

select 
count (distinct case when marks > 90 then studentid else null end )*1.0/ 
count(distinct studentid)*100 as perc
from #students


-- get second highest and second lowest marks for each subject
/* 
subject	   second_highestmarks	second lowest marks
Subjectl	91		              63
Subject2	71                    60
Subject3	29		              98
*/

;with cte as (
select *,
ROW_NUMBER() over(partition by subject order by marks desc) as rn_desc,
ROW_NUMBER() over(partition by subject order by marks asc) as  rn_asc
from #students )

select subject,
Max(case when rn_desc= 2 then marks else null end) as second_highest_marks,
Max(case when rn_asc= 2 then marks else null end) as second_highest_marks
from cte group by subject

-- For each students and test identify if their marks increased or decreased from prev test
select *,
case when marks > prev_marks then 'inc' 
when marks <  prev_marks then 'dec'
else null end as status
from (
select *, 
LAG(marks,1) over (partition by studentid order by testdate,subject) as prev_marks
from  #students )t

-- Question 4

select studentid, studentname, subject, marks, testdate,
	   (case 
		 when lag(marks,1) over(partition by studentid order by testdate) is null then 'N/A'
                 else (case
				   when marks - lag(marks,1) over(partition by studentid order by testdate) > 0 then 'Increased'
                                   else 'Decreased'
			  end)
	   end) status
from #students;


-- Q4

ith 
cte as (
	select *, lag(marks) over(partition by studentname order by subject asc) as prev_marks
	from students
	)
select *, 
(case when prev_marks is null then 'NA' when prev_marks is not null then 
	(case when (prev_marks - marks) > 0 then 'Decreased' else 'Increased' end) 
end) as comparison 
from cte order by studentid;


--q3

question 3 alternate approach:

with 
second_lowest as (
	select subject, marks, rank() over(partition by subject order by marks asc) as asc_marks from students s
	),
second_highest as (
	select subject, marks, rank() over(partition by subject order by marks desc) as desc_marks from students s
	)
select sh.subject, sh.marks, sl.marks from (
	(select subject, marks from second_lowest where asc_marks = 2) sl inner join (select subject, marks from second_highest where desc_marks = 2) sh on sl.subject = sh.subject)
	order by sh.subject, sh.marks desc;


-- Q3

with asce as (
select 
	subject,
    marks,
    dense_rank() over( partition by subject order by marks asc) as arnk
from students
),

desce as (
select 
	subject,
    marks,
    dense_rank() over( partition by subject order by marks desc) as drnk
from students
)

select  
	a.subject,
    second_highest,
    second_lowest
from (select subject, marks as second_lowest from asce where arnk=2) as a
JOIN (select subject, marks as second_highest from desce where drnk=2) as b
ON a.subject=b.subject


-- Question 3 - 
with a as
(select subject, marks,
rank() over (partition by subject order by marks) as low,
rank() over (partition by subject order by marks desc) as high
from students)
select subject, min(marks) second_lowest, max(marks) second_highest from a where low = 2 or high = 2
group by subject;

--
/*SOLUTION : 1. First CTE simply ranks marks
2. Second CTE uses total_count in each window to get second_lowest marks
3. Uses IF statment to conditionally select marks as for 2 subject count marks critieria inverses*/

WITH CTE1 as (SELECT s.*, COUNT(*) OVER(PARTITION BY subject) as total_student_count,
DENSE_RANK() OVER(PARTITION BY subject ORDER BY marks DESC) as rnk 
FROM #students s)

, CTE2 AS (SELECT * FROM CTE1
WHERE ((total_student_count - 1) = rnk) OR rnk = 2)

SELECT subject, IF(total_student_count <> 2,MAX(marks), MIN(marks)) AS second_highest_marks, IF(total_student_count <> 2,MIN(marks),MAX(marks)) AS second_lowest_marks 
FROM CTE2
GROUP BY subject;


--

--Question3
--write a query to get the second highest and second lowest marks for each subject
with cte1 as(
select studentid,subject,marks,dense_rank() over(partition by subject order by marks) as rnk1,
dense_rank() over(partition by subject order by marks desc) as rnk2
from students
)
select cte1.subject,cte2.marks as second_highest,cte1.marks as second_lowest from cte1 cte1 
     join
     cte1 cte2
     on cte1.subject=cte2.subject
     where cte1.rnk1=2 and cte2.rnk2=2