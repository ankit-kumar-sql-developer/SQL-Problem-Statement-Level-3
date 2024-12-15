

create table #job_positions (
id  int,
title varchar(100),
groups varchar(10),
levels varchar(10),     
payscale int, 
totalpost int );
insert into #job_positions values (1, 'General manager', 'A', 'l-15', 10000, 1); 
insert into #job_positions values (2, 'Manager', 'B', 'l-14', 9000, 5); 
insert into #job_positions values (3, 'Asst. Manager', 'C', 'l-13', 8000, 10);  

create table #job_employees ( id  int, name   varchar(100),     position_id  int  );  
insert into #job_employees values (1, 'John Smith', 1); 
insert into #job_employees values (2, 'Jane Doe', 2);
insert into #job_employees values (3, 'Michael Brown', 2);
insert into #job_employees values (4, 'Emily Johnson', 2); 
insert into #job_employees values (5, 'William Lee', 3); 
insert into #job_employees values (6, 'Jessica Clark', 3); 
insert into #job_employees values (7, 'Christopher Harris', 3);
insert into #job_employees values (8, 'Olivia Wilson', 3);
insert into #job_employees values (9, 'Daniel Martinez', 3);
insert into #job_employees values (10, 'Sophia Miller', 3)


--

select * from #job_employees
select * from #job_positions

-- Method 1 R_cte
; with cte as (
select id,title,groups,levels,payscale,totalpost, 1 as rn 
from #job_positions 

union all
select id,title,groups,levels,payscale,totalpost, rn+1  from cte
where rn+1 <= totalpost)
, emp as (
select *, ROW_NUMBER() over (partition by position_id order by id) as rn
from #job_employees )

select cte.*, coalesce(emp.name,'vacant') from cte 
left join emp on cte.id=emp.position_id and cte.rn= emp.rn
order by cte.id,cte.rn

-- Method 2

; with t1 as (
select row_id as rn from Master_orders where row_id <=(select MAX(totalpost) from #job_positions) )
, cte as (
select * 
from #job_positions  a
left join t1
on t1.rn <=a.totalpost )
, emp as (
select *, ROW_NUMBER() over (partition by position_id order by id) as rn
from #job_employees )

select cte.*, coalesce(emp.name,'vacant') from cte 
left join emp on cte.id=emp.position_id and cte.rn= emp.rn
order by cte.id,cte.rn
 
 --

 declare @itr1 int
set @itr1 = 1;
declare @itr2 int
set @itr2 = 1;
declare @t_r table (id int, title varchar(100), groups varchar(10), levels varchar(10));
declare @id int
set @id = 1;

while @itr1 <= (select COUNT(*) from #job_positions)
	begin			
		while @itr2 <= (select totalpost from #job_positions where id = @id)			
			begin
				insert into @t_r
				select id, title, groups, levels from #job_positions
				where id = @id

				set @itr2 = @itr2 + 1;
	              end
		set @id = @id + 1;
		set @itr2 = 1
		set @itr1 = @itr1 + 1;
	end

select t.title, isnull(s1.name, 'VACANT POSITION') [name], t.levels
from (select ROW_NUMBER() over(partition by groups order by (select 1)) [rn], *
		from @t_r) t
left join (select ROW_NUMBER() over(partition by position_id order by (select 1)) [rn], *
			from #job_employees) s1
on t.id = s1.position_id and t.[rn] = s1.rn