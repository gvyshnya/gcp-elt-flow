MERGE `{{params.project_name}}.semantics_central.DealerWishlist` final
USING (
{{range_query}}
) staging
ON final.dealer_id = staging.dealer_id
WHEN MATCHED THEN
UPDATE SET
final.wish_list = staging.wish_list,
final.country_id = staging.country_id,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at
WHEN NOT MATCHED THEN
INSERT (
dealer_id,
wish_list,
country_id,
created_at,
updated_at,
deleted_at
) VALUES (
staging.dealer_id,
staging.wish_list,
staging.country_id,
staging.created_at,
staging.updated_at,
staging.deleted_at
)