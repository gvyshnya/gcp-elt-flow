MERGE `{{params.project_name}}.semantics_central.FinancingEligibilityCriteria` final
USING (
{{range_query}}
) staging
ON final.eligibility_criteria_id = staging.eligibility_criteria_id
WHEN MATCHED THEN
UPDATE SET
final.dealer_id = staging.dealer_id,
final.unjust_car_rejection = staging.unjust_car_rejection,  --int
final.account_blocked = staging.account_blocked,      --int
final.payment_delayed = staging.payment_delayed,      --int
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
eligibility_criteria_id,
dealer_id,
unjust_car_rejection,  --int
account_blocked,      --int
payment_delayed,      --int
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
staging.eligibility_criteria_id,
staging.dealer_id,
staging.unjust_car_rejection,  --int
staging.account_blocked,      --int
staging.payment_delayed,      --int
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