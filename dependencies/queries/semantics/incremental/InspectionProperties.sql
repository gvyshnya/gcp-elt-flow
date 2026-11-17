MERGE `{{params.project_name}}.semantics_central.InspectionProperties` final
USING (
{{range_query}}
) staging
ON final.inspection_property_id = staging.inspection_property_id
WHEN MATCHED THEN
UPDATE SET
final.inspection_id = staging.inspection_id,
final.property_name = staging.property_name,
final.property_value = staging.property_value,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
inspection_property_id,
inspection_id,
property_name,
property_value,
created_at,
updated_at,
deleted_at,
country_id
) VALUES (
staging.inspection_property_id,
staging.inspection_id,
staging.property_name,
staging.property_value,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.country_id
)