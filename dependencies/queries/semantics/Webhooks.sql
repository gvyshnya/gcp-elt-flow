SELECT
w.webhook_id,
w.webhook_name,
w.webhook_url,
w.nonce,
w.webhook_description,
DATETIME(w.created_at, cmt.country_timezone) as created_at,
DATETIME(w.updated_at, cmt.country_timezone) as updated_at,
DATETIME(w.deleted_at, cmt.country_timezone) as deleted_at,
w.created_by_name,
w.updated_by_name,
w.deleted_by_name,
w.created_by_id,
w.updated_by_id,
w.deleted_by_id,
TRIM(w.country_id) as country_id
FROM `{{params.project_name}}.staging.Webhooks` w
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(w.country_id) = cmt.country_id
WHERE w.updated_at >= '{{params.start_ts}}' AND w.updated_at < '{{params.end_ts}}'