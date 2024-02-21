/*

Cleaning DATA in SQL Queries


*/


SELECT*
FROM [Project Portfolio]..NashvilleHousing

-------------------

--Standardize Date Format


SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Project Portfolio]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



----------------------


----populate the property address

SELECT *
FROM [Project Portfolio]..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--originally the property address is empty

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Project Portfolio]..NashvilleHousing a
JOIN [Project Portfolio]..NashvilleHousing b
	on b.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--no more columns with null with the below statement
-- can also add a string
-- SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress,'string')

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Project Portfolio]..NashvilleHousing a
JOIN [Project Portfolio]..NashvilleHousing b
	on b.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


------
--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Project Portfolio]..NashvilleHousing
--WhERE PropertyAddress is null
--ORDER BY ParcelID

-- Start at the position prior of the charindex
--- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
-- without + 1 there is a comma
--- QUERY IS DETAILING THE DIFFERENCE BETWEEN THE ADDRESSES OF CITY AND PROPERTY

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM [Project Portfolio]..NashvilleHousing


-- create 2 new coluumns
-- do property address and propertysplitcity

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress) )

SELECT*
FROM [Project Portfolio]..NashvilleHousing


SELECT OwnerAddress
FROM [Project Portfolio]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM [Project Portfolio]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

SELECT *
FROM [Project Portfolio]..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsvacant), Count(SoldAsVacant)
FROM [Project Portfolio]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

FROM [Project Portfolio]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END














--- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Project Portfolio]..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM [Project Portfolio]..NashvilleHousing




















---Delete Unused Columns



SELECT *
FROM [Project Portfolio]..NashvilleHousing

ALTER TABLE [Project Portfolio]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, Sale















































---------------
---------------
--- Importing Data using OPENROWSET AND BULK INSERT

--- More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this in case you wanted to try it



-- sp_configure * show advanced options'. 1;
-- RECONFIGURE
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- USE [Project Portfolio]

--GO

-- EXEC master.dbo.sp_MSet_oledb_prop N 'Microsoft.ACE.OLEDB.1.0', N'AllowInProcess', 1

-- GO

-- EXEC master.dbo.sp_MSet_oledb_prop N 'Microsoft.ACE.OLEDB.12.0', n'DynamicParameters', 1

--GO

--- USING BULK INSERT

-- USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'directoryfornashville'
-- WITH (
--		FIELD TERMINATOR = ',',
--		ROWTERMINATOR = '\n'
--);
-- GO