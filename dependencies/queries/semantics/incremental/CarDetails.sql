MERGE `{{params.project_name}}.semantics_central.CarDetails` final
USING (
{{range_query}}
) staging
ON final.car_detail_id = staging.car_detail_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id, 
final.attribute_name = staging.attribute_name,
final.attribute_value = staging.attribute_value,
final.created_at = staging.created_at,
final.created_by_id = staging.created_by_id,
final.created_by_name = staging.created_by_name,
final.updated_at = staging.updated_at,
final.updated_by_id = staging.updated_by_id,
final.updated_by_name = staging.updated_by_name,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by_name = staging.deleted_by_name
WHEN NOT MATCHED THEN
INSERT (
car_detail_id, 
car_id,
country_id, 
attribute_name,
attribute_value,
created_at,
created_by_id,
created_by_name,
updated_at,
updated_by_id,
updated_by_name,
deleted_at,
deleted_by_id,
deleted_by_name
) VALUES (
staging.car_detail_id, 
staging.car_id,
staging.country_id, 
staging.attribute_name,
staging.attribute_value,
staging.created_at,
staging.created_by_id,
staging.created_by_name,
staging.updated_at,
staging.updated_by_id,
staging.updated_by_name,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by_name
)