MERGE `{{params.project_name}}.semantics_central.CarCheckoutOptions` final
USING (
{{range_query}}
) staging
ON final.car_checkout_option_id = staging.car_checkout_option_id
WHEN MATCHED THEN
UPDATE SET
    final.car_id = staging.car_id,
    final.status = staging.status,
    final.internal_checkout_option_id = staging.internal_checkout_option_id,
    final.from_date = staging.from_date,
    final.decided_by = staging.decided_by,
    final.requested_by = staging.requested_by,
    final.created_at = staging.created_at,
    final.updated_at = staging.updated_at,
    final.deleted_at = staging.deleted_at,
    final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
    car_checkout_option_id,
    car_id,
    status,
    internal_checkout_option_id,
    from_date,
    decided_by,
    requested_by,
    created_at,
    updated_at,
    deleted_at,
    country_id
) VALUES (
    staging.car_checkout_option_id,
    staging.car_id,
    staging.status,
    staging.internal_checkout_option_id,
    staging.from_date,
    staging.decided_by,
    staging.requested_by,
    staging.created_at,
    staging.updated_at,
    staging.deleted_at,
    staging.country_id
)