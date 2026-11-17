MERGE `{{params.project_name}}.semantics_central.CarStatus` final
USING (
{{range_query}}
) staging
ON final.car_status_id = staging.car_status_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.car_status_id = staging.car_status_id,
final.car_status_type = staging.car_status_type,
final.car_status = staging.car_status,
final.status_reason = staging.status_reason,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.created_by_id = staging.created_by_id,
final.created_by = staging.created_by,
final.updated_by_id = staging.updated_by_id,
final.updated_by = staging.updated_by,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by = staging.deleted_by
WHEN NOT MATCHED THEN
INSERT (
car_id, 
country_id,
car_status_id,
car_status_type,
car_status,
status_reason,
created_at, 
updated_at, 
deleted_at, 
created_by_id,
created_by,
updated_by_id,
updated_by,
deleted_by_id,
deleted_by
) VALUES (
staging.car_id,
staging.country_id,
staging.car_status_id,
staging.car_status_type,
staging.car_status,
staging.status_reason,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.created_by_id,
staging.created_by,
staging.updated_by_id,
staging.updated_by,
staging.deleted_by_id,
staging.deleted_by
)