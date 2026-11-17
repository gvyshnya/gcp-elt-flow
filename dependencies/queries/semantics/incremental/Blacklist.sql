MERGE `{{params.project_name}}.semantics_central.Blacklist` final
USING (
{{range_query}}
) staging
ON final.blacklist_id = staging.blacklist_id
WHEN MATCHED THEN
UPDATE SET
final.auction_id = staging.auction_id,
final.dealer_id = staging.dealer_id,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
blacklist_id,
auction_id,
dealer_id,
created_at,
updated_at,
deleted_at,
country_id
) VALUES (
staging.blacklist_id,
staging.auction_id,
staging.dealer_id,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.country_id
)