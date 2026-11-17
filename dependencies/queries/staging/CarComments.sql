SELECT
    cc.id as car_comment_id,
    cc.carId as car_id,
    c.country as country_id,
    cc.title as comment_title,
    cc.description as comment_description, 
    cc.mentions as mentions, 
    UNIX_TIMESTAMP(cc.createdAt) as created_at,
    UNIX_TIMESTAMP(cc.updatedAt) as updated_at, 
    UNIX_TIMESTAMP(cc.deletedAt) as deleted_at, 
    cc.createdById as created_by_id,
    cc.createdByName as created_by_name,
    cc.updatedById as updated_by_id,
    cc.updatedByName as updated_by_name,
    cc.deletedById as deleted_by_id,
    cc.deletedByName as deleted_by_name
FROM fcgCar.comment cc
    JOIN fcgCar.car c on c.id = cc.carId
where cc.updatedAt >= '{{params.start_ts}}' and cc.updatedAt < '{{params.end_ts}}'

