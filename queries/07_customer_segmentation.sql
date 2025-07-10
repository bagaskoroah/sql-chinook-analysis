-- Case 07: Customer Segmentation by Quartile
-- Objective: Categorize customers into tiers based on total spending using NTILE to enable personalized marketing strategies by customer tier (Silver, Gold, Platinum).
WITH quantile_placement AS (
	SELECT
		CONCAT(c.first_name, ' ', c.last_name) AS cust_name,
		SUM(i.total) as total_spend,
		NTILE(4) OVER (ORDER BY SUM(i.total)) AS quantile
	FROM customer c 
	JOIN invoice i on c.customer_id = i.customer_id
	GROUP BY 1)

SELECT
	cust_name,
	total_spend,
	CASE
		WHEN quantile = 1 THEN 'Silver'
		WHEN quantile = 2 OR quantile = 3 THEN 'Gold'
		ELSE 'Platinum'
	END AS cust_tier
FROM quantile_placement;