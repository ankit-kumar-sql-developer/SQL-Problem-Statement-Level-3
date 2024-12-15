
/*Find the number of users that made additional in-app purchases due to the success of the marketing campaign.
The marketing campaign doesn't start until one day after the initial in-app purchase so users that only
made one or multiple purchases on the first day do not count, nor do we count users that over time purchase
only the products they purchased on the first day. */

create table #marketing_campaign(
 [user_id] [int] null,
 [created_at] [date] null,
 [product_id] [int] null,
 [quantity] [int] null,
 [price] [int] null
);
insert into #marketing_campaign values (10,'2019-01-01',101,3,55),
(10,'2019-01-02',119,5,29),
(10,'2019-03-31',111,2,149),
(11,'2019-01-02',105,3,234),
(11,'2019-03-31',120,3,99),
(12,'2019-01-02',112,2,200),
(12,'2019-03-31',110,2,299),
(13,'2019-01-05',113,1,67),
(13,'2019-03-31',118,3,35),
(14,'2019-01-06',109,5,199),
(14,'2019-01-06',107,2,27),
(14,'2019-03-31',112,3,200),
(15,'2019-01-08',105,4,234),
(15,'2019-01-09',110,4,299),
(15,'2019-03-31',116,2,499),
(16,'2019-01-10',113,2,67),
(16,'2019-03-31',107,4,27),
(17,'2019-01-11',116,2,499),
(17,'2019-03-31',104,1,154),
(18,'2019-01-12',114,2,248),
(18,'2019-01-12',113,4,67),
(19,'2019-01-12',114,3,248),
(20,'2019-01-15',117,2,999),
(21,'2019-01-16',105,3,234),
(21,'2019-01-17',114,4,248),
(22,'2019-01-18',113,3,67),
(22,'2019-01-19',118,4,35),
(23,'2019-01-20',119,3,29),
(24,'2019-01-21',114,2,248),
(25,'2019-01-22',114,2,248),
(25,'2019-01-22',115,2,72),
(25,'2019-01-24',114,5,248),
(25,'2019-01-27',115,1,72),
(26,'2019-01-25',115,1,72),
(27,'2019-01-26',104,3,154),
(28,'2019-01-27',101,4,55),
(29,'2019-01-27',111,3,149),
(30,'2019-01-29',111,1,149),
(31,'2019-01-30',104,3,154),
(32,'2019-01-31',117,1,999),
(33,'2019-01-31',117,2,999),
(34,'2019-01-31',110,3,299),
(35,'2019-02-03',117,2,999),
(36,'2019-02-04',102,4,82),
(37,'2019-02-05',102,2,82),
(38,'2019-02-06',113,2,67),
(39,'2019-02-07',120,5,99),
(40,'2019-02-08',115,2,72),
(41,'2019-02-08',114,1,248),
(42,'2019-02-10',105,5,234),
(43,'2019-02-11',102,1,82),
(43,'2019-03-05',104,3,154),
(44,'2019-02-12',105,3,234),
(44,'2019-03-05',102,4,82),
(45,'2019-02-13',119,5,29),
(45,'2019-03-05',105,3,234),
(46,'2019-02-14',102,4,82),
(46,'2019-02-14',102,5,29),
(46,'2019-03-09',102,2,35),
(46,'2019-03-10',103,1,199),
(46,'2019-03-11',103,1,199),
(47,'2019-02-14',110,2,299),
(47,'2019-03-11',105,5,234),
(48,'2019-02-14',115,4,72),
(48,'2019-03-12',105,3,234),
(49,'2019-02-18',106,2,123),
(49,'2019-02-18',114,1,248),
(49,'2019-02-18',112,4,200),
(49,'2019-02-18',116,1,499),
(50,'2019-02-20',118,4,35),
(50,'2019-02-21',118,4,29),
(50,'2019-03-13',118,5,299),
(50,'2019-03-14',118,2,199),
(51,'2019-02-21',120,2,99),
(51,'2019-03-13',108,4,120),
(52,'2019-02-23',117,2,999),
(52,'2019-03-18',112,5,200),
(53,'2019-02-24',120,4,99),
(53,'2019-03-19',105,5,234),
(54,'2019-02-25',119,4,29),
(54,'2019-03-20',110,1,299),
(55,'2019-02-26',117,2,999),
(55,'2019-03-20',117,5,999),
(56,'2019-02-27',115,2,72),
(56,'2019-03-20',116,2,499),
(57,'2019-02-28',105,4,234),
(57,'2019-02-28',106,1,123),
(57,'2019-03-20',108,1,120),
(57,'2019-03-20',103,1,79),
(58,'2019-02-28',104,1,154),
(58,'2019-03-01',101,3,55),
(58,'2019-03-02',119,2,29),
(58,'2019-03-25',102,2,82),
(59,'2019-03-04',117,4,999),
(60,'2019-03-05',114,3,248),
(61,'2019-03-26',120,2,99),
(62,'2019-03-27',106,1,123),
(63,'2019-03-27',120,5,99),
(64,'2019-03-27',105,3,234),
(65,'2019-03-27',103,4,79),
(66,'2019-03-31',107,2,27),
(67,'2019-03-31',102,5,82)

