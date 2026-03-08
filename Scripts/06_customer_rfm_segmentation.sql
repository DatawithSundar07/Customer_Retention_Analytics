/*
Project: Customer Retention Analytics
Script: 06_customer_rfm_segmentation.sql
Goal: Segment customers using the RFM (Recency, Frequency, Monetary) model.

Description:
This query calculates Recency, Frequency, and Monetary metrics for each
customer and assigns quartile scores using NTILE. These scores are then
combined to create customer segments such as Champions, Loyal Customers,
Potential Loyalists, At Risk, and Lost Customers.

This segmentation helps businesses target marketing campaigns,
improve retention strategies, and identify high-value customers.
*/

WITH last_order AS (
SELECT
    MAX(OrderDate) AS max_order_date
FROM FactInternetSales
),  -- identify the most recent order date in the dataset

rfm_base AS (
SELECT
    CustomerKey,
    MAX(OrderDate) AS last_purchase_date,
    COUNT(DISTINCT SalesOrderNumber) AS frequency,
    SUM(SalesAmount) AS monetary_value
FROM FactInternetSales
GROUP BY
    CustomerKey
),  -- calculate base RFM metrics

rfm_calculation AS (
SELECT
    rb.CustomerKey,
    DATEDIFF(DAY, rb.last_purchase_date, lo.max_order_date) AS recency,
    rb.frequency,
    rb.monetary_value
FROM rfm_base rb
CROSS JOIN last_order lo
),  -- calculate recency relative to latest order

rfm_scores AS (
SELECT
    CustomerKey,
    recency,
    frequency,
    monetary_value,
    5 - NTILE(4) OVER (ORDER BY recency ASC) AS recency_score,
    5 - NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
    5 - NTILE(4) OVER (ORDER BY monetary_value DESC) AS monetary_score
FROM rfm_calculation
),  -- assign RFM scores (4 = best)

rfm_combined AS (
SELECT
    CustomerKey,
    recency,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS rfm_total_score
FROM rfm_scores
)

SELECT
    rc.CustomerKey,
    dc.FirstName + ' ' + dc.LastName AS customer_name,
    rc.recency,
    rc.frequency,
    rc.monetary_value,
    rc.recency_score,
    rc.frequency_score,
    rc.monetary_score,
    rc.rfm_total_score,

    CASE
        WHEN rc.recency_score >= 4 AND rc.frequency_score >= 4 AND rc.monetary_score >= 4
            THEN 'Champions'
        WHEN rc.frequency_score >= 3 AND rc.monetary_score >= 3
            THEN 'Loyal Customers'
        WHEN rc.recency_score >= 3 AND rc.frequency_score >= 2
            THEN 'Potential Loyalists'
        WHEN rc.recency_score <= 2 AND rc.frequency_score >= 3
            THEN 'At Risk'
        ELSE 'Lost Customers'
    END AS customer_segment   -- assign marketing segments

FROM rfm_combined rc
JOIN DimCustomer dc
    ON rc.CustomerKey = dc.CustomerKey
ORDER BY
    rc.rfm_total_score DESC;   -- best customers appear first
