/*Write SQL to find all couples of trade for same stock that happened in the range of 10 
seconds and having price difference by more than 10 %.
Output result should also list the percentage of price difference between the 2 trade*/

drop table if exists #Trade_tbl
Create Table #Trade_tbl(
TRADE_ID varchar(20),
Trade_Timestamp time,
Trade_Stock varchar(20),
Quantity int,
Price Float
)

Insert into #Trade_tbl Values('TRADE1','10:01:05','ITJunction4All',100,20)
Insert into #Trade_tbl Values('TRADE2','10:01:06','ITJunction4All',20,15)
Insert into #Trade_tbl Values('TRADE3','10:01:08','ITJunction4All',150,30)
Insert into #Trade_tbl Values('TRADE4','10:01:09','ITJunction4All',300,32)
Insert into #Trade_tbl Values('TRADE5','10:10:00','ITJunction4All',-100,19)
Insert into #Trade_tbl Values('TRADE6','10:10:01','ITJunction4All',-300,19)


Insert into #Trade_tbl Values('TRADE1','10:10:00','IFS',-100,19)
Insert into #Trade_tbl Values('TRADE2','10:10:01','IFS',-300,19)
Insert into #Trade_tbl Values('TRADE3','10:10:05','IFS',100,20)
Insert into #Trade_tbl Values('TRADE4','10:10:06','IFS',20,15)
--
select * from #Trade_tbl

--

select t1.Trade_Stock,t1.TRADE_ID,t2.TRADE_ID,t1.Trade_Timestamp,t2.Trade_Timestamp,
t1.price,t2.price,
Abs(((t1.price-t2.Price)*1.0/t1.price)*100) as per,
DATEDIFF(second,t1.Trade_Timestamp,t2.Trade_Timestamp) as diff
from #Trade_tbl t1
inner join #Trade_tbl t2 on t1.Trade_Stock=t2.Trade_Stock --and t1.TRADE_ID <> t2.TRADE_ID 
where  DATEDIFF(second,t1.Trade_Timestamp,t2.Trade_Timestamp) < 10
and t1.Trade_Timestamp < t2.Trade_Timestamp 
and Abs(((t1.price-t2.Price)*1.0/t1.price)*100) >10
order by t1.TRADE_ID


--

with cte as (
SELECT a.Trade_id as first_trade, b.trade_id as second_trade , TIMESTAMPDIFF( second, (a.trade_timestamp) ,(b.trade_timestamp))  as time_diff
,round((abs(a.price - b.price)/a.price) *100,0) as price_per 
FROM trade_tbl AS a
CROSS JOIN trade_tbl AS b
where a.Trade_Timestamp < b.trade_timestamp 
order by a.trade_id, b.trade_id
)

select * from cte
where price_per > 10 and time_diff < 10