

--Cleaning Data in SQL Queries
--*/

Select *
from dbo.NashvilleHousing

-------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDateConverted, Convert(date, SaleDate)
from dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)


---------------------------------------------------------------------------------

--Populate Property Address data

Select *
from dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> B.UniqueID
	where a.PropertyAddress is null

Update a
Set  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> B.UniqueID
	where a.PropertyAddress is null


----------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select*
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 3)


Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 2)


Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
  END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
  END 


  ----------------------------------------------------------------------------------------------------------

  --Remove Duplicates

  WITH RowNumCTE AS (
  Select *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by
				Uniqueid) row_num
  From PortfolioProject.dbo.NashvilleHousing
  --order by ParcelID
  )
  Select *
  from RowNumCTE
  where row_num > 1
 order by PropertyAddress


 Select *
 From PortfolioProject.dbo.NashvilleHousing


 -----------------------------------------------------------------------------------------------

 --Delete Unused Columns

 Select *
 From PortfolioProject.dbo.NashvilleHousing

 ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
 DROP COLUMN SaleDate

 ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
 DROP COLUMN ParcelID
 