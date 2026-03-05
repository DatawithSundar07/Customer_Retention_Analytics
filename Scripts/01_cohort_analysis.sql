WITH first_purchase AS (
SELECT
    CustomerKey,
    MIN(OrderDate) AS first_purchase_date   -- find the first purchase date for each customer
FROM FactInternetSales
GROUP BY
    CustomerKey
)
SELECT
    fp.CustomerKey,
    dc.FirstName + ' ' + dc.LastName AS customer_name,   -- get customer full name from dimension table
    DATEFROMPARTS(YEAR(fp.first_purchase_date),MONTH(fp.first_purchase_date),1) AS cohort_month   -- convert first purchase date to cohort month
FROM first_purchase fp
JOIN DimCustomer dc
    ON fp.CustomerKey = dc.CustomerKey   -- join to get customer details
ORDER BY
    cohort_month,
    fp.CustomerKey;   -- sort customers by cohort month
