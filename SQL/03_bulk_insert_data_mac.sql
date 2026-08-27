USE BikeStoreDB;
GO

-- Drop existing foreign keys first so this import script can be rerun safely during testing.
IF OBJECT_ID('sales.FK_staffs_stores', 'F') IS NOT NULL
    ALTER TABLE sales.staffs DROP CONSTRAINT FK_staffs_stores;

IF OBJECT_ID('sales.FK_staffs_manager', 'F') IS NOT NULL
    ALTER TABLE sales.staffs DROP CONSTRAINT FK_staffs_manager;

IF OBJECT_ID('sales.FK_orders_customers', 'F') IS NOT NULL
    ALTER TABLE sales.orders DROP CONSTRAINT FK_orders_customers;

IF OBJECT_ID('sales.FK_orders_stores', 'F') IS NOT NULL
    ALTER TABLE sales.orders DROP CONSTRAINT FK_orders_stores;

IF OBJECT_ID('sales.FK_orders_staffs', 'F') IS NOT NULL
    ALTER TABLE sales.orders DROP CONSTRAINT FK_orders_staffs;

IF OBJECT_ID('sales.FK_order_items_orders', 'F') IS NOT NULL
    ALTER TABLE sales.order_items DROP CONSTRAINT FK_order_items_orders;

IF OBJECT_ID('sales.FK_order_items_products', 'F') IS NOT NULL
    ALTER TABLE sales.order_items DROP CONSTRAINT FK_order_items_products;

IF OBJECT_ID('production.FK_products_brands', 'F') IS NOT NULL
    ALTER TABLE production.products DROP CONSTRAINT FK_products_brands;

IF OBJECT_ID('production.FK_products_categories', 'F') IS NOT NULL
    ALTER TABLE production.products DROP CONSTRAINT FK_products_categories;

IF OBJECT_ID('production.FK_stocks_stores', 'F') IS NOT NULL
    ALTER TABLE production.stocks DROP CONSTRAINT FK_stocks_stores;

IF OBJECT_ID('production.FK_stocks_products', 'F') IS NOT NULL
    ALTER TABLE production.stocks DROP CONSTRAINT FK_stocks_products;
GO

-- Make this script rerunnable while testing.
TRUNCATE TABLE sales.order_items;
TRUNCATE TABLE sales.orders;
TRUNCATE TABLE sales.staffs;
TRUNCATE TABLE sales.stores;
TRUNCATE TABLE sales.customers;
TRUNCATE TABLE production.stocks;
TRUNCATE TABLE production.products;
TRUNCATE TABLE production.brands;
TRUNCATE TABLE production.categories;
GO

BULK INSERT sales.customers
FROM '/var/opt/mssql/import/customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT sales.stores
FROM '/var/opt/mssql/import/stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- staffs.csv contains blank manager_id values.
-- Load into a staging table first, then convert blank manager_id values to NULL.
IF OBJECT_ID('tempdb..#staffs_staging') IS NOT NULL
    DROP TABLE #staffs_staging;

CREATE TABLE #staffs_staging
(
    staff_id VARCHAR(50),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    active VARCHAR(50),
    store_id VARCHAR(50),
    manager_id VARCHAR(50)
);

BULK INSERT #staffs_staging
FROM '/var/opt/mssql/import/staffs.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

INSERT INTO sales.staffs
    (
    staff_id,
    first_name,
    last_name,
    email,
    phone,
    active,
    store_id,
    manager_id
    )
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(staff_id), '')),
    first_name,
    last_name,
    email,
    phone,
    TRY_CONVERT(INT, NULLIF(TRIM(active), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(store_id), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(REPLACE(REPLACE(manager_id, CHAR(13), ''), CHAR(10), '')), ''))
FROM #staffs_staging;

-- orders.csv contains blank shipped_date values.
-- Load into a staging table first, then convert blank shipped_date values to NULL.
IF OBJECT_ID('tempdb..#orders_staging') IS NOT NULL
    DROP TABLE #orders_staging;

CREATE TABLE #orders_staging
(
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_date VARCHAR(50),
    required_date VARCHAR(50),
    shipped_date VARCHAR(50),
    store_id VARCHAR(50),
    staff_id VARCHAR(50)
);

BULK INSERT #orders_staging
FROM '/var/opt/mssql/import/orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

INSERT INTO sales.orders
    (
    order_id,
    customer_id,
    order_status,
    order_date,
    required_date,
    shipped_date,
    store_id,
    staff_id
    )
SELECT
    TRY_CONVERT(INT, NULLIF(TRIM(order_id), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(customer_id), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(order_status), '')),
    TRY_CONVERT(DATE, NULLIF(TRIM(order_date), '')),
    TRY_CONVERT(DATE, NULLIF(TRIM(required_date), '')),
    TRY_CONVERT(DATE, NULLIF(TRIM(REPLACE(REPLACE(shipped_date, CHAR(13), ''), CHAR(10), '')), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(store_id), '')),
    TRY_CONVERT(INT, NULLIF(TRIM(REPLACE(REPLACE(staff_id, CHAR(13), ''), CHAR(10), '')), ''))
FROM #orders_staging;

BULK INSERT sales.order_items
FROM '/var/opt/mssql/import/order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT production.categories
FROM '/var/opt/mssql/import/categories.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT production.brands
FROM '/var/opt/mssql/import/brands.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT production.products
FROM '/var/opt/mssql/import/products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT production.stocks
FROM '/var/opt/mssql/import/stocks.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);