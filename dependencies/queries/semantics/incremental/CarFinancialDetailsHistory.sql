MERGE `{{params.project_name}}.semantics_central.CarFinancialDetailsHistory` final
USING (
{{range_query}}
) staging
ON final.financial_detail_id = staging.financial_detail_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.financial_detail_operation_type = staging.financial_detail_operation_type,
final.financial_detail_operation = staging.financial_detail_operation,
final.affected_field = staging.affected_field,
final.financial_detail_operation_value = staging.financial_detail_operation_value,
final.updated_by = staging.updated_by,
final.updated_by_email = staging.updated_by_email,
final.financial_detail_created = staging.financial_detail_created,
final.financial_detail_last_modified = staging.financial_detail_last_modified,
final.deleted_at = staging.deleted_at,
final.partition_date = staging.partition_date
WHEN NOT MATCHED THEN
INSERT (
financial_detail_id,
car_id,
country_id,
financial_detail_operation_type,
financial_detail_operation,
affected_field,
financial_detail_operation_value,
updated_by,
updated_by_email,
financial_detail_created,
financial_detail_last_modified,
deleted_at,
partition_date
) VALUES (
staging.financial_detail_id,
staging.car_id,
staging.country_id,
staging.financial_detail_operation_type,
staging.financial_detail_operation,
staging.affected_field,
staging.financial_detail_operation_value,
staging.updated_by,
staging.updated_by_email,
staging.financial_detail_created,
staging.financial_detail_last_modified,
staging.deleted_at,
staging.partition_date
)