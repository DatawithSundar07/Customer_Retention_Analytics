/*
Project: Customer_Retention_Analytics
Script: 02_customer_retention_rate.sql
Goal: Calculate monthly customer retention and retention percentage by cohort.

Description:
This query identifies each customer's cohort (first purchase month),
tracks their monthly activity, and calculates how many customers
return in subsequent months along with the retention percentage.
*/

WITH first_purchase AS (
SELECT
    CustomerKey,
    MIN(OrderDate) AS first_purchase_date
FROM FactInternetSales
GROUP BY CustomerKey
),  -- Identify the first purchase date for each customer

cohort AS (
SELECT
    CustomerKey,
    DATEFROMPARTS(YEAR(first_purchase_date),MONTH(first_purchase_date),1) AS cohort_month
FROM first_purchase
),  -- Assign each customer to a cohort based on their first purchase month

customer_activity AS (
SELECT DISTINCT
    CustomerKey,
    DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) AS order_month
FROM FactInternetSales
),  -- Capture the months in which each customer made a purchase

cohort_size AS (
SELECT
    cohort_month,
    COUNT(DISTINCT CustomerKey) AS cohort_size
FROM cohort
GROUP BY cohort_month
)  -- Calculate the total number of customers in each cohort

-- Calculate monthly active customers and retention percentage for each cohort
SELECT
    c.cohort_month,
    ca.order_month,
    COUNT(DISTINCT ca.CustomerKey) AS active_customers,
    cs.cohort_size,
    DATEDIFF(MONTH,c.cohort_month,ca.order_month) AS retention_month,
    ROUND(
        COUNT(DISTINCT ca.CustomerKey) * 100.0 / cs.cohort_size,
        2
    ) AS retention_percentage
FROM cohort c
JOIN customer_activity ca
    ON c.CustomerKey = ca.CustomerKey
JOIN cohort_size cs
    ON c.cohort_month = cs.cohort_month
WHERE ca.order_month >= c.cohort_month
GROUP BY
    c.cohort_month,
    ca.order_month,
    cs.cohort_size
ORDER BY
    c.cohort_month,
    ca.order_month;
