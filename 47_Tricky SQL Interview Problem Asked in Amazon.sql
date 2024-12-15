
--Write a sql query to find users who purchased different products	on different dates
--ie products purchased on any given day are not repeated on any	other day

create table #purchase_history
(userid int
,productid int
,purchasedate date
);
SET DATEFORMAT dmy;
insert into #purchase_history values
(1,1,'23-01-2012')
,(1,2,'23-01-2012')
,(1,3,'25-01-2012')
,(2,1,'23-01-2012')
,(2,2,'23-01-2012')
,(2,2,'25-01-2012')
,(2,4,'25-01-2012')
,(3,4,'23-01-2012')
,(3,1,'23-01-2012')
,(4,1,'23-01-2012')
,(4,2,'25-01-2012')

select * from #purchase_history

-- M1
; with cte as (
select userid, COUNT(distinct purchasedate) no_of_dates,
COUNT(productid) cnt_product, COUNT(distinct productid) count_dist_product
from #purchase_history group by userid ) 

select * from cte where no_of_dates > 1 and cnt_product= count_dist_product

-- M2

select userid
from #purchase_history group by userid 
having COUNT(distinct purchasedate) > 1 and COUNT(distinct productid)= COUNT(productid)


-- if same product is bought more than once on the same day. 
 
; WITH cte_1 AS
(
SELECT			*, LAG(productid) OVER(PARTITION BY userid ORDER BY productid) AS prev_product,
				LAG(purchasedate) OVER(PARTITION BY userid ORDER BY productid) AS prev_date
FROM			#purchase_history
)
SELECT			userid
FROM			cte_1 c1
GROUP BY		userid
HAVING			SUM(IIF(productid = prev_product AND purchasedate <> prev_date, 1,0)) = 0 AND COUNT(DISTINCT purchasedate) > 1

--
with purchase_history_compared AS (
    -- join each row with a different transaction 
    -- which is not on samedate and is done by same user
    -- It will also filter out userid who don't have 2 purchases
    SELECT a.userid, a.productid, b.productid as next_productid
    FROM practice.purchase_history a
    JOIN practice.purchase_history b
    ON a.userid = b.userid and a.purchasedate != b.purchasedate
)
, repeat_flag_table AS(
    -- mark those transaction as repeated where the product matches
    SELECT 
        userid,
        CASE WHEN  next_productid = productid THEN 0
        ELSE 1
        END as repeat_flag
    FROM purchase_history_compared  
)
SELECT 
-- Filter those users who have all non repeated transactions
    userid
FROM repeat_flag_table
GROUP BY userid
HAVING SUM(repeat_flag) = COUNT(1)

--
select a.userid
from purchase_history a
inner join purchase_history b
on a.userid = b.userid and a.purchasedate > b.purchasedate
group by a.userid
having count(distinct case when a.productid = b.productid then 1 else 0 end)=1 and max(case when a.productid = b.productid then 1 else 0 end)=0
--
;WITH all_data AS(
SELECT *,DENSE_RANK()OVER(PARTITION BY userid,productid ORDER BY purchasedate ASC) AS rn
FROM purchase_history)
SELECT userid
FROM all_data
GROUP BY userid
HAVING max(rn)=1 AND count(distinct purchasedate)>1

--
with cte as(
select *,row_number() over(partition by userid,productid order by purchasedate) as rn
FROM purchase_history)
select userid
from cte
group by userid
having max(rn)=1 and count(distinct purchasedate)>1

--
with cte1 as ---This cte returns, users who bought same product more than once
(
select userid,productid,  count(1) as tot 
from purchase_history
group by userid, productid
having count(1) > 1

)

select distinct userid
from purchase_history
where userid not in (select userid from cte1)  --Filtering users who bought same product more than once

and userid not in ( select userid              ----Filtering users who dont buy on different dates
				from  purchase_history
				group by userid
				having count(distinct purchasedate) = 1 )


--
with cte as(
select *,count(1) over(partition by userid,productid) as cnt from purchase_history),
cte2 as(
select * from cte where userid not in (select userid from cte where cnt>1))
select userid from cte2 group by userid having count(distinct purchasedate)>1;

--
;with cte as (
select p1.userid  from purchase_history p1
inner join purchase_history p2 on p1.userid=p2.userid and p1.purchasedate!=p2.purchasedate
and p1.productid=p2.productid)
select MAX(userid) as userid
from purchase_history where userid not in (select * from cte )
group by userid
having count(distinct purchasedate)>1
--
with ctee as(
select userid
from purchase_history
group by userid
having count(distinct purchasedate)=1),
cte as(
select userid, count(productid) as cnt from purchase_history
group by userid, productid
having count(productid)>1
)
select distinct userid from purchase_history where userid not in
(select userid from cte
union
select userid from ctee)


--
with cte as(
Select *,
row_number() over(partition by userid, productid order by userid) as rn,
lead(purchasedate,1) over(partition by userid) as ld,
Case when purchasedate != lead(purchasedate,1) over(partition by userid) then 1 end as fp
from purchase_history)

Select userid from cte
where userid not in (Select userid from cte where rn>1) 
group by userid



--

with cte_samepdoduct as 
	(
		/* Using denserank, we can get those same products which 
		have been bought on different dates, so that we can
		filter it out later */

		select *,DENSE_RANK() over(partition by userid,productid order by productid,purchasedate) as drn
		from purchase_history
)
, cte_purchasecount as (
		/* In this cte, we are counting distinct purchase
		date so that we can filter those userid later */

		select userid,count(distinct Purchasedate) as days_cnt
		from purchase_history
		group by userid
	)
Select userid from cte_purchasecount 
where days_cnt > 1 and 
userid not in ( select userid from cte_samepdoduct where drn>1 )
