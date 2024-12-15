/*-- Write an SQL query to find the winner in each group.
-- The winner in each group is the player who scored the maximum total points within the group. In the case of a tie,
-- the lowest player_id wins */

create table #players
(player_id int,
group_id int)

insert into #players values (15,1);
insert into #players values (25,1);
insert into #players values (30,1);
insert into #players values (45,1);
insert into #players values (10,2);
insert into #players values (35,2);
insert into #players values (50,2);
insert into #players values (20,3);
insert into #players values (40,3);

create table #matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)

insert into #matches values (1,15,45,3,0);
insert into #matches values (2,30,25,1,2);
insert into #matches values (3,30,15,2,0);
insert into #matches values (4,40,20,5,2);
insert into #matches values (5,35,50,1,1);

select * from #matches
select * from #players

--
; with cte as (
select first_player,sum(sc) as sc from(
select first_player, sum(first_score) as sc from #matches
group by first_player
union all
select second_player, sum(second_score) as sc from #matches
group by second_player ) t  group by first_player )
, cte2 as (
select a.*,p.group_id,
rank() over (partition by group_id order by sc desc, first_player)  as rn
from cte a
inner join #players p on a.first_player= p.player_id )
select * from cte2 where rn =1

--

with cte as (
Select player_id,group_id,total_score,
dense_rank() over (partition by group_id order by total_score desc,player_id) as rn
from (
Select p.*,(coalesce(m.first_score,0)+coalesce(m1.second_score,0)) as total_score
from #Players p
left join #matches m on p.player_id = m.first_player
left join #matches m1 on p.player_id = m1.second_player) t
group by player_id,group_id,total_score)

Select * from cte where rn = 1 

--

;with cte as (
select d.*, rank() over(partition by d.group_id order by tot_score desc) as rnk
from (
select p.group_id, p.player_id,
sum(coalesce(fp.first_score, 0) + coalesce(sp.second_score, 0)) as tot_score
from #players p
left join #matches fp on p.player_id = fp.first_player
left join #matches sp on p.player_id = sp.second_player
group by p.group_id, p.player_id --order by group_id, player_id
)d)
select c1.group_id, c1.player_id
from cte c1
where rnk = 1
and player_id = (select min(player_id) from cte c2 where c1.group_id = c2.group_id and c2.rnk = 1)

--
select p.group_id,p.player_id,
sum(isnull(m1.first_score,0) + isnull(m2.second_score,0)) as TotalScore
from #players as p
left join #matches as m1 on m1.first_player=p.player_id
left join #matches as m2 on m2.second_player=p.player_id
group by p.player_id,p.group_id

--

;with t1 as (
select  case when first_score>=second_score then first_player else second_player end as player,
        case when first_score>=second_score then first_score else second_score end as score
from #matches)

select group_id,player_id,max(score) as score from t1 join #players on t1.player=#players.player_id 
group by group_id order by group_id

--

select * from (
select player_id,group_id,
rank()over(partition by group_id order by score desc,player_id asc) as rnk
from(
select player_id,group_id,
sum(case when f.first_score is not null then f.first_score else s.second_score end) as score
from #players p 
left outer join #matches f on (p.player_id = f.first_player)
left outer join #matches s on (p.player_id = s.second_player)
group by player_id,group_id)a)b
where rnk=1;


--

select group_id,min(player_id) player_id from (
select bb.*, p.group_id, max(total_player_score) over (partition by group_id) score_max_group
from (
select player_id, sum(player_score) total_player_score from (
select first_player player_id, first_score player_score
from #matches
union all
select second_player player_id, second_score player_score
from #matches
) aa
group by player_id ) bb
join #players p on p.player_id = bb.player_id
 )cc
where total_player_score=score_max_group
group by group_id