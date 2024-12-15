/*-- Write an SQL query to report	the	students (student_id, student _ name) 
being "quiet" in ALL	exams .
-- A "quite" student is the one who	took at least one exam and didn't score neither the high	
score nor the low score in any of the exam.
-- Don't return the student who	has	never taken any exam. Return the result table ordered by	student id.		
*/

create table #students
(
student_id int,
student_name varchar(20)
);
insert into #students values
(1,'Daniel'),(2,'Jade'),(3,'Stella'),(4,'Jonathan'),(5,'Will');

create table #exams
(
exam_id int,
student_id int,
score int);

insert into #exams values
(10,1,70),(10,2,80),(10,3,90),(20,1,80),(30,1,70),(30,3,80),(30,4,90),(40,1,60)
,(40,2,70),(40,4,80);

select * from #exams
select * from #students

--
; with cte as (
select exam_id, MIN(score) as min_score, MAX(score) as max_score
from #exams
group by exam_id )
select student_id,
max(case when score=min_score or score=max_score then 1 else 0 end) as flag
from cte a
inner join #exams b on a.exam_id = b.exam_id
group by student_id 
having max(case when score=min_score or score=max_score then 1 else 0 end) =0
--and b.score<>a.min_score and b.score<> a.max_score


--
with cte as (
select *,
max(score) over(partition by exam_id) as max_score,
min(score) over(partition by exam_id) as min_score,
count(*) over(partition by student_id) as cnt from #exams)
select cte.student_id, student_name 
from cte join #students 
on cte.student_id = #students.student_id
where min_score < score and score < max_score
group by cte.student_id,student_name having max(cnt) = count(*)

--
with cte as 
	(select e.STUDENT_ID,dense_rank() over (partition by EXAM_ID order by SCORE desc) as TOPrnk,
    dense_rank() over (partition by EXAM_ID order by SCORE) as LOWrnk from #exams e)
select STUDENT_ID from #exams
except
select STUDENT_ID from cte 
    where TOPrnk = 1 or LOWrnk = 1;

--
with cte as (
select e.*, s.student_name,
min(score) over(partition by exam_id order by score asc) as min_marks,
max(score) over(partition by exam_id order by score desc) as max_marks
from exams e inner join students s on e.student_id = s.student_id 
)
select distinct student_id, student_name from cte 
where student_id not in (
select student_id  from cte 
where score = min_marks or score = max_marks )

--

with cte as (
select a.*, b.student_name,
dense_rank() over(partition by exam_id order by score asc) as low,
dense_rank() over(partition by exam_id order by score desc) as high
from exams a
inner join students b 
on a.student_id = b.student_id)

select student_name from cte
group by student_name
having min(low) <> 1 and min(high) <> 1;

--

with q1 as 
(
  select *,
  row_number() over(partition by exam_id order by score) as rn,
  count(*)  over(partition by exam_id order by score range between unbounded preceding and unbounded following) as cnt
  from exams
)
select distinct student_id from q1 where student_id not in (select distinct(student_id) from q1 where rn=1 or rn=cnt);


--

WITH A AS(
             SELECT E_ID,STUDENTS.ID,SCORE,
             MAX(SCORE) OVER(PARTITION BY             E_ID)MAX_SCORE,
              MIN(SCORE) OVER(PARTITION BY           E_ID)MIN_SCORE
             FROM STUDENTS JOIN EXAM ON       STUDENTS.ID=EXAM.ID )

SELECT ID ,MAX(CASE WHEN SCORE IN( MAX_SCORE ,MIN_SCORE)THEN 1 ELSE 0 END) AS AH
FROM A GROUP BY ID HAVING MAX(CASE WHEN SCORE IN (MAX_SCORE,MIN_SCORE)THEN 1 ELSE 0 END)=0  ;

--
with cte_1 as(
select *,
max(score) over(partition by exam_id order by student_id rows between unbounded PRECEDING and unbounded FOLLOWING ) as max_score,
min(score) over(partition by exam_id order by student_id) as min_score
from #exams)
select * from cte_1 WHERE student_id not in
(select student_id from cte_1 where score = max_score or score = min_score)

--

with cte as ( 
select *,
FIRST_VALUE(score) over(partition by exam_id order by score desc) as hig,
FIRST_VALUE(score) over(partition by exam_id order by score asc) as low
from #exams )
select cte.student_id,s.student_name
from cte
INNER JOIN #students s on cte.student_id=s.student_id
group by cte.student_id,s.student_name
having max(case when score = hig OR score = low then 1 else 0 end)=0