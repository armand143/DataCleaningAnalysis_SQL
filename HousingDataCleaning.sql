SELECT * 
FROM projects.dbo.NashvilleHousing


------ CLEANING DATA USING SQL QUERIES-----------------------------------



----------Correct the SaleDate Format: (Idea is to create a new column and put in the Date data in it's wanted format then delete the SaleDate Column with unwanted date format
--view SaleDate Column 
SELECT SaleDate 
FROM projects.dbo.NashvilleHousing

--create new column 
ALTER TABLE projects.dbo.NashvilleHousing
ADD newSaleDate date

--add data into new column with wanted format 
UPDATE projects.dbo.NashvilleHousing
SET newSaleDate = CONVERT(date, SaleDate)

--delete column with unwanted format 
ALTER TABLE projects.dbo.NashvilleHousing
DROP COLUMN SaleDate







------------------Populate PropertyAddress: 
--view if table actually contains NULLs in propertyaddress
SELECT * 
FROM projects.dbo.NashvilleHousing 
WHERE propertyAddress IS NULL

--abserve parcelid often appears twice, with different uniqueIDs and some entries with same parcelid have missen Propertyasddress entries
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.PropertyAddress  --,ISNULL(a.propertyAddress, b.propertyAddress) 
FROM projects.dbo.NashvilleHousing a JOIN projects.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID 
AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL 

-- fill in the NULLs in propertyAddress 
UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.propertyAddress) 
				      FROM projects.dbo.NashvilleHousing a JOIN projects.dbo.NashvilleHousing b 
					  ON a.ParcelID = b.ParcelID 
					  AND a.UniqueID != b.UniqueID
					  WHERE a.PropertyAddress IS NULL
					  




-----------------------break Address into individual columns( address, city, state) 
--using SUBSTRING
SELECT SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) as Address, OwnerAddress
FROM projects.dbo.NashvilleHousing


---PARSENAME is a better option (PARSENAME works backwards on a string) 

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), OwnerAddress
FROM projects.dbo.NashvilleHousing

--create new columns for address, city and state

ALTER TABLE projects.dbo.NashvilleHousing
ADD newAddress varchar(256);

ALTER TABLE projects.dbo.NashvilleHousing
ADD newCity varchar(256);

ALTER TABLE projects.dbo.NashvilleHousing
ADD newState varchar(256); 

UPDATE projects.dbo.NashvilleHousing 
SET newAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 


UPDATE projects.dbo.NashvilleHousing 
SET newCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

UPDATE projects.dbo.NashvilleHousing 
SET newState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 







----------------Changing Y and N to Yes or No in SoldAsVacant column 

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  WHEN SoldAsVacant = 'N' THEN 'No' 	
						  ELSE SoldAsVacant
						  END
						  as newSoldAsVacant
FROM projects.dbo.NashvilleHousing


--update Column

UPDATE projects.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  WHEN SoldAsVacant = 'N' THEN 'No' 	
						  ELSE SoldAsVacant
						  END						  
FROM projects.dbo.NashvilleHousing

---just quick check if it's actually updated
SELECT SoldAsVacant 
FROM projects.dbo.NashvilleHousing
WHERE SoldAsVacant IN ('Y','N')





------------Deleting duplicates 

---using window functions to locate duplicates

WITH nvHousingCTE AS( 
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, newSaleDate, LegalReference ORDER BY uniqueID) rownum
FROM projects.dbo.NashvilleHousing)
	SELECT * 
	FROM nvHousingCTE
	WHERE rownum > 1


--now deleting all these entries/rows from the table projects.dbo.NashvilleHousing
WITH nvHousingCTE AS( 
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, newSaleDate, LegalReference ORDER BY uniqueID) rownum
FROM projects.dbo.NashvilleHousing)
	DELETE
	FROM nvHousingCTE
	WHERE rownum > 1





--------- Deleting Unused Columns 

ALTER TABLE projects.dbo.NashvilleHousing
DROP COlUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT * 
FROM projects.dbo.NashvilleHousing 


