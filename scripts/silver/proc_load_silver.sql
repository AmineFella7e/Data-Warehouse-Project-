/*
===============================================================================
Stored Procedure: Load Silver Layer
===============================================================================

Parameters:
    None.

Script Purpose:
    This stored procedure loads transformed and cleaned data into the
    'silver' schema from the Bronze layer.

    It performs the following actions:
        - Truncates the Silver tables before loading data.
        - Cleans and standardizes customer information.
        - Removes duplicate customer records.
        - Transforms product keys and derives category identifiers.
        - Standardizes product line values.
        - Calculates product end dates using the next start date.
        - Converts sales date values into DATE format.
        - Validates and corrects sales and price values.
        - Standardizes customer gender and country information.
        - Removes unnecessary prefixes and characters from identifiers.
        - Displays the total loading duration.
        - Handles and displays errors that may occur during the loading process.

    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;

===============================================================================
*/




CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN   
        DECLARE @batch_start_time DATETIME,@batch_end_time DATETIME;
        BEGIN TRY
            SET @batch_start_time = GETDATE();

            PRINT '=====================================================';
            PRINT 'Loading Silver Layer';
            PRINT '=====================================================';
            -- ====================================================================
            -- Load CRM tables
            -- =====================================================================
            PRINT '-----------------------------------------------------';
            PRINT 'Loading CRM tables';
            PRINT '-----------------------------------------------------';
            
            -- Load: silver.crm_cust_info
            PRINT '>> Truncating Table : crm_cust_info';
            TRUNCATE TABLE silver.crm_cust_info;
            PRINT '>> Inserting Data Into : crm_cust_info';

            INSERT INTO silver.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
            SELECT 
	            cst_id,cst_key,TRIM(cst_firstname) as cst_firstname ,TRIM(cst_lastname) as cst_lastname,
	            Case 
		            When UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		            When UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		            ELSE 'n/a'
	            END AS cst_marital_status,        
	            Case 
		            When UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		            When UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		            ELSE 'n/a'
	            END AS cst_gndr						
	            ,cst_create_date                 
	            FROM (
			            SELECT *,ROW_NUMBER() OVER(PARTITION BY cst_id Order by cst_create_date DESC) as Classement FROM bronze.crm_cust_info 
			            Where cst_id is not null) as SOURCE 
            WHERE Classement=1;


            -- Load: silver.crm_prd_info
            PRINT '>> Truncating Table : crm_prd_info';
            TRUNCATE TABLE silver.crm_prd_info;
            PRINT '>> Inserting Data Into : crm_prd_info';

            INSERT INTO silver.crm_prd_info(prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
            SELECT 
	            prd_id, 
	            REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id ,              
	            SUBSTRING(prd_key,7,len(prd_key)) as prd_key,					 
	            prd_nm,
	            ISNULL(prd_cost,0) as prd_cost ,								
	            CASE UPPER(TRIM(prd_line)) 
		            WHEN 'M' THEN 'Mountain'
		            WHEN 'R' THEN 'Road'
		            WHEN 'S' THEN 'Other Sales'
		            WHEN 'T' THEN 'Touring'
		            ELSE 'n/a'
	            END AS prd_line,												
	            prd_start_dt,
	            DATEADD(DAY,-1,LEAD(prd_start_dt) Over (Partition BY prd_key order by prd_start_dt)) as  prd_end_dt  
            FROM bronze.crm_prd_info;



            -- Load: silver.crm_sales_details
            PRINT '>> Truncating Table : crm_sales_details';
            TRUNCATE TABLE silver.crm_sales_details;
            PRINT '>> Inserting Data Into : crm_sales_details';

            INSERT INTO silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
 
            SELECT sls_ord_num
                  ,sls_prd_key
                  ,sls_cust_id,
                  CASE 
                        WHEN sls_order_dt <=0 or len(sls_order_dt) !=8 THEN NULL
                        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)          
                  END AS sls_order_dt 
                  ,CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) AS sls_ship_dt                   
                  ,CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)  AS sls_due_dt                  
                  ,CASE 
                        WHEN sls_sales <=0 or sls_sales IS NULL OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
                        ELSE sls_sales
                   END AS sls_sales          
                  ,sls_quantity
                  ,CASE 
                        WHEN sls_price IS NULL or sls_price = 0 THEN sls_sales/NULLIF(sls_quantity,0)
                        WHEN sls_price < 0 THEN ABS(sls_price)
                        ELSE sls_price
                   END AS sls_price             

              FROM bronze.crm_sales_details;



            -- ====================================================================
            -- Load ERP tables
            -- =====================================================================
            PRINT '-----------------------------------------------------';
            PRINT 'Loading ERP tables';
            PRINT '-----------------------------------------------------';
            
            -- Load: silver.erp_cust_az12
            PRINT '>> Truncating Table : erp_cust_az12';
            TRUNCATE TABLE silver.erp_cust_az12;
            PRINT '>> Inserting Data Into : erp_cust_az12';

            INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
            SELECT        
                 CASE 
                        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))                  
                        ELSE cid                                                
                 END AS cid,
                CASE 
                    WHEN bdate>= GETDATE() THEN NULL                        
                    ELSE bdate
                END AS bdate ,
                CASE 
                    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                    WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                    ELSE 'n/a'
                END AS gen                                                    
              FROM [bronze].[erp_cust_az12]; 


 
 
            -- Load: silver.erp_loc_a101
            PRINT '>> Truncating Table : erp_loc_a101';
            TRUNCATE TABLE silver.erp_loc_a101;
            PRINT '>> Inserting Data Into : erp_loc_a101';

            INSERT INTO silver.erp_loc_a101(cid,cntry)
            SELECT 
                   REPLACE([cid],'-','') as cid
                  ,CASE 
                        WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
                        WHEN UPPER(TRIM(cntry)) IN('DE','GERMANY') THEN 'Germany'
                        WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'Australia'
                        WHEN UPPER(TRIM(cntry)) = 'UNITED KINGDOM' THEN 'United Kingdom'
                        WHEN UPPER(TRIM(cntry)) = 'FRANCE' THEN 'France'
                        WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'Canada'
                        ELSE 'n/a'
                    END AS cntry
              FROM bronze.erp_loc_a101;




            -- Load: silver.erp_px_cat_g1v2
            PRINT '>> Truncating Table : erp_px_cat_g1v2';
            TRUNCATE TABLE silver.erp_px_cat_g1v2;
            PRINT '>> Inserting Data Into : erp_px_cat_g1v2';

            INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
            SELECT id,cat,subcat,maintenance FROM bronze.erp_px_cat_g1v2
            -- ====================================================================
            -- Completion
            -- ====================================================================

            SET @batch_end_time = GETDATE();

            PRINT '=====================================================';
            PRINT 'Loading Silver Layer is completed';
            PRINT '>> TOTAL Load Duration: '
                + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
                + ' seconds';
            PRINT '=====================================================';
        END TRY

    BEGIN CATCH

        PRINT '-----------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '-----------------------------------------------------';

    END CATCH
END;
