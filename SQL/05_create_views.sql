

USE BikeStoreDB;
GO

-- Drop existing views first so this script can be rerun safely during testing.
IF OBJECT_ID('dbo.vw_Inventory', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Inventory;
GO

IF OBJECT_ID('dbo.vw_DimStaff', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DimStaff;
GO

IF OBJECT_ID('dbo.vw_DimStore', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DimStore;
GO

IF OBJECT_ID('dbo.vw_DimCustomer', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DimCustomer;
GO

IF OBJECT_ID('dbo.vw_DimProduct', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DimProduct;
GO

IF OBJECT_ID('dbo.vw_SalesFact', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SalesFact;
GO

CREATE VIEW dbo.vw_SalesFact
AS
    SELECT
        oi.order_id,
        oi.item_id,
        o.customer_id,
        o.store_id,
        o.staff_id,
        oi.product_id,
        o.order_status,
        o.order_date,
        o.required_date,
        o.shipped_date,
        oi.quantity,
        oi.list_price,
        oi.discount,
        oi.quantity * oi.list_price AS gross_sales,
        oi.quantity * oi.list_price * oi.discount AS discount_amount,
        oi.quantity * oi.list_price * (1 - oi.discount) AS net_sales,
        DATEDIFF(DAY, o.order_date, o.shipped_date) AS shipping_days
    FROM sales.order_items oi
        JOIN sales.orders o
        ON oi.order_id = o.order_id;
GO

CREATE VIEW dbo.vw_DimProduct
AS
    SELECT
        p.product_id,
        p.product_name,
        p.model_year,
        p.list_price,
        b.brand_name,
        c.category_name
    FROM production.products p
        JOIN production.brands b
        ON p.brand_id = b.brand_id
        JOIN production.categories c
        ON p.category_id = c.category_id;
GO

CREATE VIEW dbo.vw_DimCustomer
AS
    SELECT
        customer_id,
        first_name,
        last_name,
        first_name + ' ' + last_name AS full_name,
        phone,
        email,
        street,
        city,
        state,
        zip_code
    FROM sales.customers;
GO

CREATE VIEW dbo.vw_DimStore
AS
    SELECT
        store_id,
        store_name,
        phone,
        email,
        street,
        city,
        state,
        zip_code
    FROM sales.stores;
GO

CREATE VIEW dbo.vw_DimStaff
AS
    SELECT
        s.staff_id,
        s.first_name + ' ' + s.last_name AS staff_name,
        s.email,
        s.phone,
        s.active,
        s.store_id,
        st.store_name,
        s.manager_id,
        m.first_name + ' ' + m.last_name AS manager_name
    FROM sales.staffs s
        LEFT JOIN sales.stores st
        ON s.store_id = st.store_id
        LEFT JOIN sales.staffs m
        ON s.manager_id = m.staff_id;
GO

CREATE VIEW dbo.vw_Inventory
AS
    SELECT
        st.store_id,
        st.store_name,
        p.product_id,
        p.product_name,
        b.brand_name,
        c.category_name,
        s.quantity AS stock_quantity
    FROM production.stocks s
        JOIN sales.stores st
        ON s.store_id = st.store_id
        JOIN production.products p
        ON s.product_id = p.product_id
        JOIN production.brands b
        ON p.brand_id = b.brand_id
        JOIN production.categories c
        ON p.category_id = c.category_id;
GO