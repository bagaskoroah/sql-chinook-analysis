-- Case 01: List Customer Names and Countries
-- Objective: Retrieve all customers along with their respective country of origin to understand customer geographic distribution for regional marketing strategies.
SELECT
	CONCAT(first_name, ' ', last_name) AS customer_name,
	country AS customer_country
FROM customer
ORDER BY 1;