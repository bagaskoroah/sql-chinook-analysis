-- Case 05: High-Value Customers Based on Total Spend
-- Objective: Use CTE and subquery to filter customers whose total spend exceeds the overall average to highlight high-value segments for potential retargeting or rewards.
with spend as (
	SELECT
		CONCAT(c.first_name, ' ', c.last_name) AS cust_name,
		SUM(i.total) as total_spend
	FROM customer c 
	JOIN invoice i on c.customer_id = i.customer_id
	GROUP BY 1
),
avg_spend AS (
	SELECT AVG(total_spend) AS avg_spend
	FROM spend
)
SELECT
	s.cust_name,
	s.total_spend
FROM spend s, avg_spend asp
WHERE s.total_spend > asp.avg_spend
ORDER BY 2 DESC;