MERGE `{{params.project_name}}.semantics_central.CarOfferPrices` final
USING (
{{range_query}}
) staging
ON final.car_offer_pricing_id = staging.car_offer_pricing_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.offer_price = staging.offer_price,
final.offer_price_type = staging.offer_price_type,
final.offer_price_subtype = staging.offer_price_subtype,
final.created_by = staging.created_by,
final.created_by_id = staging.created_by_id,
final.created_at = staging.created_at,
final.updated_by = staging.updated_by,
final.updated_by_id = staging.updated_by_id,
final.updated_at = staging.updated_at,
final.deleted_by = staging.deleted_by,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_at = staging.deleted_at,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
car_offer_pricing_id,
car_id,
offer_price,
offer_price_type,
offer_price_subtype,
created_by,
created_by_id,
created_at,
updated_by,
updated_by_id,
updated_at,
deleted_by,
deleted_by_id,
deleted_at,
country_id
) VALUES (
staging.car_offer_pricing_id,
staging.car_id,
staging.offer_price,
staging.offer_price_type,
staging.offer_price_subtype,
staging.created_by,
staging.created_by_id,
staging.created_at,
staging.updated_by,
staging.updated_by_id,
staging.updated_at,
staging.deleted_by,
staging.deleted_by_id,
staging.deleted_at,
staging.country_id
)