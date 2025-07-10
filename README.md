# SQL Analytics Portfolio – Chinook Dataset

This repository contains a collection of SQL business analysis use cases based on the [Chinook](https://github.com/lerocha/chinook-database) dataset, a popular sample database representing a digital music store.

Each case is written with a focus on real-world business questions and industry-relevant SQL techniques, such as subqueries, CTEs, window functions, cohort analysis.

---

## Selected Use Cases

| Case | Title | Description |
|------|-------|-------------|
| 01   | Customer & Country | Extract customer names and countries |
| 02   | Total Expense per Customer | Calculate total spending by customer |
| 03   | Above-Avg Genre Price Songs | Find songs priced above genre average |
| 04   | Customers Buying Above Average | Identify customers buying more than average quantity |
| 05   | High Value Customers | Detect customers whose total spend is above average |
| 06   | Purchase Frequency | Analyze days between purchases per customer |
| 07   | Customer Segmentation | Segment customers into tiers using quartile of total spend |
| 08   | Cohort Retention Analysis | Track customer retention month by month from first purchase |
| 09   | Churn Analysis | Identify churn behavior per cohort using self-join logic |

---

## Tools & Concepts Used

- PostgreSQL
- Window Functions (`RANK()`, `LAG()`, `NTILE()`, `OVER`)
- Common Table Expressions (CTE)
- Aggregation and Filtering
- Subqueries and Self-Joins
- Cohort & Churn Analysis

---

## File Structure

- `/queries`: contains `.sql` files for each use case.
- `/data`: optional schema diagrams or mock data.

---

## About the Dataset

- [Chinook Database](https://github.com/lerocha/chinook-database)
- Represents music store data with customers, tracks, invoices, genres, etc.
- Compatible with PostgreSQL (version used: Chinook_PostgreSql.sql)

---

## Author

Created by **Bagaskoro Adi Hutomo**  
Please feel free to contact me for further discussion on: 
LinkedIn: www.linkedin.com/in/bagaskoroah 
Email: bagaskoroah@gmail.com