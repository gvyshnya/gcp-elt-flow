SELECT
h.id as 'car_history_change_id',
h.carId as 'car_id',
c.country as 'country_id',
h.type as 'car_history_change_type',
h.typeId as 'car_history_change_type_id',
h.operation as 'car_history_change_operation',
h.field as 'affected_field',
h.value as 'car_history_change_value',
h.updatedById as 'updated_by',
h.updatedByEmail as 'updated_by_email',
UNIX_TIMESTAMP(h.createdAt) as 'car_history_change_created',
UNIX_TIMESTAMP(h.updatedAt) as 'car_history_change_last_modified',
UNIX_TIMESTAMP(h.deletedAt) as 'deleted_at'
FROM fcgCar.carHistory h
JOIN fcgCar.car c ON h.carId = c.id
where h.updatedAt >= '{{params.start_ts}}' and h.updatedAt < '{{params.end_ts}}'