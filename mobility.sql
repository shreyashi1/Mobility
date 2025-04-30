CREATE DATABASE MOBILITYDB;

-- Create customer_orders table
CREATE TABLE customer_orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    shipping_address VARCHAR(255),
    order_status VARCHAR(50)
);

-- Create payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES customer_orders(order_id)
);

select * from customer_orders;
select *  from payments;


-- Task 1: Order and Sales Analysis 
-- Order Status & Revenue Trends
SELECT 
    order_status,
    COUNT(*) AS order_count,
    SUM(order_amount) AS total_revenue,
    AVG(order_amount) AS avg_order_value
FROM 
    customer_orders
GROUP BY 
    order_status
ORDER BY 
    total_revenue DESC;

-- Monthly Sales Trend
SELECT 
    p.payment_status,
    COUNT(*) AS transaction_count,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS percentage
FROM 
    payments p
JOIN 
    customer_orders o ON p.order_id = o.order_id
GROUP BY 
    p.payment_status;
SELECT 
    p.payment_method,
    COUNT(*) AS failed_payments,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS failure_rate
FROM 
    payments p
WHERE 
    p.payment_status = 'failed'
GROUP BY 
    p.payment_method;
    
SELECT 
    DATE_FORMAT(order_date, '%Y-%m-01') AS month,
    SUM(order_amount) AS monthly_revenue,
    COUNT(*) AS order_count
FROM 
    customer_orders
WHERE 
    order_status = 'completed'
GROUP BY 
    DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY 
    month;
    
    SET SQL_SAFE_UPDATES = 0;

-- Task 2: customer analysis
-- Repeat Customers
SELECT 
    customer_id,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS lifetime_value
FROM 
    customer_orders
GROUP BY 
    customer_id
HAVING 
    COUNT(*) > 1
ORDER BY 
    total_orders DESC;

-- Customer Segmentation (RFM Analysis)
WITH rfm AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(*) AS frequency,
        SUM(order_amount) AS monetary_value
    FROM 
        customer_orders
    GROUP BY 
        customer_id
)
SELECT 
    customer_id,
    last_order_date,
    frequency,
    monetary_value,
    NTILE(3) OVER (ORDER BY last_order_date) AS recency_score,
    NTILE(3) OVER (ORDER BY frequency) AS frequency_score,
    NTILE(3) OVER (ORDER BY monetary_value) AS monetary_score
FROM 
    rfm;
    
-- Task 3: Payment Status Analysis
-- Payment Success vs. Failure Rates
SELECT 
    p.payment_status,
    COUNT(*) AS transaction_count,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS percentage
FROM 
    payments p
JOIN 
    customer_orders o ON p.order_id = o.order_id
GROUP BY 
    p.payment_status;

-- Failed Payments by Payment Method
SELECT 
    p.payment_method,
    COUNT(*) AS failed_payments,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS failure_rate
FROM 
    payments p
WHERE 
    p.payment_status = 'failed'
GROUP BY 
    p.payment_method;
    
-- Task 4: Order Details Report
-- Comprehensive Order-Payment Report
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.order_amount,
    p.payment_method,
    p.payment_status,
    p.payment_date
FROM 
    customer_orders o
LEFT JOIN 
    payments p ON o.order_id = p.order_id
ORDER BY 
    o.order_date DESC;
    
