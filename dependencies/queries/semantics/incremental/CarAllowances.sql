MERGE `{{params.project_name}}.semantics_central.CarAllowances` final
USING (
{{range_query}}
) staging
ON final.car_allowance_id = staging.car_allowance_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.allowance_sum = staging.allowance_sum,
final.allowance_created_usd = staging.allowance_created_usd,
final.allowance_type = staging.allowance_type,
final.allowance_comment = staging.allowance_comment,
final.allowance_created = staging.allowance_created,
final.allowance_created_by_id = staging.allowance_created_by_id,
final.allowance_created_by = staging.allowance_created_by,
final.allowance_last_modified = staging.allowance_last_modified,
final.allowance_last_modified_by_id = staging.allowance_last_modified_by_id,
final.allowance_last_modified_by = staging.allowance_last_modified_by,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by = staging.deleted_by
WHEN NOT MATCHED THEN
INSERT (
car_allowance_id,
car_id,
country_id,
allowance_sum,
allowance_created_usd,
allowance_type,
allowance_comment,
allowance_created,
allowance_created_by_id,
allowance_created_by,
allowance_last_modified,
allowance_last_modified_by_id,
allowance_last_modified_by,
deleted_at,
deleted_by_id,
deleted_by
) VALUES (
staging.car_allowance_id,
staging.car_id,
staging.country_id,
staging.allowance_sum,
staging.allowance_created_usd,
staging.allowance_type,
staging.allowance_comment,
staging.allowance_created,
staging.allowance_created_by_id,
staging.allowance_created_by,
staging.allowance_last_modified,
staging.allowance_last_modified_by_id,
staging.allowance_last_modified_by,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by
)