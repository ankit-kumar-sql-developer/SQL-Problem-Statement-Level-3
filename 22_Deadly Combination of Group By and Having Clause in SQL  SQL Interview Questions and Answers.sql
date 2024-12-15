
-- find students with same marks in phy chem
create table #exams (student_id int, subject varchar(20), marks int);
delete from #exams;
insert into #exams values (1,'Chemistry',91),(1,'Physics',91)
,(2,'Chemistry',80),(2,'Physics',90)
,(3,'Chemistry',80)
,(4,'Chemistry',71),(4,'Physics',54);

select * from #exams

--

select student_id
from #exams
where subject in ('Chemistry','Physics')
group  by student_id having COUNT(distinct subject)=2
and COUNT(distinct marks) =1

--
select student_id from (
select *,dense_rank() over (partition by student_id order by marks) as ran from #exams) tb 
group by student_id having count(distinct ran)=1 and count(ran)=2

--
;with cte as(
select student_id, sum(case when subject ='Chemistry' then marks end)c,
sum(case when subject='Physics' then marks end)p from #exams group by student_id)
select student_id from cte where c=p;

--
select distinct(e1.student_id)
from #exams e1 join #exams e2
on e1.student_id= e2.student_id
where e1.subject<> e2.subject and  e1.marks= e2.marks

--
with cte1 as
(select *, lag(marks) over(partition by student_id order by student_id) old_mrk from #exams)
select student_id from cte1 where marks=old_mrk 

--
SELECT	student_id
FROM	#exams
GROUP BY student_id
HAVING	SUM(IIF(subject = 'Chemistry',marks,0)) = SUM(IIF(subject = 'Physics',marks,0))

--
Select student_id
from #exams
group by student_id
having count(distinct subject)=2 and max(marks)=avg(marks);

--
Select distinct student_id from 
(Select student_id,marks,
lag(marks,1) over (partition by student_id order by subject) as prev_1,
lead(marks,1) over (partition by student_id order by subject) as next_1 
from #exams where subject in ('Chemistry','Physics') ) a
Where marks=prev_1 or marks=next_1;

--
; with cte as (
select student_id, sum(marks)/2 as half
from #exams
group by student_id 
having count(student_id) = 2
order by student_id )

select distinct c.student_id from cte c INNER JOIN #exams e ON c.student_id = e.student_id
where c.half = e.marks;

--

; with studentCTE as(
select 
*
,avg(marks) over(partition by student_id) as avg_flag
,marks - avg(marks) over(partition by student_id) as diff
from #exams)
select student_id from  studentCTE
group by student_id 
having max(diff)=0 and count(diff)=2

--
SELECT student_id
FROM #exams
WHERE SUBJECT IN ('Physics' , 'Chemistry')
GROUP BY student_id
HAVING count(distinct subject)=2 AND MAX(marks)-MIN(marks) = 0

--

with cte as(
select student_id,
(case when subject='Chemistry' then marks end) as 'Chemistry',
(case when subject='Physics' then marks end) as 'Physics'
from #exams)
select student_id, sum(Chemistry) as Chem, sum(Physics) as Phy
from cte 
group by student_id
having sum(Chemistry)=sum(Physics)

--

SELECT student_id, max(marks), sum(marks)
FROM #exams
GROUP BY student_id
HAVING max(marks) = sum(marks)/2;

--
;with cte as(
select * ,
DENSE_RANK() over(partition by subject order by marks desc) rnk
from #exams )

select student_id,subject
from cte where rnk =1 group by student_id,subject

--
;with abc as(
select student_id,
sum(case when subject='physics' then marks else 0 end) as physics_marks,
sum(case when subject='chemistry' then marks else 0 end) as chemistry_marks,
count(subject) as attmpted
from #exams group by student_id 
)
select student_id from abc where physics_marks=chemistry_marks  and attmpted=2

----2nd method

; with cte1 as(
select student_id,[physics],[chemistry] from #exams
pivot
(sum(marks) for subject in([physics],[chemistry] )
)
as pivottable
)
select student_id from cte1 where physics=chemistry  
-- in the second method  assuming that if student attempted exam for a subject 
-- he get marks>0 if not attempted he gets zero

--
select  e.student_id
from #exams e 
join #exams e2
on e.marks = e2.marks 
and e.subject = 'Chemistry' 
and e2.subject = 'Physics'