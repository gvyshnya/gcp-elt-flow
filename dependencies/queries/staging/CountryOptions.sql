SELECT 
c_ops.id as 'country_options_id',
c_ops.type as 'country_options_type',
c_ops.name as 'country_options_name',
c_ops.country as 'country_id',
c_ops.biMapping as 'bi_mapping',
UNIX_TIMESTAMP(c_ops.createdAt) as 'created_at',
UNIX_TIMESTAMP(c_ops.updatedAt) as 'updated_at',
UNIX_TIMESTAMP(c_ops.deletedAt) as 'deleted_at'
FROM fcgCar.countryOptions c_ops
where
c_ops.updatedAt >= '{{params.start_ts}}' and c_ops.updatedAt < '{{params.end_ts}}'