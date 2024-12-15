/* write a query to find personid,name,number of friends, sum of marks
of person who have friends with total score greater than 100*/

drop table if exists #friend 
Create table #friend (pid int, fid int)
insert into #friend (pid , fid ) values ('1','2');
insert into #friend (pid , fid ) values ('1','3');
insert into #friend (pid , fid ) values ('2','1');
insert into #friend (pid , fid ) values ('2','3');
insert into #friend (pid , fid ) values ('3','5');
insert into #friend (pid , fid ) values ('4','2');
insert into #friend (pid , fid ) values ('4','3');
insert into #friend (pid , fid ) values ('4','5');

drop table if exists #person
create table #person (PersonID int,	Name varchar(50),	Score int)
insert into #person(PersonID,Name ,Score) values('1','Alice','88')
insert into #person(PersonID,Name ,Score) values('2','Bob','11')
insert into #person(PersonID,Name ,Score) values('3','Devis','27')
insert into #person(PersonID,Name ,Score) values('4','Tara','45')
insert into #person(PersonID,Name ,Score) values('5','John','63')

select * from #person
select * from #friend

--
; with cte as (
Select f.pid,Sum(p.Score) as Friend_score, count(f.fid) as No_of_Friends
from #person p
inner join #friend f on f.fid = p.PersonID
group by pid having Sum(p.Score) > 100 )

Select a.*,b.Name from cte a
inner join #person b on a.pid= b.PersonID

-- Two Way Relationship

;with cte as (
select distinct id1, 
count(id2) over (partition by id1 order by id1) as no_of_friends,
sum(p.score) over (partition by id1 order by id1) as friend_score
from (
    select pid as id1, fid as id2 from #friend
    union 
    select fid as id1, pid as id2 from #friend)t
join #person p on t.id2 = p.PersonID)

select a.id1 as PersonId, b.name as Name, no_of_friends, friend_score as sum_of_marks
from cte a join #Person b on a.id1 = b.PersonID
where friend_score > 100

--

with score_cte as (
select #Person.PersonId,#Person.Name,#Friend.fid,#Person.Score 
from #Person join #Friend on #Person.PersonId = #Friend.pid
),
total_score_cte as (
select PersonId,score_cte.Name, 
SUM(score_cte.Score) over (partition by PersonId order by PersonId) as total_score ,
ROW_NUMBER() over (partition by PersonId order by PersonId) as rn ,
Count(fid) over (partition by PersonId order by PersonId) as total_friends
from score_cte
)
select PersonId,Name,total_friends,total_score from total_score_cte where total_score_cte.total_score > 100
and total_score_cte.rn = 1

--

;with cte as (
select N.Name , F.pid,F.fid , P.Name as FriendsName,P.Score,
Sum(P.Score) over (partition by N.Name) as TotalMark,
count(*) over (partition by N.Name) as NoFriends
from #friend  F 
left join #person P on F.fid = P.PersonID
left join #person N on F.pid = N.PersonID ) 
select distinct Name , TotalMark ,NoFriends from cte  where TotalMark > 100 order by Name

