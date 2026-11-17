SELECT
ca.id as 'car_allowance_id',
ca.carId as 'car_id',
ca.country as 'country_id',
ca.amount as 'allowance_sum',
ca.type as 'allowance_type',
ca.comments as 'allowance_comment',
UNIX_TIMESTAMP(ca.createdAt) as 'allowance_created',
ca.createdById as 'allowance_created_by_id',
ca.createdByName as 'allowance_created_by',
UNIX_TIMESTAMP(ca.updatedAt) as 'allowance_last_modified',
ca.updatedById as 'allowance_last_modified_by_id',
ca.updatedByName as 'allowance_last_modified_by',
UNIX_TIMESTAMP(ca.deletedAt) as 'deleted_at',
ca.deletedById as 'deleted_by_id',
ca.deletedByName as 'deleted_by'
FROM fcgOrder.carAllowance ca
where ca.updatedAt >= '{{params.start_ts}}' and ca.updatedAt < '{{params.end_ts}}'