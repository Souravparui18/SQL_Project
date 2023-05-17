/*

Cleaning Data in Sql Queries

*/

Select * 
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaledateConverted, CONVERT(date,Saledate)
from PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set Saledate = CONVERT(date,Saledate)

Alter TABLE NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
Set SaledateConverted = CONVERT(date,Saledate)

-----------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City , State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Addresss
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Addresss
from PortfolioProject..NashvilleHousing


Alter TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select * 
from PortfolioProject..NashvilleHousing



Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing


Alter TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


Alter TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


Select * from PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), COUNT(SoldasVacant)
from PortfolioProject..NashvilleHousing
Group By SoldAsVacant
order by 2


Select SoldAsVacant
,  CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End

----------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
--Select *
from RowNumCTE
where row_num >1 
--Order By PropertyAddress

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
from PortfolioProject..NashvilleHousing

Alter TABLE NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

