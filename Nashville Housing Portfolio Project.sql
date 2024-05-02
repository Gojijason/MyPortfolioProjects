/* 

This project was done with Microsoft SQL Server and displays the beginning of a data cleaning process for a Nashville Housing datatset provided by Alex Freberg:
https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
NOTE: this is NOT an end to end project, but simply a showcase of data cleaning skills. Let's Begin :)

*/

-- Look at the data we are going to be working with
	 
SELECT *
FROM NashvilleHousing

-- After noticing the data type in the SaleDate column, we convert it into a 'DATE' format instead of 'DATETIME' using ALTER TABLE and ALTER COLUMN.

SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	
-- Populate NULL PropertyAddress values by using a self join. 

/* 

The dataset contained some nearly duplicate rows, where the only difference was the UniqueID. That being said, we can see in these rows that the PropertyAddress was NULL
in one, while its' duplicate had an Address written in the column. So, we join our table with itself ON ParcelID being equal with the condition that the UniqueID is not equal. 

*/


SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- Use ISNULL to return a new column where if the property address IS NULL in table a, fill it with the values of PropertyAddress in table b. 
	
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------

-- Breaking down the PropertyAddress to make 2 different columns(Address, City)

SELECT PropertyAddress
FROM NashvilleHousing

-- CHARINDEX to return a variable of the place in which the ',' character is located within the strings of each PropertyAddress value.
-- (-1 because this function counts the place in front of our desired character)
	
SELECT CHARINDEX(',', PropertyAddress) -1
FROM NashvilleHousing

-- LEFT function to return the left part of the column, the cutoff being the CHARINDEX variable above, which gives us the address.
-- SUBSTRING function to return the right part of the column, starting from the CHARINDEX variable and the cutoff as the length of the value in the PropertyAddress. Gives city.
SELECT LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) Address ,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 2, LEN(PropertyAddress)) City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(250)

UPDATE NashvilleHousing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(250)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 2, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------
	
-- Breaking down the OwnerAddress to make 3 different columns(Address, City, State)

SELECT OwnerAddress
FROM NashvilleHousing

-- REPLACE function to replace ',' with '.'. Can now use PARSENAME function to split the value in column by the '.' delimiter into new columns. 
-- Return new columns in order of Address, City, and State by ordering by descending (3,2,1), which are the now split parts of the string in the column. 

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(250)

UPDATE NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(250)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(10)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------

-- Make uniform the SoldAsVacant values as a YES or NO. (N or Y is not acceptable in this case)

SELECT SoldAsVacant
FROM NashvilleHousing

SELECT SoldAsVacant
FROM NashvilleHousing
WHERE SoldAsVacant <> 'Yes' AND SoldAsVacant <> 'No'

-- CASE statement to make 'N' values into 'No' and 'Y' values into 'Yes', while keeping the rest of the column the same. 

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END 
FROM NashvilleHousing
WHERE SoldAsVacant = 'N' OR SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END 

SELECT * 
FROM NashvilleHousing

---------------------------------------------------------------------------------

-- Remove Duplicate rows
	
/*

ROW_NUM function to number rows in ASC order wherever the listed columns in query below have the exact same values(a duplicate row). Any duplicate row will be assigned the
row number '2', or if multiple duplicates then '3', '4' & so on. When rows do not have the same values, they are only numbered '1' and starts over as '1' again. 

*/

SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY   ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID) row_num
FROM NashvilleHousing
ORDER BY ParcelID

-- Using a CTE table we are going to effectively delete the duplicates.
-- NOTICE this query returns 104 rows. So, there are 104 duplicate rows.

WITH duplicate_rowsCTE AS
(SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY   ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID) row_num
FROM NashvilleHousing )

SELECT *
FROM duplicate_rowsCTE
WHERE row_num > 1

-- Remove duplicate rows CONTINUED , with a CTE table. 

WITH duplicate_rowsCTE AS
(SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY   ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID) row_num
FROM NashvilleHousing )

DELETE
FROM duplicate_rowsCTE
WHERE row_num > 1

-- NOTICE, query below returns 56,373 rows. We have successfully deleted the 104 duplicte rows
	
SELECT *
FROM NashvilleHousing
ORDER BY SalePrice

--------------------------------------------------------------------------------------------------------------------

-- Remove unused columns from table

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict

-----------------------------------------------------

-- All Done. 






