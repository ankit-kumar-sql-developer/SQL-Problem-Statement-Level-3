
create table #friends (
    user_id int,
    friend_id int
);

-- insert data into friends table
insert into #friends values
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(3, 1),
(3, 4),
(4, 1),
(4, 3);

-- create likes table
create table #likes (
    user_id int,
    page_id char(1)
);

-- insert data into likes table
insert into #likes values
(1, 'a'),
(1, 'b'),
(1, 'c'),
(2, 'a'),
(3, 'b'),
(3, 'c'),
(4, 'b');

select * from #friends
select * from #likes

-- Method 1
; with user_pages as (
select distinct f.user_id,l.page_id
from #friends f 
inner join #likes l on f.user_id= l.user_id )
,friends_pages as (
select distinct f.user_id,f.friend_id, l.page_id
from #friends f 
inner join #likes l on f.friend_id= l.user_id )

select fp.user_id,fp.page_id
from friends_pages fp
left join user_pages up on fp.user_id=up.user_id and fp.page_id= up.page_id
where up.user_id is null
order by fp.user_id


-- Method 2 
select *
from #friends f 
inner join #likes fp on f.friend_id= fp.user_id 
left  join #likes up on f.user_id=up.user_id and fp.page_id= up.page_id
where up.page_id is null

-- Method 3
Select --CONCAT(f.user_id,fp.page_id) as concat_col
f.user_id,fp.page_id
from  #friends f
inner join #likes fp on f.friend_id = fp.user_id
where CONCAT(f.user_id,fp.page_id) not in (
select distinct  CONCAT(f.user_id,fp.page_id) as concat_col
from #friends f
inner join  #likes fp on f.user_id= fp.user_id)
group by f.user_id,fp.page_id


--

; with cte as (
select f.user_id, l.page_id from #likes l
join #friends f on f.friend_id = l.user_id)
select user_id,page_id from cte except (select * from #likes)


--
with cte as
(
select distinct f.user_id, l.page_id from friends f
join likes l on f.friend_id = l.user_id
)

select user_id, page_id from cte
where (user_id, page_id) not in (select user_id, page_id from likes)

--
select f.user_id,l.page_id from #friends f
JOIN #likes l on f.friend_id = l.user_id
except
select user_id,page_id from #likes
order by user_id,page_id

--


