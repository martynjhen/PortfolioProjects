select *
from nashville_housing_data_for_data_cleaning nhdfdc 
--Set normal columns names
ALTER table nashville_housing_data_for_data_cleaning
RENAME COLUMN "ParcelID" to parcel_id;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "LandUse" to land_use;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "PropertyAddress"  to property_address;
ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "SaleDate" to sale_date;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "SalePrice" to sale_price;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "LegalReference" to legal_reference;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "SoldAsVacant" to sold_as_vacant;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "OwnerName" to owner_name;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "OwnerAddress" to owner_address;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "Acreage" to acreage;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "TaxDistrict" to tax_district;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "LandValue" to land_value;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "BuildingValue" to building_value;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "TotalValue" to total_value;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "YearBuilt" to year_built;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "Bedrooms" to bedrooms;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "FullBath" to fullbath;

ALTER TABLE nashville_housing_data_for_data_cleaning
RENAME COLUMN "HalfBath" to halfbath;

--Populate Property Address Data
select *
from nashville_housing_data_for_data_cleaning
where LENGTH(property_address)= 0

Update nashville_housing_data 
Set property_address = 'No address'
where LENGTH(property_address) = 0 

--Breaking out Address into individual Columns(Address, City, State)

select property_address
from nashville_housing_data_for_data_cleaning nhdfdc 

select split_part(property_address, '.', 1) as Address, split_part(property_address, '.', 2) as Address
from nashville_housing_data_for_data_cleaning nhdfdc 

alter table nashville_housing_data_for_data_cleaning 
add column property_split_address varchar(255);

update nashville_housing_data_for_data_cleaning 
set property_split_address = split_part(property_address, '.', 1);

alter table nashville_housing_data_for_data_cleaning 
add column property_split_city varchar(255);

update nashville_housing_data_for_data_cleaning 
set property_split_city = split_part(property_address, '.', 2);

select *
from nashville_housing_data_for_data_cleaning nhdfdc 
-- do the similar stuff with owner_address column
select owner_address, 
		split_part(owner_address, '.', 1) as Address,
		split_part(owner_address, '.', 2) as Address,
		split_part(owner_address, '.', 3) as Address
from nashville_housing_data_for_data_cleaning nhdfdc 

alter table nashville_housing_data_for_data_cleaning 
add column owner_split_address varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_address = split_part(owner_address, '.', 1);

alter table nashville_housing_data_for_data_cleaning 
add column owner_split_city varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_city = split_part(owner_address, '.', 2);

alter table nashville_housing_data_for_data_cleaning 
add column owner_split_state varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_state = split_part(owner_address, '.', 3);

--Change Y and N to Yes and No in 'aold_as_vacant' field
select distinct sold_as_vacant
from nashville_housing_data_for_data_cleaning nhdfdc 

update nashville_housing_data_for_data_cleaning 
set sold_as_vacant = case when sold_as_vacant = 'Y' then 'Yes'
							when sold_as_vacant = 'N' then 'No'
							else sold_as_vacant
							end

--Remove duplicates
with RowNumCTE AS(
select *,
	ROW_NUMBER() over (
	partition by parcel_id,
				 property_address,
				 sale_price,
				 sale_date,
				 legal_reference
				 order by 
				 	"UniqueID ") as row_num
from nashville_housing_data_for_data_cleaning)
delete from nashville_housing_data_for_data_cleaning nhdfdc 
where "UniqueID " IN(
select "UniqueID "
from RowNumCTE
where row_num > 1);

