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