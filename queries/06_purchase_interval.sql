-- Case 06: Purchase Interval per Customer
-- Objective: Calculate the time gaps between a customer's purchases using window functions to measure purchase frequency to inform customer retention strategy.
WITH time_transaction AS (
SELECT
	CONCAT(c.first_name, ' ', c.last_name) AS cust_name,
	i.invoice_date,
	LAG(i.invoice_date, 1) OVER (PARTITION BY CONCAT(c.first_name, ' ', c.last_name) ORDER BY i.invoice_date) AS next_buy_date,
	i.invoice_date - LAG(i.invoice_date, 1) OVER (PARTITION BY CONCAT(c.first_name, ' ', c.last_name) ORDER BY i.invoice_date) AS buy_day_interval
FROM customer c 
JOIN invoice i on c.customer_id = i.customer_id)

SELECT 
	cust_name,
	MIN(buy_day_interval) AS minimum_buy_interval,
	MAX(buy_day_interval) AS maximum_buy_interval
FROM time_transaction
GROUP BY 1
ORDER BY 1;