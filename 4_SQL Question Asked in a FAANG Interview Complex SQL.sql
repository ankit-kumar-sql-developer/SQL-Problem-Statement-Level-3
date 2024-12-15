
-- write a query to provide data for nth occurence of sunday in future date

declare @today_date date ;
declare @n int;

set @today_date = '2022-01-01' ; -- saturday
set @n= 3;

select dateadd(week,@n-1,
dateadd(day,8-datepart(weekday,@today_date),@today_date))

-- The below snippet would give results for n = 0 as well: -
declare @today_date date = getdate();
declare @n int = 0;
declare @dayofweek int = datepart(WEEKDAY, @today_date);
declare @daystillsunday int = case when @dayofweek = 1 then 0 else 9 - @dayofweek end;
select dateadd(day, 7*@n + @daystillsunday, @today_date) as NewDate;

--

