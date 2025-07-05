-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- NOTE: At the time of this project, this dataset contained information from the period when COVID-19 was declared a pandemic, i.e., from "11 March 2020" to "04 June 2025".

-- Preview raw data
SELECT * 
FROM layoffs;

-- Option 1 to create a staging table: Structure-only copy
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging LIKE layoffs;

-- Preview empty staging table
SELECT * FROM layoffs_staging; 

-- Populate staging table with raw data
INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- Option 2 to create a staging table: Structure + data copy
DROP TABLE IF EXISTS layoffs_staging1;
CREATE TABLE layoffs_staging1 
SELECT * 
FROM layoffs;

-- Preview second staging table
SELECT * FROM layoffs_staging1;
 
-- I continued using `layoffs_staging` for the next steps.

-- Step 1: Remove Duplicate Records

-- Since there are no unique identifiers, we create a column using `ROW_NUMBER()` to detect duplicates.

-- First trial using a CTE (Common Table Expression) with fewer columns to test detection logic
-- Note: CTEs are limited to SELECT queries and cannot be used directly with DELETE/UPDATE
WITH duplicate_rows AS
(
 SELECT *, 
 ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
 FROM layoffs
)
SELECT * FROM duplicate_rows 
WHERE row_num > 1;

-- Inspecting a specific company for validation
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

-- All entries appear legitimate; refined the deduplication logic to use *all* columns
WITH duplicate_rows AS
(
 SELECT *, 
 ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
 FROM layoffs_staging
)
SELECT * FROM duplicate_rows 
WHERE row_num > 1;

-- Spot-checking to confirm duplicate logic is correct
SELECT * FROM layoffs_staging WHERE company = 'Beyond Meat';
SELECT * FROM layoffs_staging WHERE company = 'Cazoo';

-- Create a new staging table with an additional row_num column
DROP TABLE IF EXISTS layoffs_staging2;
CREATE TABLE `layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `total_laid_off` TEXT,
  `date` TEXT,
  `percentage_laid_off` TEXT,
  `industry` TEXT,
  `source` TEXT,
  `stage` TEXT,
  `funds_raised` TEXT,
  `country` TEXT,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert deduplicated data with row numbers
INSERT INTO layoffs_staging2
SELECT *, 
 ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
FROM layoffs_staging;

-- Preview the updated staging table
SELECT * FROM layoffs_staging2;

-- Delete true duplicates (row_num > 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Step 2: Standardize Data

-- Preview the cleaned table
SELECT * FROM layoffs_staging2;

-- Trim whitespace and harmonize inconsistent naming
SELECT DISTINCT company FROM layoffs_staging2;
UPDATE layoffs_staging2 SET company = TRIM(company);

-- Standardize 'Crypto' industry label
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;
SELECT * FROM layoffs_staging2 WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- Inspect location and country values for consistency
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;

-- Remove trailing ",Non-U.S." text from location (since country field already exists)
SELECT location, TRIM(TRAILING ',Non-U.S.' FROM location) FROM layoffs_staging2 ORDER BY 1;
-- OR
SELECT location, REPLACE(location, ',Non-U.S.', '') FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 SET location = REPLACE(location, ',Non-U.S.', '');

-- Rename and clean `funds_raised` column
ALTER TABLE layoffs_staging2 RENAME COLUMN funds_raised TO funds_raised_millions;
SELECT funds_raised_millions, REPLACE(funds_raised_millions,'$','') FROM layoffs_staging2 ORDER BY 1;
-- OR
SELECT funds_raised_millions, TRIM(LEADING '$' FROM funds_raised_millions), REPLACE(funds_raised_millions,',','') FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2
SET funds_raised_millions = TRIM(LEADING '$' FROM funds_raised_millions), 
    funds_raised_millions = REPLACE(funds_raised_millions, ',','');

-- Inspect schema
DESCRIBE layoffs_staging2;

-- Convert `date` from string to DATE format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoffs_staging2;
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- Convert `total_laid_off` from text to integer
UPDATE layoffs_staging2 SET total_laid_off = NULL WHERE total_laid_off = '';
ALTER TABLE layoffs_staging2 MODIFY COLUMN total_laid_off INT;

-- Step 3: Handle Missing Values

-- Identify missing industry values
SELECT * FROM layoffs_staging2 WHERE (industry IS NULL OR industry = '');

-- Check whether missing values can be imputed by referencing similar rows
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Appsmith%';
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Airbnb%';
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Amazon%';
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Google%';
SELECT * FROM layoffs_staging2 WHERE company LIKE 'Turo%';

-- Replace blanks with NULLs before imputation
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';

-- Use self-join to populate missing industry from other rows with the same company and location
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL AND t2.industry IS NOT NULL);

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL AND t2.industry IS NOT NULL);


-- Step 4: Remove Irrelevant or Incomplete Rows

-- Replace empty strings with NULLs for layoff metrics
UPDATE layoffs_staging2 SET total_laid_off = NULL WHERE total_laid_off = '';
UPDATE layoffs_staging2 SET percentage_laid_off = NULL WHERE percentage_laid_off = '';

-- Remove rows missing both layoff count and percentage
SELECT * FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Drop helper column used for deduplication
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

-- Final cleaned dataset
SELECT * FROM layoffs_staging2;
