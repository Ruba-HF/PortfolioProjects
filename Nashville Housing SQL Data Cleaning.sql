/*

CLEANING DATA IN SQL QUERIES

*/

SELECT * 
FROM [Portfolio Project]..NashvilleHousing
-----------------------------------------------------------------------------------
-- STANDARDIZE DATA FORMAT 


SELECT SaleDate, CONVERT(DATE,SaleDate) 
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ALTER COLUMN SaleDate DATE

-----------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA 


SELECT *
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A 
SET A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


-----------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)  

SELECT *
FROM [Portfolio Project]..NashvilleHousing

SELECT 
SUBSTRING (PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS)-1) AS ADDRESS,
SUBSTRING (PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS)) AS ADDRESS
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing 
ADD StreetName NVARCHAR(255); 
GO 

UPDATE [Portfolio Project]..NashvilleHousing
SET StreetName = SUBSTRING (PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS)-1) 
GO 

ALTER TABLE [Portfolio Project]..NashvilleHousing 
ADD City NVARCHAR(255); 
GO 

UPDATE[Portfolio Project]..NashvilleHousing
SET City = SUBSTRING (PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS))
GO

SELECT *
FROM [Portfolio Project]..NashvilleHousing


SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing



--PARSENAME (BETTER WAY THAN A SUBSTRING)  

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing


SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS STREET,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS CITY,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS STATE
FROM [Portfolio Project]..NashvilleHousing;


--RESULTS USING PARSENAME  

ALTER TABLE [Portfolio Project]..NashvilleHousing 
ADD OwnerStreet NVARCHAR(255),
    OwnerCity NVARCHAR(255),
    OwnerState NVARCHAR(255);

UPDATE[Portfolio Project]..NashvilleHousing
SET 
    OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT * 
FROM [Portfolio Project]..NashvilleHousing
-----------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD 

SELECT DISTINCT SoldAsVacant
FROM [Portfolio Project]..[NashvilleHousing];

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) 
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM [Portfolio Project]..NashvilleHousing


UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE 
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                    END;


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) 
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-----------------------------------------------------------------------------------

--REMOVE DUPLICATES 

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
                          PropertyAddress, 
                          SalePrice, 
                          SaleDate, 
                          LegalReference
             ORDER BY UniqueID) 
             ROW_NUM
FROM [Portfolio Project]..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1 
--ORDER BY PropertyAddress


--RESULTS AFTER DELTING DUPLICATES 

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
                          PropertyAddress, 
                          SalePrice, 
                          SaleDate, 
                          LegalReference
             ORDER BY UniqueID) 
             ROW_NUM
FROM [Portfolio Project]..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1 


-----------------------------------------------------------------------------------

--REMOVE DUPLICATES 

SELECT *
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



