- Add a unique ID column to help safely delete duplicates

ALTER TABLE world_layoffs.layoffs_staging
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- View all data in the staging table

SELECT * 
FROM world_layoffs.layoffs_staging;

-- View potential duplicates (rows with the same key data)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, id
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Remove duplicate rows, keeping only the first occurrence

WITH CTE AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, id
           ) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE id IN (
    SELECT id 
    FROM CTE 
    WHERE row_num > 1
);

	-- Confirm duplicates have been removed (should return 0 rows)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage, country, funds_raised_millions, id
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;
