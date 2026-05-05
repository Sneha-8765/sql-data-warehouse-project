/*
===============================================================================
Procedure Name : bronze.load_bronze
Layer          : Bronze
Purpose        : Load raw source data into Bronze layer staging tables.

Description :
    - Truncates existing Bronze layer tables before loading.
    - Bulk inserts CRM and ERP source CSV files into Bronze tables.
    - Logs load progress and execution duration for each table.
    - Tracks total batch execution time for Bronze layer load.
    - Implements TRY/CATCH error handling for ETL monitoring.

Source Systems :
    - CRM Source Files
        * cust_info.csv
        * prd_info.csv
        * sales_details.csv

    - ERP Source Files
        * CUST_AZ12.csv
        * loc_a101.csv
        * px_cat_g1v2.csv

Execution :
    EXEC bronze.load_bronze;

Warning :
    This procedure truncates all Bronze tables before loading.
    Existing Bronze layer data will be permanently deleted.

Author         : Sneha Gupta
Project        : SQL Data Warehouse Project
===============================================================================
*/
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info
(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12
(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101
(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '==============================================';
        PRINT 'LOADING BRONZE LAYER';
        PRINT '==============================================';

        PRINT '-----------------------------------------------';
        PRINT 'LOADING CRM TABLES';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE :bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT *
        FROM bronze.crm_cust_info;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE :bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT *
        FROM bronze.crm_prd_info;

        SELECT COUNT(*)
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE :bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SELECT *
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        PRINT '-----------------------------------------------';
        PRINT 'LOADING ERP TABLES';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE :bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        SELECT COUNT(*)
        FROM bronze.erp_cust_az12;

        SELECT *
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE :bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        SELECT COUNT(*)
        FROM bronze.erp_loc_a101;

        SELECT *
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> TRUNCATING THE TABLE : bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>>BULK InsertING THE DATA INTOTABLE:bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\SNEHA\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );

        SELECT COUNT(*)
        FROM bronze.erp_px_cat_g1v2;

        SELECT *
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT '>> LOAD DURATION' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-------------------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '=======================================';
        PRINT ' loading bronze layer is completed ';
        PRINT 'TOTAL LOAD DURATION:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '=====================================================';
    END TRY

    BEGIN CATCH
        PRINT '=======================================';
        PRINT ' ERROR OCCURED DURING THE BRONZE LAYER ';
        PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
        PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===========================================;';
    END CATCH
END;

---=====================================================
--- save frequently used sql code in stored procedure
---=================================================================

EXEC bronze.load_bronze;
