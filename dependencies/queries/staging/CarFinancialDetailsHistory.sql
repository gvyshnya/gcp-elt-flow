SELECT 
h.id as 'financial_detail_id',
h.carId as 'car_id',
/* c.country as 'country_id',  --Cross service field*/
h.type as 'financial_detail_operation_type',
h.operation as 'financial_detail_operation',
h.field as 'affected_field',
h.value as 'financial_detail_operation_value', 
h.updatedById as 'updated_by',
h.updatedByEmail as 'updated_by_email',
UNIX_TIMESTAMP(h.createdAt) as 'financial_detail_created',
UNIX_TIMESTAMP(h.updatedAt) as 'financial_detail_last_modified',
UNIX_TIMESTAMP(h.deletedAt) as 'deleted_at'
FROM fcgOrder.financialDetailsHistory h
/* JOIN fcgCar.car c ON h.carId = c.id  --Cross service */
where h.updatedAt >= '{{params.start_ts}}' and h.updatedAt < '{{params.end_ts}}'