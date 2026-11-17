SELECT
    cd.id as car_detail_id,
    cd.carId as car_id,
    c.country as country_id,
    cd.key as attribute_name,
    cd.value as attribute_value,
    UNIX_TIMESTAMP(cd.createdAt) as created_at, 
    cd.createdById as created_by_id,
    cd.createdByName as created_by_name,
    UNIX_TIMESTAMP(cd.updatedAt) as updated_at, 
    cd.updatedById as updated_by_id,
    cd.updatedByName as updated_by_name,
    UNIX_TIMESTAMP(cd.deletedAt) as deleted_at, 
    cd.deletedById as deleted_by_id,
    cd.deletedByName as deleted_by_name
FROM fcgCar.carDetail cd
    JOIN fcgCar.car c on c.id = cd.carId
where cd.updatedAt >= '{{params.start_ts}}' and cd.updatedAt < '{{params.end_ts}}'