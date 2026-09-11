/*
===============================================================================
Stored Procedure: Load Bronze Layer
===============================================================================

Parameters:
    None.

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external
    CSV files.

    It performs the following actions:
        - Truncates the Bronze tables before loading data.
        - Uses the BULK INSERT command to load data from CSV files into
          the Bronze tables.
        - Displays the loading duration for each table.
        - Displays the total loading duration for the Bronze layer.
        - Handles and displays errors that may occur during the loading process.

    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '=====================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=====================================================';


        -- ====================================================================
        -- Load CRM tables
        -- ====================================================================

        PRINT '-----------------------------------------------------';
        PRINT 'Loading CRM tables';
        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.crm_cust_info
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.crm_prd_info
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.crm_sales_details
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- ====================================================================
        -- Load ERP tables
        -- ====================================================================

        PRINT '-----------------------------------------------------';
        PRINT 'Loading ERP tables';
        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.erp_cust_az12
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.erp_loc_a101
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- --------------------------------------------------------------------
        -- Load: bronze.erp_px_cat_g1v2
        -- --------------------------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating: bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\HP\Documents\Projects\Data Projects\SQL-DW1\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- ====================================================================
        -- Completion
        -- ====================================================================

        SET @batch_end_time = GETDATE();

        PRINT '=====================================================';
        PRINT 'Loading Bronze Layer is completed';
        PRINT '>> TOTAL Load Duration: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '=====================================================';


    END TRY

    BEGIN CATCH

        PRINT '-----------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '-----------------------------------------------------';

    END CATCH

END;
