

USE BikeStoreDB;
GO

-- Drop existing procedures first so this script can be rerun safely during testing.
IF OBJECT_ID('dbo.sp_SalesSummaryByDate', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SalesSummaryByDate;
GO

IF OBJECT_ID('dbo.sp_StorePerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_StorePerformance;
GO

IF OBJECT_ID('dbo.sp_TopSellingProducts', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TopSellingProducts;
GO

IF OBJECT_ID('dbo.sp_DataQualityCheck', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DataQualityCheck;
GO

IF OBJECT_ID('dbo.sp_LowStockProducts', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_LowStockProducts;
GO

CREATE PROCEDURE dbo.sp_SalesSummaryByDate
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(order_date AS DATE) AS order_date,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(quantity) AS total_quantity,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS discount_amount,
        SUM(net_sales) AS net_sales,
        AVG(CAST(shipping_days AS FLOAT)) AS avg_shipping_days
    FROM dbo.vw_SalesFact
    WHERE order_date BETWEEN @StartDate AND @EndDate
    GROUP BY CAST(order_date AS DATE)
    ORDER BY order_date;
END;
GO

CREATE PROCEDURE dbo.sp_StorePerformance
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        st.store_id,
        st.store_name,
        COUNT(DISTINCT sf.order_id) AS order_count,
        SUM(sf.quantity) AS units_sold,
        SUM(sf.gross_sales) AS gross_sales,
        SUM(sf.discount_amount) AS discount_amount,
        SUM(sf.net_sales) AS net_sales,
        AVG(CAST(sf.shipping_days AS FLOAT)) AS avg_shipping_days
    FROM dbo.vw_SalesFact sf
    JOIN dbo.vw_DimStore st
        ON sf.store_id = st.store_id
    GROUP BY
        st.store_id,
        st.store_name
    ORDER BY net_sales DESC;
END;
GO

CREATE PROCEDURE dbo.sp_TopSellingProducts
    @TopN INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        p.product_id,
        p.product_name,
        p.brand_name,
        p.category_name,
        SUM(sf.quantity) AS units_sold,
        SUM(sf.net_sales) AS net_sales
    FROM dbo.vw_SalesFact sf
    JOIN dbo.vw_DimProduct p
        ON sf.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.brand_name,
        p.category_name
    ORDER BY units_sold DESC;
END;
GO

CREATE PROCEDURE dbo.sp_LowStockProducts
    @Threshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        store_id,
        store_name,
        product_id,
        product_name,
        brand_name,
        category_name,
        stock_quantity
    FROM dbo.vw_Inventory
    WHERE stock_quantity <= @Threshold
    ORDER BY stock_quantity ASC, store_name, product_name;
END;
GO

CREATE PROCEDURE dbo.sp_DataQualityCheck
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'sales.customers' AS table_name, COUNT(*) AS row_count FROM sales.customers
    UNION ALL
    SELECT 'sales.stores', COUNT(*) FROM sales.stores
    UNION ALL
    SELECT 'sales.staffs', COUNT(*) FROM sales.staffs
    UNION ALL
    SELECT 'sales.orders', COUNT(*) FROM sales.orders
    UNION ALL
    SELECT 'sales.order_items', COUNT(*) FROM sales.order_items
    UNION ALL
    SELECT 'production.categories', COUNT(*) FROM production.categories
    UNION ALL
    SELECT 'production.brands', COUNT(*) FROM production.brands
    UNION ALL
    SELECT 'production.products', COUNT(*) FROM production.products
    UNION ALL
    SELECT 'production.stocks', COUNT(*) FROM production.stocks;

    SELECT
        'orders_missing_staff_id' AS check_name,
        COUNT(*) AS issue_count
    FROM sales.orders
    WHERE staff_id IS NULL
    UNION ALL
    SELECT
        'orders_missing_shipped_date',
        COUNT(*)
    FROM sales.orders
    WHERE shipped_date IS NULL
    UNION ALL
    SELECT
        'order_items_invalid_discount',
        COUNT(*)
    FROM sales.order_items
    WHERE discount < 0 OR discount > 1;
END;
GO