-- ==============================================================================
-- SQL Data Extraction Queries
-- E-Commerce Transaction & Performance Analysis (Week 3)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Table Creation and Scaffolding
-- Run this schema script to initialize the SQLite database table.
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transactions (
    OrderID VARCHAR(20) PRIMARY KEY,
    Date TIMESTAMP,
    CustomerID VARCHAR(20),
    Product VARCHAR(50),
    Quantity INTEGER,
    UnitPrice REAL,
    ShippingAddress VARCHAR(255),
    PaymentMethod VARCHAR(50),
    OrderStatus VARCHAR(50),
    TrackingNumber VARCHAR(100),
    ItemsInCart INTEGER,
    CouponCode VARCHAR(50),
    ReferralSource VARCHAR(50),
    TotalPrice REAL
);

-- ------------------------------------------------------------------------------
-- 2. Core Performance & Descriptive Statistics
-- Calculates overall totals, averages, medians, and bounds.
-- ------------------------------------------------------------------------------

-- Query 2.1: Basic aggregates for order size, pricing, and cart activity
SELECT 
    COUNT(OrderID) AS Total_Orders,
    SUM(TotalPrice) AS Gross_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value,
    MIN(TotalPrice) AS Min_Order_Value,
    MAX(TotalPrice) AS Max_Order_Value,
    AVG(Quantity) AS Avg_Quantity_Per_Order,
    AVG(ItemsInCart) AS Avg_Items_In_Cart
FROM transactions;


-- ------------------------------------------------------------------------------
-- 3. Product Performance Profile
-- Aggregates orders, quantities, revenue, and pricing per product.
-- ------------------------------------------------------------------------------

-- Query 3.1: Product performance breakdown, sorted by total revenue descending
SELECT 
    Product,
    COUNT(OrderID) AS Order_Count,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(TotalPrice) AS Total_Revenue,
    AVG(UnitPrice) AS Avg_Unit_Price
FROM transactions
GROUP BY Product
ORDER BY Total_Revenue DESC;


-- ------------------------------------------------------------------------------
-- 4. Order Fulfillment & Funnel Status
-- Identifies the percentage and count of each order status.
-- ------------------------------------------------------------------------------

-- Query 4.1: Fulfillment counts and percentage of overall funnel
SELECT 
    OrderStatus,
    COUNT(OrderID) AS Order_Count,
    ROUND(COUNT(OrderID) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS Percentage_Of_Total
FROM transactions
GROUP BY OrderStatus
ORDER BY Order_Count DESC;

-- Query 4.2: High-value order cancellation audit
-- Inspects if cancelled orders have higher average order values than delivered ones.
SELECT 
    OrderStatus,
    COUNT(OrderID) AS Order_Count,
    AVG(Quantity) AS Avg_Quantity,
    AVG(TotalPrice) AS Avg_Order_Value
FROM transactions
GROUP BY OrderStatus
ORDER BY Avg_Order_Value DESC;


-- ------------------------------------------------------------------------------
-- 5. Sales Trends & Seasonality
-- Analyzes sales patterns by month, quarter, and year.
-- ------------------------------------------------------------------------------

-- Query 5.1: Yearly revenue comparison
SELECT 
    STRFTIME('%Y', Date) AS Year,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Yearly_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value
FROM transactions
GROUP BY Year
ORDER BY Year ASC;

-- Query 5.2: Year-over-Year comparison for the first half of the year (H1: Jan to Jun)
-- This eliminates seasonal bias when evaluating sales contraction.
SELECT 
    STRFTIME('%Y', Date) AS Year,
    COUNT(OrderID) AS H1_Order_Count,
    SUM(TotalPrice) AS H1_Revenue,
    AVG(TotalPrice) AS H1_Avg_Order_Value
FROM transactions
WHERE STRFTIME('%m', Date) BETWEEN '01' AND '06'
GROUP BY Year
ORDER BY Year ASC;

-- Query 5.3: Monthly revenue seasonality breakdown
SELECT 
    STRFTIME('%m', Date) AS Month_Number,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Monthly_Revenue
FROM transactions
GROUP BY Month_Number
ORDER BY Monthly_Revenue DESC;


-- ------------------------------------------------------------------------------
-- 6. Marketing Acquisition Channels
-- Identifies where the highest-revenue orders originate.
-- ------------------------------------------------------------------------------

-- Query 6.1: Referral source performance, ranked by total revenue
SELECT 
    ReferralSource,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Total_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value
FROM transactions
GROUP BY ReferralSource
ORDER BY Total_Revenue DESC;


-- ------------------------------------------------------------------------------
-- 7. Payment Methods Breakdown
-- Analyzes transaction volumes and values by payment provider.
-- ------------------------------------------------------------------------------

-- Query 7.1: Payment method performance
SELECT 
    PaymentMethod,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Total_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value
FROM transactions
GROUP BY PaymentMethod
ORDER BY Total_Revenue DESC;


-- ------------------------------------------------------------------------------
-- 8. Coupon Code Effectiveness & Returns
-- Evaluates transaction volumes and returns based on the coupon code applied.
-- ------------------------------------------------------------------------------

-- Query 8.1: Return rates and revenues per coupon code
SELECT 
    COALESCE(NULLIF(CouponCode, ''), 'No Coupon') AS Coupon_Applied,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Total_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value,
    SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END) AS Returned_Count,
    ROUND(SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(OrderID), 2) AS Return_Rate_Pct
FROM transactions
GROUP BY Coupon_Applied
ORDER BY Total_Revenue DESC;


-- ------------------------------------------------------------------------------
-- 9. Outlier and High-Value Transaction Detection
-- Identifies orders that lie far above the typical order values.
-- ------------------------------------------------------------------------------

-- Query 9.1: Locate all orders exceeding the statistical IQR upper bound ($3,330.41)
SELECT 
    OrderID,
    Date,
    Product,
    Quantity,
    UnitPrice,
    TotalPrice,
    OrderStatus
FROM transactions
WHERE TotalPrice > 3330.41
ORDER BY TotalPrice DESC;
