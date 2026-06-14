# Decodelabs Internship: Project 3 - SQL Queries & Database Insights

This repository contains the dataset, SQL query script, and documentation for Project 3 of the DecodeLabs Data Analytics Internship. The primary focus of this project was to translate raw business questions into structured, optimized SQL queries to extract key metrics and strategic insights from the database.

## Project Overview

In production environments, e-commerce data resides in relational database tables rather than spreadsheets. This project provides a robust, fully-documented SQL file (`queries.sql`) containing schema definition scripts and analytical queries. The queries filter, group, aggregate, and audit a database representation of the transactional data containing 1,200 orders.

### Project File Inventory

* **`queries.sql`**: The finalized SQL script containing schema tables, formatting, and analytical query blocks.
* **`Dataset for Data Analytics p3.xlsx`**: The spreadsheet representation of the transaction records.
* **`Data Analytics Project 3.pdf`**: The official project assignment requirements.

---

## SQL Schema and Structure

The database mapping is based on the `transactions` table schema. Below is the SQL creation block used to initialize the table:

```sql
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
```

---

## Core Queries & Insight Extraction

The `queries.sql` file contains highly commented query blocks designed to extract specific business performance metrics:

### 1. General Metrics & Summary Statistics
Calculates total transactions, gross revenue, average order value, average items per cart, and average quantities using standard aggregations:
```sql
SELECT 
    COUNT(OrderID) AS Total_Orders,
    SUM(TotalPrice) AS Gross_Revenue,
    AVG(TotalPrice) AS Avg_Order_Value,
    AVG(Quantity) AS Avg_Quantity_Per_Order
FROM transactions;
```

### 2. Product Revenue Rankings
Groups orders by product catalog and ranks them by total sales revenue to find top performance lines:
```sql
SELECT Product, SUM(Quantity), SUM(TotalPrice) AS Total_Revenue
FROM transactions
GROUP BY Product
ORDER BY Total_Revenue DESC;
```

### 3. Order status and Funnel Analysis
Calculates the exact breakdown of the order fulfillment funnel, displaying counts and overall percentages:
```sql
SELECT 
    OrderStatus,
    COUNT(OrderID) AS Order_Count,
    ROUND(COUNT(OrderID) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS Percentage_Of_Total
FROM transactions
GROUP BY OrderStatus
ORDER BY Order_Count DESC;
```

### 4. Year-over-Year H1 Sales Trends
Isolates transactions in the first half of the year (January 1 to June 30) for 2023, 2024, and 2025 to evaluate YoY changes without seasonal bias:
```sql
SELECT 
    STRFTIME('%Y', Date) AS Year,
    COUNT(OrderID) AS H1_Order_Count,
    SUM(TotalPrice) AS H1_Revenue
FROM transactions
WHERE STRFTIME('%m', Date) BETWEEN '01' AND '06'
GROUP BY Year
ORDER BY Year ASC;
```

### 5. Coupon Performance & Return Rates
Uses conditional aggregation (`CASE WHEN`) to calculate how different coupon codes correlate with order return rates:
```sql
SELECT 
    COALESCE(NULLIF(CouponCode, ''), 'No Coupon') AS Coupon_Applied,
    COUNT(OrderID) AS Order_Count,
    SUM(TotalPrice) AS Total_Revenue,
    SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END) AS Returned_Count,
    ROUND(SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(OrderID), 2) AS Return_Rate_Pct
FROM transactions
GROUP BY Coupon_Applied
ORDER BY Total_Revenue DESC;
```

### 6. High-Value Outlier Identification
Locates transactions that exceed the statistical IQR upper bound ($3,330.41):
```sql
SELECT OrderID, Date, Product, Quantity, TotalPrice
FROM transactions
WHERE TotalPrice > 3330.41
ORDER BY TotalPrice DESC;
```
