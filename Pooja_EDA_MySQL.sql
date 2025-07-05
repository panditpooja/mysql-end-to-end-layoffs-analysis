-- Exploratory Data Analysis

-- layoffs_staging2: Cleaned and standardized version of the layoffs dataset used for all exploratory data analysis.
SELECT * 
FROM layoffs_staging2;

-- Section 1: Dataset Overview

-- Finding the tenure of the dataset (earliest and latest dates)
SELECT MIN(`date`) AS min_date, MAX(`date`) AS max_date
FROM layoffs_staging2;
-- Results: min_date: 2020-03-11, max_date: 2025-06-04

-- Find companies that laid off 100% of employees.
-- Display the results ordered by highest funds raised.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Section 2: Layoff Magnitudes

-- Top 5 companies with the biggest single-day layoffs
SELECT company, total_laid_off
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 5;

-- Top 10 companies with the most total layoffs over the dataset's entire time range
SELECT company, SUM(total_laid_off) AS Total_Layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Section 3: Industry & Location

-- List the top 10 industries with the highest layoffs during the dataset's tenure
SELECT industry, SUM(total_laid_off) AS Total_Layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10;

-- List the top 10 locations with the highest layoffs
SELECT location, SUM(total_laid_off) AS Total_Layoffs
FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- List the top 10 countries with the highest layoffs
SELECT country, SUM(total_laid_off) AS Total_Layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;

-- Section 4: Temporal Trends by Year

-- Aggregate total layoffs by year, ordered from most recent to oldest
SELECT YEAR(`date`) AS layoff_year, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- Identify the company with the highest total layoffs for each year
WITH per_year_company_total AS (
  -- Step 1: Get total layoffs per company per year
  SELECT YEAR(`date`) AS layoff_year, company, SUM(total_laid_off) AS total_layoff
  FROM layoffs_staging2
  GROUP BY 1,2
),
company_rank AS (
  -- Step 2: Rank companies by layoffs within each year
  SELECT layoff_year, company, total_layoff,
         RANK() OVER(PARTITION BY layoff_year ORDER BY total_layoff DESC) AS rank_val
  FROM per_year_company_total
)
-- Step 3: Filter to keep only the top-ranked company per year
SELECT layoff_year, company, total_layoff
FROM company_rank 
WHERE rank_val = 1;

-- List the top 5 companies with the highest layoffs per year
WITH per_year_company_total AS (
  SELECT YEAR(`date`) AS layoff_year, company, SUM(total_laid_off) AS total_layoff
  FROM layoffs_staging2
  GROUP BY 1,2
),
company_rank AS (
  SELECT layoff_year, company, total_layoff,
         DENSE_RANK() OVER(PARTITION BY layoff_year ORDER BY total_layoff DESC) AS rank_val
  FROM per_year_company_total
)
SELECT *
FROM company_rank 
WHERE rank_val < 6;

-- Section 5: Rolling Monthly Layoffs

-- Rolling total of layoffs per month within each year
WITH per_year_month_total_layoff AS (
  -- Step 1: Aggregate layoffs by year and month
  SELECT YEAR(`date`) AS layoff_year, MONTH(`date`) AS layoff_month, SUM(total_laid_off) AS total_layoff
  FROM layoffs_staging2
  GROUP BY 1,2
),
rolling_total_per_month_year AS (
  -- Step 2: Compute rolling sum of layoffs over months within each year
  SELECT layoff_year, layoff_month, total_layoff,
         SUM(total_layoff) OVER(PARTITION BY layoff_year ORDER BY layoff_month) AS rolling_total
  FROM per_year_month_total_layoff
)
SELECT *
FROM rolling_total_per_month_year;
