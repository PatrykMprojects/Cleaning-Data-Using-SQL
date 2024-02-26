-- Cleaning Data in SQL

select * 
from NashvilleHousing
-- Standartize date format

select SaleDateConverted, CONVERT(Date, SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing 
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property address data 

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

-- use ParcelID as reference to populate address column 
-- if ParcelID is the same but has a difeferent UniqueID then populate address column
-- after running update and rerunning code below the output should be columns names with no rows 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- update the main table and populate null values

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 


-- breaking out address into individual columns ( address city, state)

-- this query below is displaying everything until ',' character is met in the PropertyAddress column 
-- charindex is giving us a character position of ',' occurs
-- by adding -1 into query, the output wont include ',' in the Address column
-- by addig +1 into query, the output will include everything that is after ',' in Property address
-- len(PropertyAddress) is specifying where our query ends. It will end at the last character of the column PropertyAddress.
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
-- ,CHARINDEX(',', PropertyAddress)
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from NashvilleHousing

-- add columns into the main table 

alter table NashvilleHousing 
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing 
add PropertySplitCity  Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


-- check main table 
select * 
from NashvilleHousing

-- different approach to do the same operation on OwnerAddress
-- parsname work only with '.' therefore query includes replacing ',' with '.' 

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

-- adding new columns to the original dataset 

alter table NashvilleHousing 
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing 
add OwnerSplitCity  Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing 
add OwnerSplitState  Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


-- check main dataset

select*
from NashvilleHousing


-- change Y and N to Yes and No in 'Sold as Vacant' 
-- display all possibilities in column 'Sold as Vacant'

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- change Y and N to Yes and No using case statment

select SoldAsVacant
	, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

-- update the main dataset

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- check the output

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



-- remove duplicates
-- query to display duplicates where in col row_num with value 2 means duplicate
-- for this purpose we use CTE to create another instance of our main dataset to delete values from copied table

with RowNumCTE as (
select * , 
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num > 1
--Order by PropertyAddress

-- check if duplicates were removed

with RowNumCTE as (
select * , 
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress

-- delete unused columns OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- check updated dataset 

select * 
from NashvilleHousing