--- clearning data in SQL Querles
select *
from beheo.dbo.NashvilleHousing

-------- standardize Date Format: in saledate, i want to insert a column just keep the date
select SaleDate,SaleDateConverted, CONVERT(date, SaleDate)
from beheo.dbo.NashvilleHousing

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

-------- Populate Property address data
select *
from beheo.dbo.NashvilleHousing
--where PropertyAddress is null

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from beheo.dbo.NashvilleHousing a
Join beheo.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from beheo.dbo.NashvilleHousing a
Join beheo.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


---- Breaking out address into individual columns (address, city, state)
select PropertyAddress
from beheo.dbo.NashvilleHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as address 
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from beheo.dbo.NashvilleHousing

Alter Table NashvilleHousing
add PopertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PopertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


Alter Table NashvilleHousing
add PopertySplitCity Nvarchar(255);

Update NashvilleHousing
set PopertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select OwnerAddress
from NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.'), 3)
,PARSENAME(Replace(OwnerAddress,',','.'), 2)
,PARSENAME(Replace(OwnerAddress,',','.'), 1)
from NashvilleHousing

Alter Table NashvilleHousing
add OwnerAddressSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerAddressSplitCity =PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
add OwnerAddressSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerAddressSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
add OwnerAddressSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerAddressSplitState =PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from beheo.dbo.NashvilleHousing

------ change Y and N to yes and no in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
from beheo.dbo.NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from beheo.dbo.NashvilleHousing


Update beheo.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--------- Remove Duplicates 

WITH RowNumCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY 
                UniqueID
        ) AS row_num
    FROM 
        beheo.dbo.NashvilleHousing
)
Delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

----------- Delete Unused Columns
Select *
from beheo.dbo.NashvilleHousing

Alter table beheo.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table beheo.dbo.NashvilleHousing
Drop column SaleDate
