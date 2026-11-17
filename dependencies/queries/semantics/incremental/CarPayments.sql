MERGE `{{params.project_name}}.semantics_central.CarPayments` final
USING (
{{range_query}}
) staging
ON final.payment_id = staging.payment_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.payment_type = staging.payment_type,
final.payment_subtype = staging.payment_subtype,
final.payment_sum = staging.payment_sum,
final.payment_sum_usd = staging.payment_sum_usd,
final.payment_comment = staging.payment_comment,
final.country_id = staging.country_id,
final.transaction_date = staging.transaction_date,
final.payment_created = staging.payment_created,
final.payment_last_modified = staging.payment_last_modified,
final.deleted_at = staging.deleted_at
WHEN NOT MATCHED THEN
INSERT (
payment_id,
car_id,
payment_type,
payment_subtype,
payment_sum,
payment_sum_usd,
payment_comment,
country_id,
transaction_date,
payment_created,
payment_last_modified,
deleted_at
) VALUES (
staging.payment_id,
staging.car_id,
staging.payment_type,
staging.payment_subtype,
staging.payment_sum,
staging.payment_sum_usd,
staging.payment_comment,
staging.country_id,
staging.transaction_date,
staging.payment_created,
staging.payment_last_modified,
staging.deleted_at
)