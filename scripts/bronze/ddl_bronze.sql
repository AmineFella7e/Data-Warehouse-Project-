/*
===============================================================================
DDL - Bronze Layer
===============================================================================

Script Purpose:
    This script creates the tables required for the Bronze layer of the
    Data Warehouse.

    The Bronze layer stores raw data as received from the source systems,
    with minimal transformations.

    DDL (Data Definition Language) is used to define and modify the structure
    of database objects such as tables, schemas, and views.

    Each table is dropped if it already exists and then recreated.

WARNING:
    Dropping an existing table will permanently delete all data stored in it.

===============================================================================
*/


-- ============================================================================
-- CRM: Customer Information
-- ============================================================================

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
GO


-- ============================================================================
-- CRM: Product Information
-- ============================================================================

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost FLOAT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO


-- ============================================================================
-- CRM: Sales Details
-- ============================================================================

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales FLOAT,
    sls_quantity INT,
    sls_price FLOAT
);
GO


-- ============================================================================
-- ERP: Customer Information
-- ============================================================================

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);
GO


-- ============================================================================
-- ERP: Location Information
-- ============================================================================

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO


-- ============================================================================
-- ERP: Product Category Information
-- ============================================================================

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
