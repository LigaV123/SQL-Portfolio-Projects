/*
	Data Cleaning with SQL queries
*/



Select *
From NashvilleHousing..NashvilleHousing



-- Converting/Casting Sale Date from dateTime to date

Alter Table NashvilleHousing
Alter Column SaleDate date

Select SaleDate, Cast(SaleDate As date) As DateOfSale
From NashvilleHousing



-- Populate Property Address data

Select MainTable.ParcelID, MainTable.PropertyAddress, SecondTable.ParcelID, SecondTable.PropertyAddress
	, IsNull(MainTable.PropertyAddress, SecondTable.PropertyAddress) As DataToFill
From NashvilleHousing MainTable
Join NashvilleHousing SecondTable
	On MainTable.ParcelID = SecondTable.ParcelID
	And MainTable.[UniqueID ] <> SecondTable.[UniqueID ]
Where MainTable.PropertyAddress Is Null

Update MainTable
Set PropertyAddress = IsNull(MainTable.PropertyAddress, SecondTable.PropertyAddress)
From NashvilleHousing MainTable
Join NashvilleHousing SecondTable
	On MainTable.ParcelID = SecondTable.ParcelID
	And MainTable.[UniqueID ] <> SecondTable.[UniqueID ]
Where MainTable.PropertyAddress Is Null



-- Breaking Address into individual columns (Address, City, State)
-- Property Address

Select Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
	, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) As City
From NashvilleHousing

-- For Property Address
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- For Property City
Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


-- Owner Address

Select PARSENAME(Replace(OwnerAddress, ',', '.'), 1) As State
	, PARSENAME(Replace(OwnerAddress, ',', '.'), 2) As City
	, PARSENAME(Replace(OwnerAddress, ',', '.'), 3) As Address
From NashvilleHousing

-- For Owner Address
Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

-- For Owner City
Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

-- For Owner State
Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in Solid As Vacant column

Select Distinct SoldAsVacant, Count(SoldAsVacant) As CountSoldAsVacant
From NashvilleHousing
Group By SoldAsVacant
Order By CountSoldAsVacant

Select SoldAsVacant
	, Case 
		When SoldAsVacant Like 'Y%' Then 'Yes'
		Else 'No'
	  End As FullWord
From NashvilleHousing
Order By SoldAsVacant

Update NashvilleHousing
Set SoldAsVacant = Case 
					 When SoldAsVacant Like 'Y%' Then 'Yes'
					 Else 'No'
				   End



-- Remove dublicates 
-- (this is for practice only, usually in real time, data is not deleted from db)

With RowNumCTE AS
(
	Select *, 
		Row_Number() Over 
			(Partition By ParcelID, PropertySplitAddress, PropertySplitCity, SaleDate, SalePrice, LegalReference Order By UniqueID) As row_num
	From NashvilleHousing
)
Delete
-- Select *  -- to check if dublicate rows where deleted
From RowNumCTE
Where row_num > 1



-- Delete unused Columns (usually done for views not the raw data)

Select *
From NashvilleHousing..NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict