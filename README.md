SQL project to clean and deduplicate layoffs data

# Layoffs Data Cleaning Project (SQL)

This project demonstrates a complete data cleaning workflow using SQL on a global layoffs dataset. The dataset had inconsistencies like duplicate rows, mixed formatting, missing values, and inconsistent categories. The goal was to prepare the data for accurate analysis and visualization.

---

## Dataset Overview

The dataset includes records of layoffs across various companies, with fields such as:

- `company`
- `location`
- `industry`
- `total_laid_off`
- `percentage_laid_off`
- `date`
- `stage`
- `country`
- `funds_raised_millions`

---

##  Tools Used

- MySQL
- SQL (Window Functions, Joins, Updates, Data Type Conversion)
- GitHub

---

## Data Cleaning Steps

```sql
-- STEP 1: Create a staging table

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- STEP 2: Copy data into the staging table

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- STEP 3: Add a unique ID column

ALTER TABLE world_layoffs.layoffs_staging
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- STEP 4: Identify duplicates using window function

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, id) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- STEP 5: Remove duplicates (keep first instance)

WITH CTE AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, id
           ) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE id IN (
    SELECT id FROM CTE WHERE row_num > 1
);

-- STEP 6: Replace empty strings with NULL in `industry`

UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- STEP 7: Fill NULL `industry` using similar company rows

UPDATE layoffs_staging t1
JOIN layoffs_staging t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- STEP 8: Standardize `industry` values (e.g., Crypto variations)

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- STEP 9: Standardize `country` values

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- STEP 10: Convert date format and change column type

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

-- STEP 11: Remove irrelevant rows (where both layoff values are NULL)

DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- STEP 12: Drop helper `id` column

ALTER TABLE layoffs_staging
DROP COLUMN id;

```

# Summary

By applying data cleaning techniques such as removing duplicates, handling missing values, standardizing categorical fields, converting date formats, and filtering irrelevant records, the dataset was transformed into a clean, structured format ready for further exploration and visualization.
