-- T1. cleaning data in sql 

select * 
from PortfolioProject.dbo.NashHousing


-- a. Standardize SaleDate format

select saleDate, CONVERT( date, saleDate)
from PortfolioProject.dbo.NashHousing

--20% update will work but most of the time to use alter then update 
--update NashHousing
--set saleDate = convert(date, saleDate)

alter table NashHousing 
add SaleDateConverted Date;

Update NashHousing
Set SaleDateConverted = convert(date, saleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashHousing 

-- b. Popular property address data 

select *
from PortfolioProject.dbo.NashHousing
--where propertyAddress is null 
order by ParcelID
-- same parceId have two records with same address 
-- fill the null address  

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashHousing a 
join PortfolioProject.dbo.NashHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashHousing a 
join PortfolioProject.dbo.NashHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]


-- c. breaking out addresss into individual columns(Address, City, State) 


select PropertyAddress 
from PortfolioProject.dbo.NashHousing
--where propertyAddress is null 
--order by ParcelID

-- substring extracts some characters from a string.
-- SUBSTRING(string, start, length)
-- string, the string to extract from 
-- start, the start position
-- length, the number of characters to extract 
--https://www.w3schools.com/sql/func_sqlserver_substring.asp

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address 
from PortfolioProject.dbo.NashHousing
-- add -1, get rid of comma 

alter table NashHousing 
add PropertySplitAddress Nvarchar(225);

Update NashHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

alter table NashHousing 
add PropertySplitCity Nvarchar(225);

Update NashHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress));

select *
from PortfolioProject.dbo.NashHousing

Alter table NashHousing
Drop column PropertySplitAddress2


-- d. differnt ways to split onweraddress by city,state.. 
-- The PARSENAME function is designed to allow you to easily parse and return individual segments from this convention. 
--It's syntax is : PARSENAME('object_name', object_piece)

PARSENAME('object_name', object_piece)
select ownerAddress 
from PortfolioProject.dbo.NashHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashHousing


alter table NashHousing 
add OwnerSplitAddress Nvarchar(225);

Update NashHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


alter table NashHousing 
add OwnerSplitCity Nvarchar(225);

Update NashHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


alter table NashHousing 
add OwnerSplitState Nvarchar(225);

Update NashHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


select *
from PortfolioProject.dbo.NashHousing


-- Change Y and N to Yes and No in 'sold as vacant' field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant 
	 END
from PortfolioProject.dbo.NashHousing

Update NashHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant 
	 END
from PortfolioProject.dbo.NashHousing

-- Remove duplicates 

With RowNuCTE as(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashHousing
--order by ParcelID
)
select *
From RowNuCTE
where row_num >1 
order by PropertyAddress 

-- change to delete 


-- Delete Unused Columns 

select * 
from PortfolioProject.dbo.NashHousing

Alter table PortfolioProject.dbo.NashHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress 