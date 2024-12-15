


create table #sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into #sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);

select * from #sales 

--

; with r_cte as (
select min(period_start) as dates, 
max(period_end) as max_date from #sales
union all
select dateadd(day,1,dates) , max_date
from r_cte 
where dates < max_date )

select product_id,year(dates) as report_year,
sum(average_daily_sales) as total_amount
from r_cte
inner join #sales on dates between period_start and period_end
group by product_id, year(dates)
order by product_id,year(dates)
option (maxrecursion 1000);

--

;with recursive dt_cte as (
select period_start,period_end,product_id,average_daily_sales from #sales
union all
select dateadd(day,1,period_start),period_end,product_id,average_daily_sales
from dt_cte 
where period_start<period_end
)

select product_id,date_format(period_start,'%Y') as yr,sum(average_daily_sales) as tot_sale
from dt_cte group by date_format(period_start,'%Y'),product_id 
order by product_id,yr,tot_sale;







--

; with cte_numbers as (
select 1 as num -- anchor query

union all

select num+1  -- recursive query
from cte_numbers 
where num <6 )
select num from cte_numbers

/*
anchor : 1
num=1, 2
num=2,3
......
num=5,6 */