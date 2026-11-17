
SELECT
    cs.id as car_status_id,
    cs.carId as car_id,
    cs.statusType as car_status_type,
    cs.status as car_status,
    cs.reason as status_reason,
    UNIX_TIMESTAMP(cs.createdAt) as created_at, 
    UNIX_TIMESTAMP(cs.updatedAt) as updated_at, 
    UNIX_TIMESTAMP(cs.deletedAt) as deleted_at, 
    cs.createdById as created_by_id,
    cs.createdByName as created_by,
    cs.updatedById as updated_by_id,
    cs.updatedByName as updated_by,
    cs.deletedById as deleted_by_id,
    cs.deletedByName as deleted_by,
    c.country as country_id
FROM fcgCar.status cs
join fcgCar.car c on cs.carId=c.id
where cs.updatedAt >= '{{params.start_ts}}' and cs.updatedAt < '{{params.end_ts}}'