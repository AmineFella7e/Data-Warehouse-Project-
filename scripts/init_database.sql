/*
===============================================================================
Create Database and Schemas
===============================================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking
    if it already exists.

    If the database exists, it is dropped and recreated.

    The script also creates three schemas corresponding to the three layers
    of the Medallion Architecture:

        bronze  -> Raw data
        silver  -> Cleaned and transformed data
        gold    -> Business-ready analytical data

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it
    already exists.

    All data in the database will be permanently deleted.

    Proceed with caution and ensure you have proper backups before running
    this script.

===============================================================================
*/


-- ============================================================================
-- Drop and recreate the 'DataWarehouse' database
-- ============================================================================

USE MASTER;
GO

IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;

GO


-- ============================================================================
-- Create the 'DataWarehouse' database
-- ============================================================================

CREATE DATABASE DataWarehouse;
GO


-- ============================================================================
-- Use the 'DataWarehouse' database
-- ============================================================================

USE DataWarehouse;
GO


-- ============================================================================
-- Create Medallion Architecture Schemas
-- ============================================================================

-- Bronze: Raw data
CREATE SCHEMA bronze;
GO

-- Silver: Cleaned and transformed data
CREATE SCHEMA silver;
GO

-- Gold: Business-ready analytical data
CREATE SCHEMA gold;
GO
