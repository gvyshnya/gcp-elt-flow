MERGE `{{params.project_name}}.semantics_central.Bids` final
USING (
{{range_query}}
) staging
ON final.bid_id = staging.bid_id
WHEN MATCHED THEN
UPDATE SET
final.bid_datetime = staging.bid_datetime,
final.bid_last_modified = staging.bid_last_modified,
final.bid_status = staging.bid_status,
final.bid_placed_on_behalf = staging.bid_placed_on_behalf,
final.deleted_at = staging.deleted_at,
final.is_internal = staging.is_internal,
final.bid_type = staging.bid_type,
final.dealer_id = staging.dealer_id,
final.auction_id = staging.auction_id,
final.country_id = staging.country_id,
final.bid_amount = staging.bid_amount,
final.bid_amount_usd = staging.bid_amount_usd
WHEN NOT MATCHED THEN
INSERT (
bid_id,
bid_datetime,
bid_last_modified,
bid_status,
bid_placed_on_behalf,
deleted_at,
is_internal,
bid_type,
dealer_id,
auction_id,
country_id,
bid_amount,
bid_amount_usd
) VALUES (
staging.bid_id,
staging.bid_datetime,
staging.bid_last_modified,
staging.bid_status,
staging.bid_placed_on_behalf,
staging.deleted_at,
staging.is_internal,
staging.bid_type,
staging.dealer_id,
staging.auction_id,
staging.country_id,
staging.bid_amount,
staging.bid_amount_usd
)