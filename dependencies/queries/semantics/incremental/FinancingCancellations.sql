MERGE `{{params.project_name}}.semantics_central.FinancingCancellations` final
USING (
{{range_query}}
) staging
ON final.cancellation_id = staging.cancellation_id
WHEN MATCHED THEN
UPDATE SET
final.customer_id = staging.customer_id,
final.loan_id = staging.loan_id,
final.reason = staging.reason,
final.customer_comments = staging.customer_comments,
final.cancelled_at = staging.cancelled_at,
final.officer_comments = staging.officer_comments,
final.principal_utr = staging.principal_utr,
final.interest_utr = staging.interest_utr,
final.charge_utr = staging.charge_utr,
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
cancellation_id,
customer_id,
loan_id,
reason,
customer_comments,
cancelled_at,
officer_comments,
principal_utr,
interest_utr,
charge_utr,
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
staging.cancellation_id,
staging.customer_id,
staging.loan_id,
staging.reason,
staging.customer_comments,
staging.cancelled_at,
staging.officer_comments,
staging.principal_utr,
staging.interest_utr,
staging.charge_utr,
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