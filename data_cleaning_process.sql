/*
********************************************************************************
DATA CLEANING PROJECT: WORLD LAYOFFS
********************************************************************************
Author: Luanna Delicato
Tool: MySQL Workbench
Description: This script cleans and standardizes a raw dataset of global 
layoffs. The process includes removing duplicates, standardizing data formats, 
handling null values, and optimizing the table schema for analysis.
********************************************************************************
*/

-- 0. Initial Data Exploration
-- Viewing the raw dataset to understand the structure and identify issues.
SELECT * FROM layoffs;

-- 1. STAGING AREA SETUP
-- Creating a staging table to perform cleaning without affecting the raw data source.
CREATE TABLE layoffs_staging 
LIKE layoffs;

-- Populating the staging table with original records.
INSERT layoffs_staging 
SELECT * FROM layoffs;

-- 2. REMOVING DUPLICATES
-- Using a CTE and ROW_NUMBER() to identify identical records across all columns.
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, 
                     funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte 
WHERE row_num > 1;

-- Creating a second staging table to safely delete duplicates, as CTEs are not updatable in some MySQL versions.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data with row numbers to identify duplicates.
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, 
                 percentage_laid_off, `date`, stage, country, 
                 funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Deleting all records where row_num > 1 (confirmed duplicates).
DELETE 
FROM layoffs_staging2 
WHERE row_num > 1;

-- Dropping the auxiliary column used for duplicate identification.
ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;

-- 3. STANDARDIZING DATA
-- Trimming leading and trailing whitespaces from company names.
UPDATE layoffs_staging2 
SET company = TRIM(company);

-- Unifying industry labels (e.g., merging all 'Crypto' variations).
UPDATE layoffs_staging2 
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Cleaning country names (removing trailing periods from 'United States').
UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

-- Converting 'date' column from text to proper DATE format.
UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modifying the column type to native DATE.
ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

-- 4. HANDLING NULL AND BLANK VALUES
-- Converting blank strings in 'industry' to NULL for easier handling.
UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = '';

-- Using a Self-Join to populate missing 'industry' data by matching company and location.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- 5. FINAL CLEANUP
-- Removing records where both total and percentage laid off are null (insufficient data).
DELETE 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Final view of the cleaned dataset.
SELECT * FROM layoffs_staging2;

-- EXPLORATORY DATA ANALYSIS (EDA)

-- 1. Rolling Total of Layoffs per Month
WITH Rolling_Total AS (
  SELECT SUBSTRING(`date`, 1, 7) as month, SUM(total_laid_off) as total_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY month
  ORDER BY 1 ASC
)
SELECT month, total_off, SUM(total_off) OVER(ORDER BY month) as rolling_total
FROM Rolling_Total;

-- 2. Ranking Top 5 Companies with most Layoffs per Year
WITH Company_Year AS (
  SELECT company, YEAR(`date`) as years, SUM(total_laid_off) as total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as ranking
  FROM Company_Year
  WHERE years IS NOT NULL
)
SELECT * FROM Company_Year_Rank WHERE ranking <= 5;
