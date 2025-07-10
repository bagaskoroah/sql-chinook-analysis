-- Case 01: List Customer Names and Countries
-- Objective: Retrieve all customers along with their respective country of origin to understand customer geographic distribution for regional marketing strategies.
SELECT
	CONCAT(first_name, ' ', last_name) AS customer_name,
	country AS customer_country
FROM customer
ORDER BY 1;

-- Case 02: Total Spending per Customer
-- Objective: Calculate the total amount each customer has spent in the store to identify top spending customers and evaluate customer lifetime value (LTV).
SELECT
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	SUM(i.total) AS total_expenses
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 2 DESC;

-- Case 03: Songs Priced Above Genre Average
-- Objective: Identify tracks that are priced higher than the average price of their genre to spot premium-priced content for pricing strategy evaluation.
SELECT
	song_name,
	genre_name,
	unit_price
FROM (
	SELECT
		t.name AS song_name,
		g.name AS genre_name,
		t.unit_price,
		ROUND(AVG(t.unit_price) OVER (PARTITION BY g.name),2) AS avg_genre_price
	FROM track t
	JOIN genre g ON t.genre_id = g.genre_id)
WHERE unit_price > avg_genre_price;

-- Case 04: Customers with Above-Average Purchase Quantity
-- Objective: Find customers who have purchased more items than the average customer to recognize high-engagement customers for loyalty or upselling campaigns.
WITH buy_per_cust AS (
  SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS cust_fullname,
    SUM(il.quantity) AS total_buy
  FROM customer c 
  JOIN invoice i ON c.customer_id = i.customer_id
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  GROUP BY c.customer_id
),

avg_buy AS (
  SELECT AVG(total_buy) AS avg_total 
  FROM buy_per_cust
)

SELECT b.cust_fullname, b.total_buy
FROM buy_per_cust b, avg_buy
WHERE b.total_buy > avg_total;

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

-- Case 08: Cohort Retention Rate Over Time
-- Objective: Track how many customers from each cohort remain active month by month to assess customer retention performance and lifecycle trends.
WITH cohort_data AS (
	SELECT 
		c.customer_id,
		CONCAT(c.first_name, ' ', c.last_name) AS cust_name,
		TO_CHAR(MIN(i.invoice_date),'YYYY-MM') AS cohort_month
	FROM customer c 
	JOIN invoice i on c.customer_id = i.customer_id
	GROUP BY 1),

month_diff_transaction AS (
	SELECT
		cd.customer_id,
		cd.cust_name,
		cd.cohort_month,
		TO_CHAR(i.invoice_date, 'YYYY-MM') AS invoice_month,
		EXTRACT(YEAR FROM AGE((TO_DATE(TO_CHAR(i.invoice_date, 'YYYY-MM'), 'YYYY-MM')), TO_DATE(cd.cohort_month, 'YYYY-MM'))) * 12 +
		EXTRACT(MONTH FROM AGE((TO_DATE(TO_CHAR(i.invoice_date, 'YYYY-MM'), 'YYYY-MM')), TO_DATE(cd.cohort_month, 'YYYY-MM'))) AS n_month_after_first_buy
	FROM cohort_data cd
	JOIN invoice i on cd.customer_id = i.customer_id),

active_cust AS (
	SELECT 
		cohort_month,
		n_month_after_first_buy,
		COUNT(DISTINCT customer_id) AS num_active_customers
	FROM month_diff_transaction
	GROUP BY 1, 2),

cohort_size AS (
	SELECT
		cohort_month,
		n_month_after_first_buy,
		num_active_customers,
		MAX(num_active_customers) OVER (PARTITION BY cohort_month) AS cohort_size
	FROM active_cust)

SELECT 
	cohort_month,
	n_month_after_first_buy,
	num_active_customers,
	cohort_size,
	100*num_active_customers / cohort_size AS retention_rate_percent
FROM cohort_size
WHERE n_month_after_first_buy <= 12
ORDER BY cohort_month, n_month_after_first_buy;

-- Case 09: Churn Analysis by Cohort
-- Objective: Detect when customers stop making purchases by comparing month-to-month activity to measure churn rate per cohort to support retention and reactivation strategies.
WITH cohort_data AS (
	SELECT 
		c.customer_id,
		TO_CHAR(MIN(i.invoice_date),'YYYY-MM') AS cohort_month
	FROM customer c 
	JOIN invoice i ON c.customer_id = i.customer_id
	GROUP BY c.customer_id
),

month_diff_transaction AS (
	SELECT
		cd.customer_id,
		cd.cohort_month,
		EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', i.invoice_date), TO_DATE(cd.cohort_month, 'YYYY-MM'))) * 12 +
		EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', i.invoice_date), TO_DATE(cd.cohort_month, 'YYYY-MM'))) AS n_month_after_buy
	FROM cohort_data cd
	JOIN invoice i ON cd.customer_id = i.customer_id
),

customer_activity AS (
	SELECT DISTINCT
		cohort_month,
		customer_id,
		n_month_after_buy
	FROM month_diff_transaction
),

churn_flag AS (
	SELECT 
		a.cohort_month,
		a.customer_id,
		a.n_month_after_buy,
		CASE 
			WHEN b.customer_id IS NULL THEN TRUE
			ELSE FALSE
		END AS is_churned
	FROM customer_activity a
	LEFT JOIN customer_activity b 
	  ON a.customer_id = b.customer_id 
	 AND a.cohort_month = b.cohort_month
	 AND a.n_month_after_buy + 1 = b.n_month_after_buy
)

SELECT 
	cohort_month,
	n_month_after_buy,
	COUNT(DISTINCT customer_id) AS active_users,
	SUM(CASE WHEN is_churned THEN 1 ELSE 0 END) AS churned_customers,
	ROUND(100.0 * SUM(CASE WHEN is_churned THEN 1 ELSE 0 END) / COUNT(DISTINCT customer_id), 2) AS churn_rate_percent
FROM churn_flag
GROUP BY cohort_month, n_month_after_buy
ORDER BY cohort_month, n_month_after_buy;