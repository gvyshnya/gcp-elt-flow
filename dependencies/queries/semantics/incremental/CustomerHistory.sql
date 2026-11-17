MERGE `{{params.project_name}}.semantics_central.CustomerHistory` final
USING (
{{range_query}}
) staging
ON final.customer_history_id = staging.customer_history_id
WHEN MATCHED THEN
UPDATE SET
    final.customer_id = staging.customer_id,
    final.customer_history_type = staging.customer_history_type,
    final.customer_history_type_id = staging.customer_history_type_id,
    final.field = staging.field,
    final.value = staging.value,
    final.updated_by_id = staging.updated_by_id,
    final.updated_by = staging.updated_by,
    final.operation = staging.operation,
    final.created_at = staging.created_at,
    final.updated_at = staging.updated_at,  
    final.deleted_at = staging.deleted_at,
    final.country_id = staging.country_id,
    final.partition_date = staging.partition_date
WHEN NOT MATCHED THEN
INSERT (
    customer_history_id,
    customer_id,
    customer_history_type,
    customer_history_type_id,
    field,
    value,
    updated_by_id,
    updated_by,
    operation,
    created_at,
    updated_at,
    deleted_at,
    country_id,
    partition_date
) VALUES (
    staging.customer_history_id,
    staging.customer_id,
    staging.customer_history_type,
    staging.customer_history_type_id,
    staging.field,
    staging.value,
    staging.updated_by_id,
    staging.updated_by,
    staging.operation,
    staging.created_at,
    staging.updated_at,
    staging.deleted_at,
    staging.country_id,
    staging.partition_date
)