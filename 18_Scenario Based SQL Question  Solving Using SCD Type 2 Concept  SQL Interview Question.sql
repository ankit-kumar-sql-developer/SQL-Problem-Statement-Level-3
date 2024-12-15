-- total charges as per billing rate
create table #billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from #billings;
insert into #billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;

create table #HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into #HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)

select * from #billings
select * from #HoursWorked

--
; with cte as (
select *,
LEAD(Dateadd(day,-1,bill_date),1,'9999-12-31') over (partition by emp_name order by bill_date asc) as bill_date_end
from #billings )
select hw.emp_name,sum(dr.bill_rate*hw.bill_hrs)
from cte dr
inner join #HoursWorked hw on dr.emp_name= hw.emp_name
and hw.work_date between dr.bill_date and dr.bill_date_end
group  by hw.emp_name

--
;WITH CTE AS(
SELECT #HoursWorked.emp_name, work_date, bill_hrs, bill_date, bill_rate 
FROM #HoursWorked
LEFT JOIN #billings ON #HoursWorked.emp_name=#billings.emp_name 
AND #HoursWorked.work_date>=#billings.bill_date)

,CTE2 AS(
SELECT *,
RANK() OVER(PARTITION BY emp_name, work_date ORDER BY bill_date DESC) AS R
FROM CTE )

SELECT emp_name,SUM(bill_hrs*bill_rate) FROM CTE2 
WHERE R=1
GROUP BY emp_name