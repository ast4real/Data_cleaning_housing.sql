
-- Data Cleaning Project: Housing Data in SQL Server

-- Step 1: Create Table (Sample Schema)
CREATE TABLE HousingData (
    Id INT PRIMARY KEY,
    SaleDate NVARCHAR(50),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    Bedrooms INT,
    Bathrooms FLOAT,
    Price NVARCHAR(50),
    LotSize NVARCHAR(50),
    SquareFeet NVARCHAR(50)
);

-- Step 2: Convert SaleDate to Standard Format
ALTER TABLE HousingData
ADD SaleDate_Formatted DATE;

UPDATE HousingData
SET SaleDate_Formatted = TRY_CAST(SaleDate AS DATE);

-- Step 3: Standardize City and State Casing
UPDATE HousingData
SET City = UPPER(LTRIM(RTRIM(City))),
    State = UPPER(LTRIM(RTRIM(State)));

-- Step 4: Remove Special Characters
UPDATE HousingData
SET Price = REPLACE(REPLACE(Price, '$', ''), ',', ''),
    LotSize = REPLACE(LotSize, ' acres', ''),
    SquareFeet = REPLACE(SquareFeet, ' sqft', '');

-- Step 5: Convert to Proper Data Types
ALTER TABLE HousingData
ADD Price_Int INT,
    LotSize_Float FLOAT,
    SquareFeet_Int INT;

UPDATE HousingData
SET Price_Int = TRY_CAST(Price AS INT),
    LotSize_Float = TRY_CAST(LotSize AS FLOAT),
    SquareFeet_Int = TRY_CAST(SquareFeet AS INT);

-- Step 6: Remove Duplicates
WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Address, City, State, ZipCode, Bedrooms, Bathrooms, Price
               ORDER BY Id
           ) AS rn
    FROM HousingData
)
DELETE FROM CTE_Duplicates
WHERE rn > 1;

-- Step 7: Remove Invalid Rows
DELETE FROM HousingData
WHERE Address IS NULL OR City IS NULL OR SaleDate_Formatted IS NULL;

-- Step 8: Drop Unused Columns
ALTER TABLE HousingData
DROP COLUMN SaleDate, Price, LotSize, SquareFeet;

-- Step 9: Rename Cleaned Columns
EXEC sp_rename 'HousingData.SaleDate_Formatted', 'SaleDate', 'COLUMN';
EXEC sp_rename 'HousingData.Price_Int', 'Price', 'COLUMN';
EXEC sp_rename 'HousingData.LotSize_Float', 'LotSize', 'COLUMN';
EXEC sp_rename 'HousingData.SquareFeet_Int', 'SquareFeet', 'COLUMN';
