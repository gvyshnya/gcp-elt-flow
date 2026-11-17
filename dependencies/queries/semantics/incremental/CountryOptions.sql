MERGE `{{params.project_name}}.semantics_central.CountryOptions` final
USING (
{{range_query}}
) staging
ON final.country_options_id = staging.country_options_id
WHEN MATCHED THEN
UPDATE SET
final.country_options_type = staging.country_options_type,
final.country_options_name = staging.country_options_name,
final.country_id = staging.country_id,
final.bi_mapping = staging.bi_mapping,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at
WHEN NOT MATCHED THEN
INSERT (
country_options_id,
country_options_type,
country_options_name,
country_id,
bi_mapping,
created_at,
updated_at,
deleted_at
) VALUES (
staging.country_options_id,
staging.country_options_type,
staging.country_options_name,
staging.country_id,
staging.bi_mapping,
staging.created_at,
staging.updated_at,
staging.deleted_at
)