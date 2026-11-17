SELECT
fec.financing_eligibility_check_id,
fec.loan_id,
fec.loan_from,
fec.loan_to,
fec.is_overdue_check,
fec.is_credit_limit_check,
fec.is_customer_manually_freezed_check,
fec.is_ltv_check,
fec.is_customer_financing_status_check,
fec.is_admin_status_check,
DATETIME(fec.created_at, cmt.country_timezone) as created_at,
DATETIME(fec.updated_at, cmt.country_timezone) as updated_at,
DATETIME(fec.deleted_at, cmt.country_timezone) as deleted_at,
fec.created_by_name,
fec.created_by_id,
fec.updated_by_name, 
fec.updated_by_id,
fec.deleted_by_name, 
fec.deleted_by_id,
fec.unjust_car_rejection,
fec.account_blocked,
fec.payment_delayed,
TRIM(fec.country_id) as country_id
FROM `{{params.project_name}}.staging.FinancingEligibilityCheck` fec
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(fec.country_id) = cmt.country_id
WHERE fec.updated_at >= '{{params.start_ts}}' AND fec.updated_at < '{{params.end_ts}}'