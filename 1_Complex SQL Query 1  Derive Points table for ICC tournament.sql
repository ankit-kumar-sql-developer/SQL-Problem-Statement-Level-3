
drop table if exists #icc_world_cup
create table #icc_world_cup
(
team_1 varchar(20),
team_2 varchar(20),
winner varchar(20)
);
insert into #icc_world_cup values('india','sl','india');
insert into #icc_world_cup values('sl','aus','aus');
insert into #icc_world_cup values('sa','eng','eng');
insert into #icc_world_cup values('eng','nz','nz');
insert into #icc_world_cup values('aus','india','india');

select * from #icc_world_cup;

select team, sum(win_flag) as no_win_match, count(1) as no_of_matches,
count(1)-sum(win_flag) as loss
from (
select team_1 as team,
case when team_1= winner then 1 else 0 end as win_flag
from #icc_world_cup
union all
select team_2,
case when team_2= winner then 1 else 0 end as win_flag
from #icc_world_cup ) a group by team

--Using full outer join

select
coalesce(a.team_1,b.team_2) as Team_name,
count(a.team_1) over (partition by a.team_1) + count(b.team_2) over (partition by b.team_2) as Matches_played,
sum(case when a.team_1 = a.winner then 1 else 0 end) over (partition by a.team_1)
+ sum(case when b.team_2 = b.winner then 1 else 0 end) over (partition by b.team_2)
as no_of_wins,
sum(case when a.team_1 != a.winner then 1 else 0 end) over (partition by a.team_1)
+ sum(case when b.team_2 != b.winner then 1 else 0 end) over (partition by b.team_2)
as no_of_losses
from #icc_world_cup a full outer join #icc_world_cup b on a.team_1=b.team_2
order by no_of_wins desc

--
Select Team_1, tot_count , coalesce(win_cnt,0) win , tot_count-coalesce(win_cnt,0) loss_cnt
from(
Select Team_1 , count(1) tot_count from (
Select Team_1 from #icc_world_cup
union all
Select Team_2 from #icc_world_cup
) x group by Team_1
) main 
left join
(Select winner, count(1) win_cnt from #icc_world_cup group by winner) win
on main.Team_1= win.winner

--

