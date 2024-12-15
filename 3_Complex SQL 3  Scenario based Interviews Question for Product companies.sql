
drop table if exists #entries
create table #entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into #entries values 
('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),
('A','Bangalore','A2@gmail.com',2,'DESKTOP'),('B','Bangalore','B@gmail.com',2,'DESKTOP'),
('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')

select * from #entries

--
; with resources_all as (
select distinct name, resources from #entries )
,agg_resouces as( 
select name, string_agg( resources,',') as used_resources from  resources_all group by name)
,total_visits as (
select name,count(1) as total_visit, string_agg(resources,',') as resources_used
from #entries group by name )
,most_visited_floor as (
Select name,floor, count(1) AS cnt,
row_number() over (partition by name order by count(1) desc) as rn
from #entries group by name,floor )

select b.name, b.floor as most_visited_floor,
a.total_visit,c.used_resources
from total_visits a
inner join  most_visited_floor b on a.name= b.name
inner join agg_resouces c on b.name= c.name
where rn=1

