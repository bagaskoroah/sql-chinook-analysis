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