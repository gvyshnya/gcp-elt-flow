MERGE `{{params.project_name}}.semantics_central.FinancingBlockingLog` final
USING (
{{range_query}}
) staging
ON final.blocking_log_id = staging.blocking_log_id
WHEN MATCHED THEN
UPDATE SET
final.customer_id = staging.customer_id,
final.mode = staging.mode,
final.blocking_type = staging.blocking_type,
final.blocking_status = staging.blocking_status,
final.blocking_reason = staging.blocking_reason,
final.blocking_comments = staging.blocking_comments,
final.created_at = staging.created_at,
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.created_by_name = staging.created_by_name,
final.created_by_id = staging.created_by_id,
final.updated_by_name = staging.updated_by_name,
final.updated_by_id = staging.updated_by_id,
final.deleted_by_name = staging.deleted_by_name,
final.deleted_by_id = staging.deleted_by_id,
final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
blocking_log_id,
customer_id,
mode,
blocking_type,
blocking_status,
blocking_reason,
blocking_comments,
created_at,
updated_at,
deleted_at,
created_by_name,
created_by_id,
updated_by_name,
updated_by_id,
deleted_by_name,
deleted_by_id,
country_id
) VALUES (
staging.blocking_log_id,
staging.customer_id,
staging.mode,
staging.blocking_type,
staging.blocking_status,
staging.blocking_reason,
staging.blocking_comments,
staging.created_at,
staging.updated_at,
staging.deleted_at,
staging.created_by_name,
staging.created_by_id,
staging.updated_by_name,
staging.updated_by_id,
staging.deleted_by_name,
staging.deleted_by_id,
staging.country_id
)