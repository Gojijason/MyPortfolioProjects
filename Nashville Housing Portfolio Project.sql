SELECT *
FROM NashvilleHousing


-- Convert SaleDate column into DATE format instead of DATETIME.

SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- Populate NULL PropertyAddress values by using a self join. 
-- Dataset included nearly duplicate rows except for UniqueID, in which PropertyAddresses were filled where said near duplicate has a NULL.

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

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

-- Breaking down the PropertyAddress to make 2 different columns(Address, City)


SELECT PropertyAddress
FROM NashvilleHousing

SELECT CHARINDEX(',', PropertyAddress) -1
FROM NashvilleHousing

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

-- Breaking down the OwnerAddress to make 3 different columns(Address, City, State)

SELECT OwnerAddress
FROM NashvilleHousing

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

-- Uniform SoldAsVacant values as a YES or NO. (N or Y is not acceptable in this case)

SELECT SoldAsVacant
FROM NashvilleHousing

SELECT SoldAsVacant
FROM NashvilleHousing
WHERE SoldAsVacant <> 'Yes' AND SoldAsVacant <> 'No'

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

-- Remove Duplicate rows, NOTICE the second query below returns 104 rows. There are 104 duplicate rows.

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

-- NOTICE, query below returns 56,373 rows. We deleted the 104 duplicte rows
SELECT *
FROM NashvilleHousing
ORDER BY SalePrice

-- Remove unused columns from table

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict









