-- Create a staging table (a working copy of the original table)

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- Copy data from the original table into the staging table

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;
