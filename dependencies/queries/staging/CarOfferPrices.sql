SELECT 
cop.id as 'car_offer_pricing_id',
cop.carId as 'car_id',
cop.amount as 'offer_price',
cop.type as 'offer_price_type',
cop.subtype as 'offer_price_subtype',
cop.country as 'country_id',
UNIX_TIMESTAMP(cop.createdAt) as 'created_at',
UNIX_TIMESTAMP(cop.updatedAt) as 'updated_at',
UNIX_TIMESTAMP(cop.deletedAt) as 'deleted_at',
cop.createdByName as 'created_by',
cop.createdById as 'created_by_id',
cop.updatedByName as 'updated_by',
cop.updatedById as 'updated_by_id',
cop.deletedByName as 'updated_by',
cop.deletedById as 'deleted_by_id'
FROM fcgOrder.offerPricing cop
where cop.updatedAt >= '{{params.start_ts}}' and cop.updatedAt < '{{params.end_ts}}'