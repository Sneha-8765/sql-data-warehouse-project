/*
===============================================================================
Script Name : bronze_layer_table_creation.sql
Layer       : Bronze
Purpose     : Create raw ingestion tables for Bronze layer source data.

Description :
    - Drops existing Bronze tables if they already exist.
    - Recreates Bronze layer tables for CRM and ERP source systems.
    - Defines raw staging schema structure for initial data ingestion.
    - Used during environment setup / schema reset for ETL pipeline.

Warning :
    Executing this script will DROP existing Bronze tables and all stored data.
    Run only in development or when a full Bronze layer reset is intended.

Author      : Sneha Gupta
Project     : SQL Data Warehouse Project
===============================================================================
*/

 if OBJECT_ID ('bronze.crm_cust_info', 'U') is not null 
 DROP Table bronze.crm_cust_info;
CREATE  TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname  NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date Date 


); 
if OBJECT_ID ('bronze.crm_prd_info', 'U') is not null 
 DROP Table bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT
	,prd_key NVARCHAR(50)
	,prd_nm  NVARCHAR(50),
	prd_cost  INT,
	prd_line NVARCHAR(50),
	prd_start_dt Datetime,
	prd_end_dt datetime 
);
if OBJECT_ID ('bronze.crm_sales_details', 'U') is not null 
 DROP Table bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	 sls_ord_num NVARCHAR(50) 
	 ,sls_prd_key NVARCHAR(50),
	 sls_cust_id INT,
	 sls_order_dt INT ,
	 sls_ship_dt INT ,

	 sls_due_dt INT ,
	 sls_sales INT  ,
	 sls_quantity INT  ,
	 sls_price INT 
)
if OBJECT_ID ('bronze.erp_cust_az12', 'U') is not null 
 DROP Table bronze.erp_cust_az12;
CREATE  TABLE bronze.erp_cust_az12(
   cid NVARCHAR(50),
  bdate Date ,
  gen NVARCHAR(50)
);
if OBJECT_ID ('bronze.erp_loc_a101', 'U') is not null 
 DROP Table bronze.erp_loc_a101;
CREATE  TABLE bronze.erp_loc_a101(
  cid NVARCHAR(50),
  cntry NVARCHAR(50)

);
if OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') is not null 
 DROP Table bronze.erp_px_cat_g1v2;
CREATE  TABLE bronze.erp_px_cat_g1v2(
   id  NVARCHAR(50),
   cat NVARCHAR(50),
   subcat NVARCHAR(50),
   maintenance NVARCHAR(50)
);
