## Data Cleaning 

SELECT * FROM us_household_income;

SELECT * FROM us_household_income_statistics;

-- Check for duplicates in both tables

SELECT id, COUNT(*)
FROM us_household_income
GROUP BY id 
HAVING COUNT(*) > 1 ;

SELECT ﻿id, COUNT(*)
FROM us_household_income_statistics
GROUP BY ﻿id
HAVING COUNT(*) > 1 ;

-- No Duplicates in _statistics table
-- Need to remove found duplicates in us_household_income table

DELETE FROM us_household_income
WHERE row_id IN (
				SELECT row_id
				FROM ( 
					SELECT row_id
					,id
					,ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
					FROM us_household_income 
					 ) duplicates
				WHERE row_num > 1 ) ;
                
SELECT * FROM us_household_income;

## Focusing on us_household_income table
## Check state_name column 

SELECT DISTINCT state_name, state_code
FROM us_household_income
ORDER BY state_name ;

-- Typo found: 'georia' must be changed to 'Georgia'

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia' ;

-- Standardize state name 'alabama' to 'Alabama'

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama' ;

SELECT * FROM us_household_income;

## Check State_ab column 

SELECT DISTINCT State_ab
FROM us_household_income
ORDER BY State_ab ;

## Check for missing values in County column 

SELECT *
FROM us_household_income
WHERE County IS NULL OR ' ' ;

## Check for missing values in City column 

SELECT *
FROM us_household_income
WHERE City IS NULL OR ' ' ;

## Check for missing values in Place column

SELECT *
FROM us_household_income
WHERE Place IS NULL or ' ' ;

-- 1 result. Populate the NULL value found with another 'Place' value that is most common in the same County

SELECT Place, County, City
FROM us_household_income
WHERE County = 'Autauga County'
ORDER BY Place ;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE COUNTY = 'Autauga County' AND City = 'Vinemont' ;

## Check Type column 

SELECT DISTINCT Type, COUNT(Type)
FROM us_household_income 
GROUP BY Type
ORDER BY Type ;

-- 'Borough' and 'Boroughs' are different values in this column. Need to standardize/remove plurality

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs' ;

## Check Primary column

SELECT DISTINCT `Primary`
FROM us_household_income ;

-- Standardize capitalization in values, convert 'place' to 'Place'

UPDATE us_household_income
SET `Primary` = 'Place'
WHERE `Primary` = 'place' ;

## Check ALand and AWater columns for missing values

SELECT ALand, AWater 
FROM us_household_income
WHERE ALand IN ('0', NULL, ' ') 
	AND AWater IN ('0', NULL, ' ') ;

SELECT ALand, AWater 
FROM us_household_income
WHERE ALand IN (NULL) 
	OR AWater IN ( NULL) ;
    
SELECT *
FROM us_household_income ;

## Check us_household_income_statistics
## Check Mean and Median columns for missing values 

SELECT Mean, COUNT(Mean)
FROM us_household_income_statistics
WHERE Mean IN (0, ' ', NULL)
GROUP BY Mean ;

SELECT Median, COUNT(Median)
FROM us_household_income_statistics
WHERE Median IN (0, ' ', NULL)
GROUP BY Median ;

-- 315 results in both Mean and Median return a value of '0'. 
-- Remove these results because they are of no use when aggregating later.

DELETE FROM us_household_income_statistics
WHERE Median = 0 AND Mean = 0 ;

SELECT *
FROM us_household_income_statistics

## Cleaning Complete 








