/*
Portfolio Project

Data Cleaning of a dataset NashvilleHousing 
Functions used - 
CONVERT()
ISNULL()
SUBSTRING()
CHARINDEX()
PARSENAME()
REPLACE()
Used CTEs - Row_Number()

*/

SELECT * FROM 
PortfolioProject.dbo.NashvilleHousing;

-- Standardize date format for saledate

Alter table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = Convert(Date,SaleDate)

-- Populate Property address data

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) FROM 
PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out address into individual columns (Address, sity ,state)
-- Property address split

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
FROM 
PortfolioProject.dbo.NashvilleHousing;

Alter table NashvilleHousing
ADD PropertSplitAddress Nvarchar(255);

Alter table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertSplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


-- Owner Address split to Address, city, state using parsename()

Select ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),
ParseName(Replace(OwnerAddress,',','.'),1)
FROM
PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Alter table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Alter table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress =ParseName(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
set OwnerSplitCity =ParseName(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
set OwnerSplitState =ParseName(Replace(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END
FROM
PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END

-- Remove Duplicates 

With RowNumCTE AS (
	SELECT *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID 
	) row_num
	FROM
	PortfolioProject.dbo.NashvilleHousing
)

Delete FROM RowNumCTE
WHERE row_num > 1

-- Delete unused columns

Alter Table NashvilleHousing
DROP Column PropertyAddress, OwnerAddress,TaxDistrict

Alter Table NashvilleHousing
DROP Column SaleDate

Select * FROM NashvilleHousing;