/*
Cleaning Data in SQL Queries
*/

Select * 
From Portfolio_Projects..NashvilleHousing

-- Standardize Date Format


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)


-- Populate Property Address data

Select * 
From Portfolio_Projects..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Projects..NashvilleHousing a
Join Portfolio_Projects..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Projects..NashvilleHousing a
Join Portfolio_Projects..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		And a.[UniqueID ] = b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From Portfolio_Projects..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Portfolio_Projects..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From Portfolio_Projects..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(Replace(OwnerAddress, ',' ,'.') ,1)
From Portfolio_Projects..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select * 
From Portfolio_Projects..NashvilleHousing


-- Change Y and N to Yes and NO in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Projects..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From Portfolio_Projects..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			End


-- Remove Duplicates

WITH RowNumCTE AS (
Select * ,
		ROW_NUMBER() Over (
		PARTITION by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
						UniqueID
						) row_num
From Portfolio_Projects..NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select * 
From Portfolio_Projects..NashvilleHousing



-- Delete Unused Columns

Alter Table Portfolio_Projects..NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict


Select * 
From Portfolio_Projects..NashvilleHousing