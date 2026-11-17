MERGE `{{params.project_name}}.semantics_central.CarChangesHistory` final
USING (
{{range_query}}
) staging
ON final.car_history_change_id = staging.car_history_change_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.car_history_change_type_id = staging.car_history_change_type_id,
final.car_history_change_type = staging.car_history_change_type,
final.car_history_change_operation = staging.car_history_change_operation,
final.affected_field = staging.affected_field,
final.car_history_change_value = staging.car_history_change_value,
final.updated_by_email = staging.updated_by_email,
final.car_history_change_created = staging.car_history_change_created,
final.car_history_change_last_modified = staging.car_history_change_last_modified,
final.deleted_at = staging.deleted_at,
final.partition_date = staging.partition_date
WHEN NOT MATCHED THEN
INSERT (
car_history_change_id,
car_id,
country_id,
car_history_change_type_id,
car_history_change_type,
car_history_change_operation,
affected_field,
car_history_change_value,
updated_by_email,
car_history_change_created,
car_history_change_last_modified,
deleted_at,
partition_date
) VALUES (
staging.car_history_change_id,
staging.car_id,
staging.country_id,
staging.car_history_change_type_id,
staging.car_history_change_type,
staging.car_history_change_operation,
staging.affected_field,
staging.car_history_change_value,
staging.updated_by_email,
staging.car_history_change_created,
staging.car_history_change_last_modified,
staging.deleted_at,
staging.partition_date
)