Data Catalog – Gold Layer
Overview

The Gold Layer contains business-ready, analytics-optimized data models designed for reporting, dashboards, and business intelligence purposes.
It follows a Star Schema approach with:

Dimension Tables → descriptive business entities
Fact Tables → transactional/measurable business events 
**1. gold.dim_customers
Purpose

The gold.dim_customers view stores customer-related descriptive information used for customer analytics, segmentation, demographic analysis, and sales reporting.

It combines customer data from:

CRM Customer Information
ERP Customer Demographics
ERP Location Information

This dimension is used by the gold.fact_sales table.
| Column Name       | Description                                      | Example      |
| ----------------- | ------------------------------------------------ | ------------ |
| `customer_key`    | Surrogate key generated for each customer record | `1`          |
| `customer_id`     | Unique customer identifier from CRM system       | `1001`       |
| `customer_number` | Business/customer reference number               | `AW00011000` |
| `first_name`      | Customer first name                              | `Sneha`      |
| `last_name`       | Customer last name                               | `Gupta`      |
| `country`         | Customer country/location                        | `India`      |
| `marital_status`  | Marital status of customer                       | `Single`     |
| `gender`          | Customer gender from CRM or ERP source           | `Female`     |
| `birthdate`       | Customer date of birth                           | `2003-05-14` |
| `create_date`     | Date customer record was created                 | `2023-01-10` |

**2. gold.dim_product
Purpose

The gold.dim_product view stores product-related descriptive information used for:

Product performance analysis
Category-wise sales reporting
Inventory and pricing analysis
Product hierarchy analysis

Only active products are included (prd_end_dt IS NULL).

SQL Logic Summary
Generates surrogate product keys
Joins product information with category details
Filters only active/current products
Organizes products into categories and subcategories

| Column Name      | Description                              | Example          |
| ---------------- | ---------------------------------------- | ---------------- |
| `product_key`    | Surrogate key generated for each product | `101`            |
| `product_id`     | Unique product identifier                | `P100`           |
| `product_number` | Business product code                    | `BK-M68B-42`     |
| `product_name`   | Product name                             | `Mountain Bike`  |
| `category_id`    | Product category identifier              | `10`             |
| `category`       | Product category                         | `Bikes`          |
| `subcategory`    | Product subcategory                      | `Mountain Bikes` |
| `maintenance`    | Maintenance classification/details       | `Yes`            |
| `cost`           | Product cost value                       | `45000`          |
| `product_line`   | Product line classification              | `Mountain`       |
| `start_day`      | Product availability start date          | `2024-01-01`     |
***3. gold.fact_sales
Purpose

The gold.fact_sales table stores transactional sales data and acts as the central fact table in the star schema.

It is used for:

Revenue analysis
Sales trend analysis
Customer purchase analysis
Product performance reporting
KPI dashboards

The table connects:

Customers (gold.dim_customers)
Products (gold.dim_product)
SQL Logic Summary
Maps customer and product surrogate keys
Stores transactional sales measures
Captures order lifecycle dates
Enables analytical reporting 

| Column Name     | Description                           | Example      |
| --------------- | ------------------------------------- | ------------ |
| `order_number`  | Unique sales order number             | `SO54496`    |
| `product_key`   | Foreign key from `gold.dim_product`   | `101`        |
| `customer_key`  | Foreign key from `gold.dim_customers` | `1`          |
| `order_date`    | Date order was placed                 | `2025-02-01` |
| `shipping_date` | Date order was shipped                | `2025-02-03` |
| `due_date`      | Expected delivery/due date            | `2025-02-07` |
| `sales_amount`  | Total sales amount                    | `52000`      |
| `quantity`      | Quantity sold                         | `2`          |
| `price`         | Unit selling price                    | `26000`      |
