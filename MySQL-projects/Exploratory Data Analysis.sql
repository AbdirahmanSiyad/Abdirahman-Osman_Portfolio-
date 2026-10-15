/*
===============================================================================
Script: Exploratory Data Analysis (EDA) - Gold Layer
===============================================================================
Script Purpose:
    This script performs Exploratory Data Analysis (EDA) on the Gold layer views 
    of the data warehouse to extract business insights and validate data quality.

    It covers the following analytical areas:
    - Database & Metadata Exploration: Inspecting database objects and schemas.
    - Dimension Exploration: Identifying unique categories, segments, and geographic distributions.
    - Date & Time Analysis: Determining data spans, temporal boundaries, and timelines.
    - Measure & Aggregation Analysis: Calculating core business key performance indicators (KPIs).
    - Magnitude Analysis: Comparing measures across different categories and dimensions.
    - Ranking Analysis: Identifying top-performing vs. bottom-performing entities.

Usage:
    Run these queries in MySQL Workbench to understand the dataset structure, 
    evaluate business metrics, and generate executive reports.
===============================================================================
*/

USE gold;

-- =============================================================================
-- SECTION 1: Database & Metadata Exploration
-- =============================================================================

-- Explore all tables and views available in the database schema
SELECT * 
FROM information_schema.tables;

-- Explore all columns and data types in the customer dimension
SELECT * 
FROM information_schema.columns
WHERE table_name = 'dim_customers';


-- =============================================================================
-- SECTION 2: Dimension Exploration
-- =============================================================================
-- Purpose: Identify unique categories and attributes for customer segmentation and grouping.

-- Explore all unique customer countries
SELECT DISTINCT country 
FROM gold.dim_customers;

-- Explore all unique product categories, subcategories, and product names
SELECT DISTINCT category, subcategory, product_name 
FROM gold.dim_products
ORDER BY 1, 2, 3;


-- =============================================================================
-- SECTION 3: Date & Time Analysis
-- =============================================================================
-- Purpose: Understand the scope, span, and boundaries of transactional timelines.

-- Find the date of the first and last order, and calculate total months of sales data available
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the birthdates of the youngest and oldest customers
SELECT
    MIN(birthdate) AS youngest_customer_birthdate, 
    MAX(birthdate) AS oldest_customer_birthdate
FROM gold.dim_customers;


-- =============================================================================
-- SECTION 4: Measure & Aggregation Analysis (Core Business KPIs)
-- =============================================================================
-- Purpose: Compute high-level aggregations to evaluate total business volume.

-- Calculate primary business performance metrics
SELECT 
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantities_sold,
    AVG(price) AS avg_selling_price,
    COUNT(order_number) AS total_order_rows,
    COUNT(DISTINCT order_number) AS total_unique_orders,
    COUNT(DISTINCT customer_key) AS total_customers_with_orders
FROM gold.fact_sales;

-- Count total products available in the catalog
SELECT COUNT(product_key) AS total_products 
FROM gold.dim_products;
              
-- Count total registered customers
SELECT COUNT(customer_key) AS total_customers 
FROM gold.dim_customers;

-- =============================================================================
-- Executive KPI Summary Report
-- =============================================================================
-- Generates a consolidated single-view report combining all key business metrics.

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Unique Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Products' AS measure_name, COUNT(product_name) AS measure_value FROM gold.dim_products
UNION ALL 
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers;


-- =============================================================================
-- SECTION 5: Magnitude Analysis (Categorical Comparisons)
-- =============================================================================
-- Purpose: Compare metrics across different dimensions to evaluate category importance.

-- Find total customers by country (sorted descending)
SELECT 
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country 
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT 
    gender, 
    COUNT(customer_key) AS total_customers 
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
SELECT 
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Find average product cost by category
SELECT 
    category,
    AVG(cost) AS avg_cost 
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Find total revenue generated by each product category
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Find total revenue generated by each customer
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key, 
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Find the distribution of sold items across countries
SELECT 
    c.country,
    SUM(f.quantity) AS total_sold_items 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


-- =============================================================================
-- SECTION 6: Ranking Analysis
-- =============================================================================
-- Purpose: Order dimensional values by aggregated measures to identify top and bottom performers.

-- Approach 1: Identify top 5 products generating the highest revenue using LIMIT
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Approach 2: Identify top 5 products generating the highest revenue using Window Functions (ROW_NUMBER)
SELECT *
FROM (
    SELECT 
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products 
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) t 
WHERE rank_products <= 5;

-- Identify the 5 worst-performing products in terms of sales revenue
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5;
