-- ============================================================
-- Script Name : Database and Schema Initialization
-- Author      : Sneha Gupta
-- Project     : SQL Data Warehouse Project
-- Description : Drops existing DataWarehouse database (if found),
--               recreates it, and initializes bronze/silver/gold
--               schemas for layered data warehouse architecture.
-- Created On  : 2026-05-04
-- SQL Server  : Microsoft SQL Server
--
-- WARNING     : This script will permanently delete the existing
--               DataWarehouse database if it already exists.
--               All stored data, tables, procedures, and objects
--               inside the database will be lost.
--               Use only in development/testing environments.
--               proceed with caution and ensure you have proper backups before running this scripts 
-- ============================================================


USE master;
GO

-- Drop database if it exists
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN
    DROP DATABASE DataWarehouse;
END
GO

-- Recreate database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Recreate schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
