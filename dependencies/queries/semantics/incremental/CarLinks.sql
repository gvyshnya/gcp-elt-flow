MERGE `{{params.project_name}}.semantics_central.CarLinks` final
USING (
{{range_query}}
) staging
ON final.link_id = staging.link_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.swapped_car_id = staging.swapped_car_id,
final.country_swapped_car = staging.country_swapped_car,
final.link_type = staging.link_type,
final.created_at = staging.created_at,
final.created_by_id = staging.created_by_id,
final.created_by_name = staging.created_by_name,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by_name = staging.deleted_by_name
WHEN NOT MATCHED THEN
INSERT (
link_id, 
car_id,
country_id, 
swapped_car_id,
country_swapped_car,
link_type,
created_at,
created_by_id,
created_by_name,
updated_at,
deleted_at,
deleted_by_id,
deleted_by_name
) VALUES (
staging.link_id, 
staging.car_id,
staging.country_id, 
staging.swapped_car_id,
staging.country_swapped_car,
staging.link_type,
staging.created_at,
staging.created_by_id,
staging.created_by_name,
staging.updated_at,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by_name
)