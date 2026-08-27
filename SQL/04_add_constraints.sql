USE BikeStoreDB;
GO

-- Drop existing foreign keys first so this script can be rerun safely during testing.
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

-- Some imported staff rows may contain invalid manager_id values such as 0 or blanks converted during import.
-- Convert any manager_id that does not match an existing staff_id to NULL before adding the self-referencing FK.
UPDATE s
SET manager_id = NULL
FROM sales.staffs s
    LEFT JOIN sales.staffs m
    ON s.manager_id = m.staff_id
WHERE s.manager_id IS NOT NULL
    AND m.staff_id IS NULL;
GO

ALTER TABLE sales.staffs
ADD CONSTRAINT FK_staffs_stores
FOREIGN KEY (store_id)
REFERENCES sales.stores(store_id);

ALTER TABLE sales.staffs
ADD CONSTRAINT FK_staffs_manager
FOREIGN KEY (manager_id)
REFERENCES sales.staffs(staff_id);

ALTER TABLE sales.orders
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (customer_id)
REFERENCES sales.customers(customer_id);

ALTER TABLE sales.orders
ADD CONSTRAINT FK_orders_stores
FOREIGN KEY (store_id)
REFERENCES sales.stores(store_id);

ALTER TABLE sales.orders
ADD CONSTRAINT FK_orders_staffs
FOREIGN KEY (staff_id)
REFERENCES sales.staffs(staff_id);

ALTER TABLE sales.order_items
ADD CONSTRAINT FK_order_items_orders
FOREIGN KEY (order_id)
REFERENCES sales.orders(order_id);

ALTER TABLE sales.order_items
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (product_id)
REFERENCES production.products(product_id);

ALTER TABLE production.products
ADD CONSTRAINT FK_products_brands
FOREIGN KEY (brand_id)
REFERENCES production.brands(brand_id);

ALTER TABLE production.products
ADD CONSTRAINT FK_products_categories
FOREIGN KEY (category_id)
REFERENCES production.categories(category_id);

ALTER TABLE production.stocks
ADD CONSTRAINT FK_stocks_stores
FOREIGN KEY (store_id)
REFERENCES sales.stores(store_id);

ALTER TABLE production.stocks
ADD CONSTRAINT FK_stocks_products
FOREIGN KEY (product_id)
REFERENCES production.products(product_id);