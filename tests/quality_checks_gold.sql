/*==============================================================
  GOLD LAYER - QUALITY CHECKS
  ==============================================================
  Script Name : quality_checks_gold.sql
  Layer       : Gold Layer
  Purpose     : Validate data quality, integrity, and consistency
                for Gold Layer views.

  Checks Included:
    1. Fact Table Validation
    2. Foreign Key Integrity Checks
    3. Duplicate Record Checks
    4. Null Value Checks
    5. Dimension Validation
    6. Gender Standardization Validation

  Expected Result:
    - Most validation queries should return ZERO records.
    - Returned records indicate data quality issues.

  ==============================================================*/

USE DataWarehouse;
GO


/*==============================================================
  CHECK 1: VIEW DATA VALIDATION
  ==============================================================
  Purpose:
    Verify data is successfully loaded into fact table.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 1 : FACT SALES DATA VALIDATION';
PRINT '================================================';

SELECT *
FROM gold.fact_sales;
GO


/*==============================================================
  CHECK 2: FOREIGN KEY INTEGRITY - CUSTOMER DIMENSION
  ==============================================================
  Purpose:
    Ensure every customer_key in fact table exists in
    gold.dim_customers.

  Expected Result:
    No records returned.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 2 : CUSTOMER FOREIGN KEY INTEGRITY';
PRINT '================================================';

SELECT
    *
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

WHERE c.customer_key IS NULL;
GO


/*==============================================================
  CHECK 3: FOREIGN KEY INTEGRITY - PRODUCT DIMENSION
  ==============================================================
  Purpose:
    Ensure every product_key in fact table exists in
    gold.dim_product.

  Expected Result:
    No records returned.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 3 : PRODUCT FOREIGN KEY INTEGRITY';
PRINT '================================================';

SELECT
    *
FROM gold.fact_sales f

LEFT JOIN gold.dim_product p
    ON p.product_key = f.product_key

WHERE p.product_key IS NULL;
GO


/*==============================================================
  CHECK 4: DUPLICATE PRODUCT RECORDS
  ==============================================================
  Purpose:
    Ensure no duplicate product records exist in
    gold.dim_product.

  Expected Result:
    No duplicate product_number values.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 4 : DUPLICATE PRODUCT RECORDS';
PRINT '================================================';

SELECT
    product_number,
    COUNT(*) AS total_records

FROM gold.dim_product

GROUP BY product_number

HAVING COUNT(*) > 1;
GO


/*==============================================================
  CHECK 5: DUPLICATE CUSTOMER RECORDS
  ==============================================================
  Purpose:
    Ensure no duplicate customer records exist in
    gold.dim_customers.

  Expected Result:
    No duplicate customer_id values.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 5 : DUPLICATE CUSTOMER RECORDS';
PRINT '================================================';

SELECT
    customer_id,
    COUNT(*) AS total_records

FROM gold.dim_customers

GROUP BY customer_id

HAVING COUNT(*) > 1;
GO


/*==============================================================
  CHECK 6: NULL VALUE CHECK - CUSTOMER DIMENSION
  ==============================================================
  Purpose:
    Identify null values in important customer columns.

  Expected Result:
    Minimal or no NULL values.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 6 : NULL VALUE CHECK - CUSTOMERS';
PRINT '================================================';

SELECT *
FROM gold.dim_customers
WHERE customer_id IS NULL
   OR first_name IS NULL
   OR last_name IS NULL;
GO


/*==============================================================
  CHECK 7: NULL VALUE CHECK - PRODUCT DIMENSION
  ==============================================================
  Purpose:
    Identify null values in important product columns.

  Expected Result:
    Minimal or no NULL values.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 7 : NULL VALUE CHECK - PRODUCTS';
PRINT '================================================';

SELECT *
FROM gold.dim_product
WHERE product_id IS NULL
   OR product_name IS NULL;
GO


/*==============================================================
  CHECK 8: NULL VALUE CHECK - FACT SALES
  ==============================================================
  Purpose:
    Identify missing measure values in fact table.

  Expected Result:
    No NULL measure values.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 8 : NULL VALUE CHECK - FACT SALES';
PRINT '================================================';

SELECT *
FROM gold.fact_sales
WHERE sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL;
GO


/*==============================================================
  CHECK 9: GENDER STANDARDIZATION VALIDATION
  ==============================================================
  Purpose:
    Verify standardized gender values after transformation.

  Expected Result:
    Standardized gender values only.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 9 : GENDER STANDARDIZATION';
PRINT '================================================';

SELECT DISTINCT
    gender
FROM gold.dim_customers;
GO


/*==============================================================
  CHECK 10: SOURCE VS TRANSFORMED GENDER VALIDATION
  ==============================================================
  Purpose:
    Compare CRM gender, ERP gender, and final transformed
    gender values.

==============================================================*/

PRINT '================================================';
PRINT 'CHECK 10 : SOURCE VS FINAL GENDER';
PRINT '================================================';

SELECT DISTINCT

    ci.cst_gndr AS crm_gender,

    ca.gen AS erp_gender,

    CASE
        -- CRM is the master source for gender information
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS final_gender

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid

ORDER BY 1,2;
GO


/*==============================================================
  CHECK 11: SOURCE TABLE SAMPLE DATA VALIDATION
  ==============================================================
  Purpose:
    Preview source data used in customer dimension creation.
==============================================================*/

PRINT '================================================';
PRINT 'CHECK 11 : SOURCE TABLE PREVIEW';
PRINT '================================================';

SELECT TOP 10 *
FROM silver.crm_cust_info;

SELECT TOP 10 *
FROM silver.erp_loc_a101;

SELECT TOP 10 *
FROM silver.erp_cust_az12;
GO
