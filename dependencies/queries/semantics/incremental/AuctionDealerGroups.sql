MERGE `{{params.project_name}}.semantics_central.AuctionDealerGroups` final
USING (
{{range_query}}
) staging
ON final.dealer_group_id = staging.dealer_group_id
WHEN MATCHED THEN
UPDATE SET
final.dealer_id = staging.dealer_id,
final.group_id = staging.group_id,
final.group_created_at = staging.group_created_at,
final.group_updated_at = staging.group_updated_at,
final.group_deleted_at = staging.group_deleted_at,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
dealer_group_id,    
dealer_id,
group_id,
group_created_at,
group_updated_at,
group_deleted_at,
country_id
) VALUES (
staging.dealer_group_id,
staging.dealer_id,
staging.group_id,
staging.group_created_at,
staging.group_updated_at,
staging.group_deleted_at,
staging.country_id
)