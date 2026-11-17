MERGE `{{params.project_name}}.semantics_central.InternalUsers` final
USING (
{{range_query}}
) staging
ON final.user_id = staging.user_id
WHEN MATCHED THEN
UPDATE SET
final.user_name = staging.user_name,
final.user_email = staging.user_email,
final.user_created = staging.user_created,
final.user_last_modified = staging.user_last_modified,
final.user_company_name = staging.user_company_name,
final.deleted_at = staging.deleted_at,
final.country_id = staging.country_id,
final.user_groups = staging.user_groups,
final.meta_info = staging.meta_info
WHEN NOT MATCHED THEN
INSERT (
user_id,
user_name,
user_email,
user_created,
user_last_modified,
user_company_name,
deleted_at,
country_id,
user_groups,
meta_info
) VALUES (
staging.user_id,
staging.user_name,
staging.user_email,
staging.user_created,
staging.user_last_modified,
staging.user_company_name,
staging.deleted_at,
staging.country_id,
staging.user_groups,
staging.meta_info
)