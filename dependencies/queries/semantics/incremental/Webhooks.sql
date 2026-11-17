MERGE `{{params.project_name}}.semantics_central.Webhooks` final
USING (
{{range_query}}
) staging
ON final.webhook_id = staging.webhook_id
WHEN MATCHED THEN
UPDATE SET
final.webhook_name = staging.webhook_name,
final.webhook_url = staging.webhook_url,
final.nonce = staging.nonce,
final.webhook_description = staging.webhook_description,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.created_by_name = staging.created_by_name,
final.updated_by_name = staging.updated_by_name,
final.deleted_by_name = staging.deleted_by_name,
final.created_by_id = staging.created_by_id,
final.updated_by_id = staging.updated_by_id,
final.deleted_by_id = staging.deleted_by_id,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
webhook_id,
webhook_name,
webhook_url,
nonce,
webhook_description,
created_at,
updated_at,
deleted_at,
created_by_name,
updated_by_name,
deleted_by_name,
created_by_id,
updated_by_id,
deleted_by_id,
country_id
) VALUES (
staging.webhook_id,
staging.webhook_name,
staging.webhook_url,
staging.nonce,
staging.webhook_description,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.created_by_name,
staging.updated_by_name,
staging.deleted_by_name,
staging.created_by_id,
staging.updated_by_id,
staging.deleted_by_id,
staging.country_id
)