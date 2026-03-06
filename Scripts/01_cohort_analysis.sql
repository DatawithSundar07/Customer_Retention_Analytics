/*
Project: Customer Retention Analytics (SQL Portfolio)
Script: 01_cohort_analysis.sql
Goal: Identify the first purchase month (cohort) for each customer.

Description:
This query determines when each customer made their first purchase
and assigns them to a cohort based on that purchase month.
The cohort will later be used for retention analysis.
*/

WITH first_purchase AS (
SELECT
    CustomerKey,
    MIN(OrderDate) AS first_purchase_date
FROM FactInternetSales
GROUP BY CustomerKey
)  -- Find the first purchase date for each customer

-- Assign each customer to a cohort month and retrieve customer details
SELECT
    fp.CustomerKey,
    dc.FirstName + ' ' + dc.LastName AS customer_name,
    DATEFROMPARTS(
        YEAR(fp.first_purchase_date),
        MONTH(fp.first_purchase_date),
        1
    ) AS cohort_month
FROM first_purchase fp
JOIN DimCustomer dc
    ON fp.CustomerKey = dc.CustomerKey
ORDER BY
    cohort_month,
    fp.CustomerKey;

