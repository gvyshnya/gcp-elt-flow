SELECT 
fbl.blocking_log_id,
fbl.customer_id,
fbl.mode,
fbl.blocking_type,
fbl.blocking_status,
fbl.blocking_reason,
fbl.blocking_comments,
DATETIME(fbl.created_at, cmt.country_timezone) as created_at,
DATETIME(fbl.updated_at, cmt.country_timezone) as updated_at,
DATETIME(fbl.deleted_at, cmt.country_timezone) as deleted_at,
fbl.created_by_name,
fbl.created_by_id,
fbl.updated_by_name,
fbl.updated_by_id,
fbl.deleted_by_name,
fbl.deleted_by_id,
fbl.country_id
FROM `{{params.project_name}}.staging.FinancingBlockingLog` fbl
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(fbl.country_id) = cmt.country_id
WHERE fbl.updated_at >= '{{params.start_ts}}' AND fbl.updated_at < '{{params.end_ts}}'