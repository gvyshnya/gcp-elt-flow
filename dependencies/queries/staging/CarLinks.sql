SELECT 
l.id as link_id, 
l.carId as car_id,
l.countryCar as country_id, 
l.swappedCarId as swapped_car_id,
l.countrySwappedCar as country_swapped_car,
l.type as link_type,
UNIX_TIMESTAMP(l.createdAt) as created_at,
l.createdById as created_by_id,
l.createdByName as created_by_name,
UNIX_TIMESTAMP(l.updatedAt) as updated_at,
UNIX_TIMESTAMP(l.deletedAt) as deleted_at,
l.deletedById as deleted_by_id,
l.deletedByName as deleted_by_name
FROM fcgCar.link l
where l.updatedAt >= '{{params.start_ts}}' and l.updatedAt < '{{params.end_ts}}'