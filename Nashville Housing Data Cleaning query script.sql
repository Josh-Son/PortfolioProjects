/* Nashville Housing Data Cleaning in SQL Queries */

SELECT *
FROM PortfolioProject..NashvilleHousing



-- Change Date to standardized format
SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- IF it doesn't update properly
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate Data on Property Addresses
SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Splitting Address into separate columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing



-- Changing Y and N to Yes and No in "Sold as Vacant" column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
        WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
        ELSE SoldAsVacant
        END



-- Removing Duplicates in Database
WITH RowNumCTE AS(
SELECT
    *,
    ROW_NUMBER() OVER
        (PARTITION BY ParcelID, 
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
        ORDER BY
            UniqueID)
        AS row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing



-- Deleting Columns that is not Useful
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

