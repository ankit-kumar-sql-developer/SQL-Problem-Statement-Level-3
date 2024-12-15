-- Datalemuer Question --
/*Say you have access to all the transactions for a given merchant account. Write
a query to print the cumulative balance of the merchant account at the end of
each day, with the total balance reset back to zero at the end of the month.
Output the transaction date and cumulative balance.*/
-- Create the transactions table
CREATE TABLE #transactions (
    transaction_id INT PRIMARY KEY,
    type VARCHAR(10) CHECK (type IN ('deposit', 'withdrawal')),
    amount DECIMAL(10, 2),
    transaction_date DATETIME
);
delete from #transactions
-- Insert the example data
INSERT INTO #transactions (transaction_id, type, amount, transaction_date) VALUES
(28765, 'deposit', 150.25, '2022-07-11 11:30:00'),
(37521, 'withdrawal', 75.00, '2022-07-11 12:00:00'),
(43718, 'deposit', 200.00, '2022-07-12 09:15:00'),
(56478, 'withdrawal', 100.50, '2022-07-13 15:45:00'),
(65341, 'deposit', 50.75, '2022-07-13 16:30:00'),
(91245, 'withdrawal', 30.00, '2022-07-14 10:00:00'),
(82315, 'deposit', 125.00, '2022-07-14 14:00:00'),
(64512, 'withdrawal', 85.20, '2022-07-15 08:30:00'),
(75621, 'deposit', 220.00, '2022-07-15 10:00:00'),
(32458, 'withdrawal', 40.25, '2022-07-16 11:00:00'),
(87654, 'deposit', 90.50, '2022-07-16 13:45:00'),
(23147, 'withdrawal', 120.00, '2022-07-17 09:30:00'),
(43528, 'deposit', 75.30, '2022-07-17 14:15:00'),
(91452, 'withdrawal', 95.00, '2022-07-18 15:00:00'),
(13562, 'deposit', 65.00, '2022-07-18 16:45:00'),
(25814, 'withdrawal', 55.50, '2022-07-19 10:30:00'),
(76253, 'deposit', 130.75, '2022-07-19 12:15:00'),
(49125, 'withdrawal', 45.00, '2022-07-20 08:45:00'),
(34621, 'deposit', 180.20, '2022-07-20 10:15:00'),
(51963, 'withdrawal', 60.90, '2023-07-21 11:30:00'),
(72538, 'deposit', 210.00, '2023-07-21 13:00:00'),
(13257, 'withdrawal', 75.25, '2023-07-22 09:45:00'),
(25413, 'deposit', 105.00, '2023-07-22 15:30:00'),
(63751, 'withdrawal', 50.00, '2023-07-23 10:00:00'),
(87123, 'deposit', 300.00, '2023-07-23 12:45:00'),
(45672, 'withdrawal', 110.10, '2023-07-24 14:00:00'),
(67832, 'deposit', 140.00, '2023-07-25 10:30:00'),
(25914, 'withdrawal', 40.50, '2023-07-25 16:15:00'),
(48271, 'deposit', 200.50, '2023-07-26 09:15:00'),
(39516, 'withdrawal', 85.75, '2023-07-26 11:30:00'),
(51921, 'withdrawal', 160.90, '2023-08-21 11:30:00'),
(72521, 'deposit', 210.00, '2023-08-21 13:00:00'),
(13221, 'withdrawal', 187.25, '2023-08-22 09:45:00'),
(25421, 'deposit', 105.00, '2023-08-22 15:30:00'),
(63721, 'withdrawal', 150.00, '2023-08-23 10:00:00'),
(87121, 'deposit', 400.00, '2023-08-23 12:45:00'),
(45621, 'withdrawal', 110.10, '2023-08-24 14:00:00'),
(67821, 'deposit', 140.00, '2023-08-25 10:30:00'),
(25921, 'withdrawal', 140.50, '2023-08-25 16:15:00'),
(48221, 'deposit', 300.50, '2023-08-26 09:15:00'),
(39521, 'withdrawal', 185.75, '2023-08-26 11:30:00');
select * from #transactions
--
; with cte as (
select cast(transaction_date as date) as transaction_date1,
sum(case when type='withdrawal' then -1*amount else amount end) as amount
from #transactions
group by cast(transaction_date as date)
 )

select transaction_date1,amount,
SUM(amount) over (partition by datepart(year,transaction_date1),
datepart(month,transaction_date1)
order by transaction_date1) as cum_sum
from cte order by transaction_date1
