MERGE `{{params.project_name}}.semantics_central.AutoBids` final
USING (
{{range_query}}
) staging
ON final.auto_bid_id = staging.auto_bid_id
WHEN MATCHED THEN
UPDATE SET
final.dealer_id = staging.dealer_id,
final.auction_id = staging.auction_id,
final.dealer_email = staging.dealer_email,
final.auto_bid_type = staging.auto_bid_type,
final.max_bid_sum = staging.max_bid_sum,
final.max_bid_sum_usd = staging.max_bid_sum_usd,
final.current_price = staging.current_price,
final.current_price_usd = staging.current_price_usd,
final.is_valid = staging.is_valid,
final.country_id = staging.country_id,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at
WHEN NOT MATCHED THEN
INSERT (
auto_bid_id,
dealer_id,
auction_id,
dealer_email,
auto_bid_type,
max_bid_sum,
max_bid_sum_usd,
current_price,
current_price_usd,
is_valid,
country_id,
created_at,
updated_at,
deleted_at
) VALUES (
staging.auto_bid_id,
staging.dealer_id,
staging.auction_id,
staging.dealer_email,
staging.auto_bid_type,
staging.max_bid_sum,
staging.max_bid_sum_usd,
staging.current_price,
staging.current_price_usd,
staging.is_valid,
staging.country_id,
staging.created_at,
staging.updated_at,
staging.deleted_at
)