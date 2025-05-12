		-- 2. Standardize Data

SELECT * 
FROM world_layoffs.layoffs_staging;

		-- there are some nulls and empty values in the industry

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging
ORDER BY industry ASC;

SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry ASC;

			-- Let's check randomly

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with

UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values

SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging
ORDER BY industry ASC;

-- Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- check results

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging
ORDER BY industry ASC;

-- --------------------------------------------------
-- Let's check other columns

SELECT *
FROM world_layoffs.layoffs_staging;

-- everything looks good except in country apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging
ORDER BY country ASC;

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- now if we run this again it is fixed

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging
ORDER BY country;


-- Let's also fix the date columns:

SELECT *
FROM world_layoffs.layoffs_staging;

-- we can use str to date to update this field

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly

ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_staging;


		-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


		-- 4. remove any columns and rows we need to

SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data. We will delete the rows where both the total_laid_off and percentage_laid_off are null

DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging;

-- we created the id column for removing duplicates - We don't need it anymore so we will delete that as well.

ALTER TABLE layoffs_staging
DROP COLUMN id;

SELECT * 
FROM world_layoffs.layoffs_staging;

-- The data is now clean and ready 
