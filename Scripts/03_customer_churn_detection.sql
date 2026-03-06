/*
Project: Customer Retention Analytics
Script: 03_customer_churn_detection.sql
Goal: Identify churned customers based on inactivity period.

Description:
This query finds the last purchase date for each customer,
compares it with the latest order date in the dataset,
and classifies customers as Active or Churned based on
the number of days since their last purchase.
*/

WITH last_purchase AS (
SELECT
    CustomerKey,
    MAX(OrderDate) AS last_purchase_date   -- find the last purchase date for each customer
FROM FactInternetSales
GROUP BY
    CustomerKey
),

last_order AS (
SELECT
    MAX(OrderDate) AS last_order_date   -- identify the most recent order date in the dataset
FROM FactInternetSales
)

SELECT
    lp.CustomerKey,
    dc.FirstName + ' ' + dc.LastName AS customer_name,   -- get customer full name from dimension table
    lp.last_purchase_date,
    DATEDIFF(DAY, lp.last_purchase_date, lo.last_order_date) AS days_since_last_purchase,   -- calculate inactivity period
    CASE
        WHEN DATEDIFF(DAY, lp.last_purchase_date, lo.last_order_date) > 180 THEN 'Churned'
        ELSE 'Active'
    END AS customer_status   -- classify customer based on inactivity threshold
FROM last_purchase lp
CROSS JOIN last_order lo
JOIN DimCustomer dc
    ON lp.CustomerKey = dc.CustomerKey   -- join to retrieve customer details
ORDER BY
    days_since_last_purchase DESC;   -- most inactive customers appear first
