SELECT 
fc.cancellation_id,
fc.customer_id,
fc.loan_id,
fc.reason,
fc.customer_comments,
DATETIME(fc.cancelled_at, cmt.country_timezone) as cancelled_at,
fc.officer_comments,
fc.principal_utr,
fc.interest_utr,
fc.charge_utr,
DATETIME(fc.created_at, cmt.country_timezone) as created_at,
DATETIME(fc.updated_at, cmt.country_timezone) as updated_at,
DATETIME(fc.deleted_at, cmt.country_timezone) as deleted_at,
fc.created_by_name,
fc.created_by_id,
fc.updated_by_name,
fc.updated_by_id,
fc.deleted_by_name,
fc.deleted_by_id,
fc.country_id
FROM `{{params.project_name}}.staging.FinancingCancellations` fc
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(fc.country_id) = cmt.country_id
WHERE fc.updated_at >= '{{params.start_ts}}' AND fc.updated_at < '{{params.end_ts}}'