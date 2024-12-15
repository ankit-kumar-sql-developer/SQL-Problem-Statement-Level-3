
--for each region find house which has won maximum no of battles.display region,	house and no of wins

-- create the 'king' table
create table #king (
    k_no int primary key,
    king varchar(50),
    house varchar(50)
);

-- create the 'battle' table
create table #battle (
    battle_number int primary key,
    name varchar(100),
    attacker_king int,
    defender_king int,
    attacker_outcome int,
    region varchar(50),
    foreign key (attacker_king) references #king(k_no),
    foreign key (defender_king) references #king(k_no)
);

delete from #king;
insert into #king (k_no, king, house) values
(1, 'robb stark', 'house stark'),
(2, 'joffrey baratheon', 'house lannister'),
(3, 'stannis baratheon', 'house baratheon'),
(4, 'balon greyjoy', 'house greyjoy'),
(5, 'mace tyrell', 'house tyrell'),
(6, 'doran martell', 'house martell');

delete from #battle;
-- insert data into the 'battle' table
insert into #battle (battle_number, name, attacker_king, defender_king, attacker_outcome, region) values
(1, 'battle of oxcross', 1, 2, 1, 'the north'),
(2, 'battle of blackwater', 3, 4, 0, 'the north'),
(3, 'battle of the fords', 1, 5, 1, 'the reach'),
(4, 'battle of the green fork', 2, 6, 0, 'the reach'),
(5, 'battle of the ruby ford', 1, 3, 1, 'the riverlands'),
(6, 'battle of the golden tooth', 2, 1, 0, 'the north'),
(7, 'battle of riverrun', 3, 4, 1, 'the riverlands'),
(8, 'battle of riverrun', 1, 3, 0, 'the riverlands');

--for each region find house which has won maximum no of battles. display region, house and no of wins

select * from #battle;
select * from #king;


-- Method 1
; with wins as (
select attacker_king as King,region
from #battle  where attacker_outcome =1
union all
select defender_king,region
from #battle  where attacker_outcome =0 )
select * from (
select region,house,COUNT(*) as no_of_wins,
RANK() over (partition by w.region order by count(*) desc ) as rn
from wins w
inner join #king k on w.King=k.k_no
group by region,house) t
where rn=1

-- Method 2


select * from (
select region,house,COUNT(*) as no_of_wins,
RANK() over (partition by region order by count(*) desc ) as rn
from #battle b
inner join #king k on k.k_no = 
case when attacker_outcome=1 then attacker_king else defender_king end
group by region,house) t
where rn=1

--

select distinct region, house from
(select * , max(total_wins) over (partition by region) max_wins from
(select *, count(*) over (partition by region, house) as total_wins from
(select region,house from
(select name,region, case when attacker_outcome = 1 then attacker_king else defender_king end as winner 
from battle1)a
join
(select * from king1)b
on a.winner = b.k_no)p)u)q
where total_wins = max_wins;

--

with cte as
 (select * ,   
    case when attacker_outcome =1   
  then attacker_king    
  else defender_king    
  end as win_id from battle   order by region),  
  
 cte2 as(select battle_number, name,region,king,house,
         count(*) as temp from cte c 
         join king k   on win_id=k_no   
         group by region ,house)      
 select region,house,temp  from cte2

 --
