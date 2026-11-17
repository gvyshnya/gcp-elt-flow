MERGE `{{params.project_name}}.semantics_central.AuctionGroups` final
USING (
{{range_query}}
) staging
ON final.group_id = staging.group_id
WHEN MATCHED THEN
UPDATE SET
final.group_name = staging.group_name, 
final.group_description = staging.group_description, 
final.country_id = staging.country_id, 
final.group_hide = staging.group_hide, 
final.group_created_by_id = staging.group_created_by_id, 
final.group_created_by = staging.group_created_by, 
final.group_created_at = staging.group_created_at,
final.group_updated_at = staging.group_updated_at, 
final.group_deleted_at = staging.group_deleted_at
WHEN NOT MATCHED THEN
INSERT (
group_id, 
group_name, 
group_description, 
country_id, 
group_hide, 
group_created_by_id, 
group_created_by, 
group_created_at,
group_updated_at, 
group_deleted_at
) VALUES (
staging.group_id, 
staging.group_name, 
staging.group_description, 
staging.country_id, 
staging.group_hide, 
staging.group_created_by_id, 
staging.group_created_by, 
staging.group_created_at,
staging.group_updated_at, 
staging.group_deleted_at
)