select * from #marketing_campaign

--
; with rnk_data as (
select *,
RANK() over (partition by user_id order by created_at asc ) as rn 
from #marketing_campaign --where user_id in (11,14,25) 
)
, first_app_purchases as (
select * from rnk_data where rn=1)
, except_first_app_purchases as (
select * from rnk_data where rn>1)

select distinct efa.user_id --,efa.product_id,efa.created_at,
--fa.user_id,fa.product_id,fa.created_at
from  except_first_app_purchases efa
left join  first_app_purchases fa on efa.user_id=fa.user_id 
and efa.product_id= fa.product_id
where fa.product_id is null


-- nice  
;with cte as(
select dense_rank()over(partition by user_id order by created_at) rnk,* 
from #marketing_campaign
)
--select * from cte order by user_id,created_at
select distinct user_id from cte a  where rnk>1
and not exists (select 1 from cte b where rnk=1 and a.user_id=b.user_id and a.product_id=b.product_id)
order by user_id

--
;
WITH cte AS
(
SELECT			*, DENSE_RANK() OVER(PARTITION BY user_id ORDER BY created_at) AS day_position
FROM			#marketing_campaign
)
SELECT			user_id
FROM			cte
GROUP BY		user_id
HAVING			COUNT(DISTINCT product_id) <> COUNT(DISTINCT iIF(day_position = 1, product_id, NULL)) AND COUNT(DISTINCT created_at) > 1

--
WITH cte1 AS 
			(SELECT *, 
				       DENSE_RANK() OVER(PARTITION BY user_id ORDER BY created_at ASC) AS user_rnk,
				       DENSE_RANK() OVER(PARTITION BY user_id, product_id ORDER BY created_at ASC) AS product_rnk
			 FROM marketing_campaign
                         ORDER BY user_id, created_at)
SELECT COUNT(DISTINCT user_id) AS total_users
FROM cte1
WHERE user_rnk > 1 AND product_rnk = 1;



--
with cte as (select * , 
dense_rank() over(partition by user_id order by created_at) cr_rn,
row_number() over(partition by user_id,product_id order by created_at) pr_rn
from #marketing_campaign)

select user_id from cte
group by user_id
having sum(case when cr_rn>1 and pr_rn=1 then 1 else 0 end)>0
--

--
with cte as
(
select *, lag(created_at) over (partition by user_id order by created_at) as ca ,
lag(product_id) over (partition by user_id order by created_at) as pi  from [dbo].[marketing_campaign]
)
select user_id from cte
where ca<>created_at and pi<>product_id



--
WITH initial_purchases AS (
    SELECT user_id, product_id
    FROM marketing_campaign 
    WHERE (user_id, created_at) IN (
        SELECT user_id, MIN(created_at) 
        FROM marketing_campaign 
        GROUP BY user_id
    )
)
SELECT user_id, MIN(created_at) AS nxt 
FROM marketing_campaign 
WHERE (user_id, created_at) NOT IN (
        SELECT user_id, MIN(created_at) 
        FROM marketing_campaign 
        GROUP BY user_id
    )
    AND (user_id, product_id) NOT IN (SELECT user_id, product_id FROM initial_purchases)
GROUP BY user_id 
ORDER BY user_id;


--

with firstProduct as(
select user_id,created_at,product_id,
    first_value(product_id) over(partition by user_id order by created_at) f_prod
    from #marketing_campaign
    )
select user_id
    from firstProduct 
    group by user_id having count(distinct created_at)>1
    and count(user_id) = count(iif(f_prod!=product_id,1,null))+1




-- Wrong
select  distinct user_id
from #marketing_campaign
group by user_id
having count(distinct created_at)>1 and count(product_id)=count(distinct product_id)


--

with cte1 as (select user_id, created_at,
              case when 
              (FIRST_VALUE(created_at) over (partition by user_id order by user_id)) = created_at then 'Y' else 'N' end as is_first_day
              ,product_id
              from #marketing_campaign
              ),
cte2 as (select * from cte1
		 where is_first_day = 'Y'),
cte3 as (select * from cte1
		 where is_first_day = 'N'),
cte4 as (select ft.user_id, ft.created_at, nt.product_id
         from cte2 ft
         join cte3 nt
         on ft.user_id = nt.user_id and nt.product_id = ft.product_id),    -- narrowing users who have purchased first day items next time
cte5 as (select ft.user_id, ft.created_at, nt.product_id				   
         from cte2 ft													   
         join cte3 nt													   
         on ft.user_id = nt.user_id and nt.product_id <> ft.product_id),   -- narrowing users who have purchased new items compared to first time
cte6 as (select distinct ft.user_id										   
         from cte4 ft													   
         join cte5 nt													   
         on ft.user_id = nt.user_id and ft.product_id = nt.product_id)     --eliminating the repeat in different purchase basket (cte5 duplicates)
select distinct USER_ID from cte5
where user_id not in (select * from cte6)