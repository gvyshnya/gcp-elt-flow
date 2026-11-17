SELECT 
lc.loan_id,
lc.contract_info,
DATETIME(lc.created_at, cmt.country_timezone) as created_at,
DATETIME(lc.updated_at, cmt.country_timezone) as updated_at,
DATETIME(lc.deleted_at, cmt.country_timezone) as deleted_at,
lc.created_by_name,
lc.created_by_id,
lc.updated_by_name,
lc.updated_by_id,
lc.deleted_by_name,
lc.deleted_by_id,
lc.country_id
FROM `{{params.project_name}}.staging.FinancingLoanContracts` lc
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(lc.country_id) = cmt.country_id
WHERE lc.updated_at >= '{{params.start_ts}}' AND lc.updated_at < '{{params.end_ts}}'