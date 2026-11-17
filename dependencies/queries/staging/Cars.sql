/* 
    this the data extraction from fcgCar.car  - this just a fraction of attributes in
    the Cars entity in BI 1.0 DWH
*/

SELECT  
    c.id as 'car_id', 
    c.internalId as 'internal_car_id', 
    c.make as 'car_manufacturer', 
    c.model as 'car_model', 
    c.trim as 'car_trim', 
    c.year as 'year_manufactured', 
    c.mileage as 'car_mileage', 
    c.color as 'car_color',
    c.vin as 'car_vin',
    c.licensePlate as 'car_license_plate',
    c.type as 'car_type', 
    c.country as 'country_id',  
    UNIX_TIMESTAMP(c.handoverFromSellerAt) as 'car_handedover_from_seller',
    UNIX_TIMESTAMP(c.handoverToBuyerAt) as 'car_handedover_to_buyer', 
    c.locationTrackerID as 'car_location_tracker_id',
    UNIX_TIMESTAMP(c.createdAt) as 'car_created', 
    UNIX_TIMESTAMP(c.updatedAt) as 'car_last_modified', 
    UNIX_TIMESTAMP(c.deletedAt) as 'deleted_at',
    c.createdById as 'created_by_id',
    c.createdByName as 'created_by',
    c.updatedByName as 'updated_by',
    c.updatedById as 'updated_by_id',
    deletedById as 'deleted_by_id',
    deletedByName as 'deleted_by',
    UNIX_TIMESTAMP(c.availableForPickup) as 'available_for_pickup',
    c.engineNumber as 'car_engine_number', 
    c.registeredCity as 'car_registered_city',
    UNIX_TIMESTAMP(c.technicalCheckExpiration) as 'car_technical_check_expiration',  
    c.refurbishmentStatus as 'car_refurbishment_status',
    c.trimDetails as 'car_trim_details',
    c.sourceCarID as 'source_car_id',
    UNIX_TIMESTAMP(c.pickUpFrom) as 'car_pick_up_from_date',     
    c.bookingId as 'booking_id',
    c.grade as 'car_grade'
FROM fcgCar.car c
where c.updatedAt >= '{{params.start_ts}}' and c.updatedAt < '{{params.end_ts}}'

/*
Table: car
Columns (as of Mar 6, 2019)
id char(36) PK 
internalId bigint(16) UN AI 
make varchar(256) 
model varchar(256)
trim varchar(256) 
year int(4) UN 
mileage int(9) UN 
color varchar(256) 
vin varchar(256) 
licensePlate varchar(256) 
type varchar(256) 
country char(2) 
handoverFromSellerAt datetime 
handoverToBuyerAt datetime 
locationTrackerID varchar(64) 
createdAt datetime 
updatedAt datetime 
deletedAt datetime 
createdById varchar(256) 
updatedByName varchar(256) 
updatedById varchar(256) 
createdByName varchar(256) 
deletedById varchar(256) 
deletedByName varchar(256) 
availableForPickup datetime 
engineNumber text 

registeredCity text 
technicalCheckExpiration datetime 
refurbishmentStatus varchar(256) 
trimDetails text 
sourceCarID char(36) 
pickUpFrom datetime 
bookingId varchar(64) 
grade varchar(64)

car_fuel and car_transmission to be  implemented on the view level down the road
*/