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