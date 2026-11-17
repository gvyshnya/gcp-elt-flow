SELECT 
tr.id as 'payment_id',
tr.carID as 'car_id', 
tr.type as 'payment_type', 
tr.subtype as 'payment_subtype',
tr.status as 'payment_status',
tr.amount as 'payment_sum',
tr.vatPercentage as 'payment_vat_percentage',
tr.vat as 'payment_vat',
tr.comments as 'payment_comment', 
tr.country as 'country_id', 
UNIX_TIMESTAMP(tr.transactionDate) as 'transaction_date', 
UNIX_TIMESTAMP(tr.createdAt) as 'payment_created',
tr.createdByName as 'payment_created_by',
tr.createdById as 'payment_created_by_id',
UNIX_TIMESTAMP(tr.updatedAt) as 'payment_last_modified', 
tr.updatedByName as 'payment_last_modified_by',
tr.updatedById as 'payment_last_modified_by_id',
UNIX_TIMESTAMP(tr.deletedAt) as 'deleted_at',
tr.deletedByName as 'deleted_by',
tr.deletedById as 'deleted_by_id'
FROM fcgOrder.transaction tr
where tr.updatedAt >= '{{params.start_ts}}' and tr.updatedAt < '{{params.end_ts}}'