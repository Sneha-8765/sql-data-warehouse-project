-- ============================================================
-- Procedure Name : proc_load_silver.sql
-- ============================================================
-- Purpose:
--     Loads data from Bronze layer into Silver layer by applying
--     cleansing, standardization, deduplication, validation,
--     and transformation rules.
--
--     This procedure performs full refresh loading by truncating
--     Silver tables and reloading transformed data from Bronze.
--
-- Transformations Performed:
--     - Removes duplicate customer records
--     - Standardizes gender and marital status values
--     - Cleans product/category keys
--     - Derives product end dates using LEAD()
--     - Validates and converts malformed sales dates
--     - Recalculates invalid sales/price values
--     - Standardizes ERP customer gender values
--     - Standardizes country names/codes
--     - Logs load duration for each table
--     - Handles runtime errors using TRY/CATCH
--
-- Parameters:
--     None
--
-- Returns:
--     None
--
-- Usage:
--     EXEC silver.load_silver;
--
-- Requirements:
--     - Bronze layer tables must exist and contain data
--     - Silver layer tables must be created beforehand
--     - User must have:
--         * EXECUTE permission on procedure
--         * INSERT / TRUNCATE permission on Silver schema tables
--         * SELECT permission on Bronze schema tables
--
-- Load Type:
--     Full Refresh
--
-- Author:
--     Sneha Gupta
--
-- Project:
--     SQL Data Warehouse / ETL Pipeline
-- ============================================================

EXEC silver.load_silver;

