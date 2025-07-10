-- Case 02: Total Spending per Customer
-- Objective: Calculate the total amount each customer has spent in the store to identify top spending customers and evaluate customer lifetime value (LTV).
SELECT
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	SUM(i.total) AS total_expenses
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 2 DESC;