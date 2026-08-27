# BikeStore Power BI & SQL Server Project

This project analyzes the BikeStore sample database using Microsoft SQL Server and Power BI.

The main idea is to start from CSV files, build a relational SQL Server database, create a SQL reporting layer with views and stored procedures, and then connect Power BI to those SQL outputs.

## Project Goal

Build a SQL-backed sales analytics dashboard for a multi-store bicycle retailer.

The dashboard is planned to analyze:

- Revenue and order performance
- Product, brand, and category performance
- Customer geography
- Inventory and low-stock products
- Store and staff performance
- Shipping delay and operational metrics

## Dataset

The project uses a BikeStores-style relational CSV dataset.

Raw CSV files are stored in the `data/` folder:

- `brands.csv`
- `categories.csv`
- `customers.csv`
- `order_items.csv`
- `orders.csv`
- `products.csv`
- `staffs.csv`
- `stocks.csv`
- `stores.csv`

## Database Design

The database is created as `BikeStoreDB`.

Two schemas are used to match the ERD structure:

- `sales`
- `production`

Main tables:

```text
sales.customers
sales.stores
sales.staffs
sales.orders
sales.order_items

production.categories
production.brands
production.products
production.stocks
```

Primary keys are created during table creation.
Foreign keys are added after the CSV import step in `04_add_constraints.sql`.

## Project Workflow

1. Import CSV files into SQL Server.
2. Create relational tables with primary keys.
3. Clean problematic CSV fields during import using staging tables.
4. Add foreign key relationships after import.
5. Build SQL views for Power BI reporting.
6. Create stored procedures for validation and analysis.
7. Connect Power BI Desktop to SQL Server reporting views.
8. Build interactive dashboards using DAX measures and slicers.

## Folder Structure

- `data/`: Original CSV files
- `sql/`: SQL scripts for database creation, import, constraints, views, procedures, and validation
- `docs/`: Documentation and dashboard planning
- `powerbi/`: Power BI report file

## SQL Execution Order

Run the scripts in this order:

1. `01_create_database.sql`
2. `02_create_tables.sql`
3. Bulk insert script depending on environment:
   - Mac/Docker: `03_bulk_insert_data_mac.sql`
   - Windows: `03_bulk_insert_data_win.sql`
4. `04_add_constraints.sql`
5. `05_create_views.sql`
6. `06_create_procedures.sql`
7. `07_validation_queries.sql`

## Environment-Specific Import Notes

### Mac / Docker

The Mac/Docker script expects CSV files inside the SQL Server container at:

```text
/var/opt/mssql/import/
```

During local testing, the CSV files were copied into the running SQL Server Docker container.

Example command:

```bash
docker cp mssql/import SQL_Server_Docker:/var/opt/mssql/import
```

The Mac/Docker import script is:

```text
sql/03_bulk_insert_data_mac.sql
```

### Windows

The Windows script expects the project folder to be located at:

```text
C:\BikeStore_Project\
```

Therefore, the CSV files should be available at paths such as:

```text
C:\BikeStore_Project\data\customers.csv
C:\BikeStore_Project\data\orders.csv
```

The Windows import script is:

```text
sql/03_bulk_insert_data_win.sql
```

If the project is placed in a different Windows folder, update the file paths inside `03_bulk_insert_data_win.sql`.

## Important Import Handling

Some CSV fields contain blank values that cannot be imported directly into `DATE` or `INT` columns.

To handle this:

- `orders.csv` is first loaded into a temporary staging table.
- Blank `shipped_date` values are converted to `NULL`.
- `staff_id` is cleaned before conversion to `INT`.
- `staffs.csv` is first loaded into a temporary staging table.
- Blank `manager_id` values are converted to `NULL`.

This prevents common SQL Server bulk import errors caused by blank dates, blank IDs, or hidden line-ending characters.

## SQL Reporting Views

Power BI connects mainly to SQL Server reporting views, not directly to raw tables.

Main views:

- `dbo.vw_SalesFact`
- `dbo.vw_DimProduct`
- `dbo.vw_DimCustomer`
- `dbo.vw_DimStore`
- `dbo.vw_DimStaff`
- `dbo.vw_Inventory`

Suggested Power BI model relationships:

```text
dbo.vw_DimProduct[product_id]   -> dbo.vw_SalesFact[product_id]
dbo.vw_DimCustomer[customer_id] -> dbo.vw_SalesFact[customer_id]
dbo.vw_DimStore[store_id]       -> dbo.vw_SalesFact[store_id]
dbo.vw_DimStaff[staff_id]       -> dbo.vw_SalesFact[staff_id]
```

## Stored Procedures

Stored procedures are included for validation and analysis:

- `dbo.sp_SalesSummaryByDate`
- `dbo.sp_StorePerformance`
- `dbo.sp_TopSellingProducts`
- `dbo.sp_LowStockProducts`
- `dbo.sp_DataQualityCheck`

These procedures are not necessarily the main Power BI model tables. They are mainly used for SQL-side analysis, testing, and demonstration.

## Power BI Plan

Planned report pages:

1. Executive Summary
2. Sales Performance
3. Product & Brand Analysis
4. Customer Geography
5. Inventory Monitoring
6. Staff & Store Operations

Recommended measures in Power BI:

```DAX
Net Sales = SUM(vw_SalesFact[net_sales])
Gross Sales = SUM(vw_SalesFact[gross_sales])
Discount Amount = SUM(vw_SalesFact[discount_amount])
Units Sold = SUM(vw_SalesFact[quantity])
Order Count = DISTINCTCOUNT(vw_SalesFact[order_id])
Average Order Value = DIVIDE([Net Sales], [Order Count])
Average Discount = AVERAGE(vw_SalesFact[discount])
Average Shipping Days = AVERAGE(vw_SalesFact[shipping_days])
```

## Team Responsibilities

Kaan:

- SQL database setup
- Schema and relationship design
- SQL views and stored procedures
- Import debugging and validation queries
- Report design planning

Emir:

- Windows SQL Server testing
- Power BI Desktop implementation
- Dashboard visuals and formatting
- Final report testing

Shared:

- Data validation
- Power BI model checking
- Presentation and final demo preparation

## Notes for Reviewers or AI Assistants

To understand the project, read the files in this order:

1. `README.md`
2. `sql/01_create_database.sql`
3. `sql/02_create_tables.sql`
4. `sql/03_bulk_insert_data_mac.sql` or `sql/03_bulk_insert_data_win.sql`
5. `sql/04_add_constraints.sql`
6. `sql/05_create_views.sql`
7. `sql/06_create_procedures.sql`
8. `sql/07_validation_queries.sql`

The most important design decision is that Power BI should use the SQL reporting views as the main data source instead of connecting directly to the raw CSV files.
