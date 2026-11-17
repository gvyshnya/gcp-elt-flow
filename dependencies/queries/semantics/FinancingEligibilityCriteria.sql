SELECT 
elc.eligibility_criteria_id,
elc.dealer_id,
elc.unjust_car_rejection,  --int
elc.account_blocked,      --int
elc.payment_delayed,      --int
DATETIME(elc.created_at, cmt.country_timezone) as created_at,
DATETIME(elc.updated_at, cmt.country_timezone) as updated_at,
DATETIME(elc.deleted_at, cmt.country_timezone) as deleted_at,
elc.created_by_name,
elc.created_by_id,
elc.updated_by_name,
elc.updated_by_id,
elc.deleted_by_name,
elc.deleted_by_id,
elc.country_id
FROM `{{params.project_name}}.staging.FinancingEligibilityCriteria` elc
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(elc.country_id) = cmt.country_id
WHERE elc.updated_at >= '{{params.start_ts}}' AND elc.updated_at < '{{params.end_ts}}'