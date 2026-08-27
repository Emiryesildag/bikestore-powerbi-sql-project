

USE BikeStoreDB;
GO

-- 1. Row count validation for all raw tables
SELECT COUNT(*) AS customer_count
FROM sales.customers;
SELECT COUNT(*) AS store_count
FROM sales.stores;
SELECT COUNT(*) AS staff_count
FROM sales.staffs;
SELECT COUNT(*) AS order_count
FROM sales.orders;
SELECT COUNT(*) AS order_item_count
FROM sales.order_items;
SELECT COUNT(*) AS category_count
FROM production.categories;
SELECT COUNT(*) AS brand_count
FROM production.brands;
SELECT COUNT(*) AS product_count
FROM production.products;
SELECT COUNT(*) AS stock_count
FROM production.stocks;
GO

-- 2. Check whether critical imported columns are populated correctly
SELECT
    COUNT(*) AS total_orders,
    COUNT(staff_id) AS orders_with_staff_id,
    COUNT(*) - COUNT(staff_id) AS orders_missing_staff_id,
    COUNT(shipped_date) AS orders_with_shipped_date,
    COUNT(*) - COUNT(shipped_date) AS orders_missing_shipped_date
FROM sales.orders;
GO

-- 3. Preview reporting views used by Power BI
SELECT TOP 10
    *
FROM dbo.vw_SalesFact;
SELECT TOP 10
    *
FROM dbo.vw_DimProduct;
SELECT TOP 10
    *
FROM dbo.vw_DimCustomer;
SELECT TOP 10
    *
FROM dbo.vw_DimStore;
SELECT TOP 10
    *
FROM dbo.vw_DimStaff;
SELECT TOP 10
    *
FROM dbo.vw_Inventory;
GO

-- 4. Validate key business totals from the main sales fact view
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_lines,
    SUM(quantity) AS total_units_sold,
    SUM(gross_sales) AS total_gross_sales,
    SUM(discount_amount) AS total_discount_amount,
    SUM(net_sales) AS total_net_sales,
    AVG(CAST(discount AS FLOAT)) AS average_discount,
    AVG(CAST(shipping_days AS FLOAT)) AS average_shipping_days
FROM dbo.vw_SalesFact;
GO

-- 5. Monthly sales summary for Power BI comparison
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(quantity) AS units_sold,
    SUM(net_sales) AS net_sales
FROM dbo.vw_SalesFact
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year, sales_month;
GO

-- 6. Store performance validation
EXEC dbo.sp_StorePerformance;
GO

-- 7. Top product validation
EXEC dbo.sp_TopSellingProducts @TopN = 10;
GO

-- 8. Date-range sales procedure validation
EXEC dbo.sp_SalesSummaryByDate
    @StartDate = '2016-01-01',
    @EndDate = '2016-12-31';
GO

-- 9. Inventory / low stock validation
EXEC dbo.sp_LowStockProducts @Threshold = 10;
GO

-- 10. General data quality checks
EXEC dbo.sp_DataQualityCheck;
GO