create or alter procedure silver.load_silver AS
BEGIN
DECLARE @start_time datetime ,@end_time datetime,@batch_start_time datetime , @batch_end_time datetime ;
 BEGIN  TRY 
        set @batch_start_time = GETDATE();
		PRINT '==============================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '==============================================';
   
	   PRINT '-----------------------------------------------';
	   PRINT 'LOADING CRM TABLES';
	   PRINT '------------------------------------------------';
        set @start_time= GETDATE();
	PRINT '>> TRUNCATING TABLE : silver.crm_cust_info';
	 TRUNCATE TABLE silver.crm_cust_info;
	 PRINT '>> Inserting Data into :silver.crm_cust_info';
	 INSERT INTO silver.crm_cust_info(
	 cst_id,
	 cst_key,
	 cst_firstname,
	 cst_lastname,
 
	 cst_gndr,
	 cst_marital_status,
	 cst_create_date
	)
	select cst_id,
	cst_key,
	 trim(cst_firstname) as cst_first_name ,
	 trim (cst_lastname) as cst_lastname,

	case  
	 when upper(trim(cst_gndr)) ='F' then 'Female'
	 when  upper(trim(cst_gndr))='M' then 'Male'
	 else 'n/a'
	 end cst_gndr,--normalize customer gender  to human readable format 
	 case  
	 when upper(trim(cst_marital_status)) ='S' then 'Single'
	 when  upper(trim(cst_marital_status))='M' then 'Married'
	 else 'n/a'
	 end cst_marital_status,-- normalize marital status to human readable format 
	cst_create_date
	from (SELECT *,
			   ROW_NUMBER() OVER (
				   PARTITION BY cst_id
				   ORDER BY cst_create_date
			   ) AS flag_last
		FROM bronze.crm_cust_info
	) t
	WHERE flag_last = 1
	  AND cst_id IS NOT NULL;
	  set @end_time=GETDATE();
		 PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------'

		   set @start_time= GETDATE();


	PRINT '>> TRUNCATING TABLE : silver.crm_prd_info';
	 TRUNCATE TABLE silver.crm_prd_info;
	 PRINT '>> Inserting Data into :silver.crm_prd_info';
	insert into silver.crm_prd_info(

	 prd_id,
 
	 cat_id,
	 prd_key,
	 prd_nm,
	 prd_cost,
	 prd_line,
	 prd_start_dt,
	 prd_end_dt
	)
	 select prd_id,
 
	  REPLACE (SUBSTRING(prd_key,1, 5),'-' , '_') AS cat_id, -- extract category id 
	  SUBSTRING(prd_key , 7 , len(prd_key)) as prd_key,-- extract product key
	 prd_nm,
	 isnull(prd_cost, 0) as prd_cost,-- handle the nulls 
 
	 case upper(trim(prd_line))
		  when  'M' then 'Mountain'
		  when  'R' then 'Road'
		  when 'S' then 'otherSales'
		  when  'T' then 'Touring'
		  else 'n/a'-- handle the missing or not availble value 
		  end  as prd_line, -- map product line codes to descriptive values
	 cast(prd_start_dt as date) as prd_start_dt,
	 cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1  as DATE) 
	 as prd_end_dt -- calculate end date as one day before the next startdate
	 -- done date enrichment 
	 from bronze.crm_prd_info
	 set @end_time= GETDATE();
		  PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------'

		    set @start_time= GETDATE();

	 PRINT '>> TRUNCATING TABLE : silver.crm_sales_details';
	 TRUNCATE TABLE silver.crm_sales_details;
	 PRINT '>> Inserting Data into :ilver.crm_sales_details';
	insert into silver.crm_sales_details(
	  sls_ord_num,
	  sls_prd_key,
	  sls_cust_id,
	  sls_order_dt,
	  sls_ship_dt,
	  sls_due_dt,
	  sls_sales,
	  sls_quantity,
	  sls_price

	 )

	select  
	  sls_ord_num,
	 sls_prd_key,
	 sls_cust_id,
	 case 
		when sls_order_dt =0 or len(sls_order_dt)!= 8 then null 
		else cast( cast(sls_order_dt as varchar) as date)
	  end sls_order_dt,
	  case 
		when sls_ship_dt =0 or len(sls_ship_dt)!= 8 then null 
		else cast( cast(sls_ship_dt as varchar) as date)
	  end sls_ship_dt,
	  case 
		when sls_due_dt =0 or len(sls_due_dt)!= 8 then null 
		else cast( cast(sls_due_dt as varchar) as date)
	  end
	sls_due_dt,
	case 
	 when sls_sales is  null or sls_sales<=0
	 or sls_sales!= sls_quantity* abs(sls_price)
	 then sls_quantity* abs(sls_price)
	 else sls_sales-- recalculate the sales if the original value is missing or incorrect
	 END  AS 
	sls_sales,
	sls_quantity,
	case when sls_price is Null or sls_price <= 0 
	then sls_sales/nullif(sls_quantity,0)
	else sls_price

	 end as sls_price-- derive price if the original value is invalid 
	from bronze.crm_sales_details
	set @end_time= GETDATE();	
	PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------';
	PRINT '-----------------------------------------------';
	   PRINT 'LOADING ERP TABLES';
	   PRINT '------------------------------------------------';
        
		set @start_time= GETDATE();
	PRINT '>> TRUNCATING TABLE : silver.erp_cust_az12';
	 TRUNCATE TABLE silver.erp_cust_az12;
	 PRINT '>> Inserting Data into :silver.erp_cust_az12';
	insert into silver.erp_cust_az12(
	   cid,
	   bdate,
	   gen
	   )
	SELECT 
		CASE  
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid 
		END AS cid,

		CASE 
			WHEN bdate > GETDATE() THEN NULL 
			ELSE bdate 
		END AS bdate,

		CASE  
			WHEN UPPER(
				TRIM(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(gen, CHAR(9), ''),   -- tab
							CHAR(10), ''),                  -- line feed
						CHAR(13), ''),                     -- carriage return
					CHAR(160), '')                         -- non-breaking space
				)
			) IN ('F', 'FEMALE') THEN 'Female'

			WHEN UPPER(
				TRIM(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(gen, CHAR(9), ''),
							CHAR(10), ''),
						CHAR(13), ''),
					CHAR(160), '')
				)
			) IN ('M', 'MALE') THEN 'Male'

			ELSE 'n/a'
		END AS gen

	FROM bronze.erp_cust_az12;
	set @end_time= GETDATE();

		PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------';

		 set @start_time= GETDATE();


	PRINT '>> TRUNCATING TABLE : silver.erp_loc_a101';
	 TRUNCATE TABLE silver.erp_loc_a101;
	 PRINT '>> Inserting Data into :silver.erp_loc_a101';
	insert into silver.erp_loc_a101( cid,cntry)

	select  replace (cid ,'-','') cid,

	 CASE
		WHEN UPPER(
			TRIM(
				REPLACE(REPLACE(REPLACE(REPLACE(cntry,CHAR(9),''),CHAR(10),''),CHAR(13),''),CHAR(160),'')
			)
		) IN ('US','USA','UNITED STATES') THEN 'United States'

		WHEN UPPER(
			TRIM(
				REPLACE(REPLACE(REPLACE(REPLACE(cntry,CHAR(9),''),CHAR(10),''),CHAR(13),''),CHAR(160),'')
			)
		) = 'DE' THEN 'Germany'

		ELSE TRIM(cntry)-- normalize and standardize the blank country codes 
	END as cntry

	from bronze.erp_loc_a101 ;
	set @end_time= GETDATE();
		PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------';


		 set @start_time= GETDATE();
  

	 PRINT '>> TRUNCATING TABLE : silver.erp_px_cat_g1v2';
	 TRUNCATE TABLE silver.erp_px_cat_g1v2;
	 PRINT '>> Inserting Data into :silver.erp_px_cat_g1v2';
	 insert into silver.erp_px_cat_g1v2( id,cat,subcat,maintenance)
	select 
	id,cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2;
	set @end_time= GETDATE();

		PRINT'>> LOAD DURATION' + CAST(DATEDIFF(second,@start_time , @end_time) as NVARCHAR) + 'seconds';
		 PRINT '-------------------------------------------------';

		 set @batch_end_time = GETDATE();
		 PRINT'=======================================';
		 PRINT' loading SILVER layer is completed ';
		 PRINT 'TOTAL LOAD DURATION:' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) as NVARCHAR) + 'seconds';
		 PRINT '=====================================================';
 END TRY
 BEGIN CATCH
  PRINT '=======================================';
  PRINT' ERROR OCCURED DURING THE SILVER LAYER ';
  PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
  PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
  PRINT '===========================================;'
 END CATCH
END
