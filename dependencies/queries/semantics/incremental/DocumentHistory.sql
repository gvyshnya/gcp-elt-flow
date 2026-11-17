MERGE `{{params.project_name}}.semantics_central.DocumentHistory` final
USING (
{{range_query}}
) staging
ON final.document_history_id = staging.document_history_id
WHEN MATCHED THEN
UPDATE SET
    final.car_id = staging.car_id,
    final.document_type_id = staging.document_type_id,
    final.document_history_type = staging.document_history_type, 
    final.document_field = staging.document_field,
    final.document_field_value = staging.document_field_value, 
    final.operation = staging.operation,
    final.updated_by_id = staging.updated_by_id,
    final.updated_by = staging.updated_by,
    final.created_at = staging.created_at,
    final.updated_at = staging.updated_at,
    final.deleted_at = staging.deleted_at,
    final.country_id = staging.country_id,
    final.partition_date = staging.partition_date
WHEN NOT MATCHED THEN
INSERT (
    document_history_id,
    car_id,
    document_type_id,
    document_history_type, 
    document_field,
    document_field_value, 
    operation,
    updated_by_id,
    updated_by,
    created_at,
    updated_at,
    deleted_at,
    country_id,
    partition_date
) VALUES (
    staging.document_history_id,
    staging.car_id,
    staging.document_type_id,
    staging.document_history_type, 
    staging.document_field,
    staging.document_field_value, 
    staging.operation,
    staging.updated_by_id,
    staging.updated_by,
    staging.created_at,
    staging.updated_at,
    staging.deleted_at,
    staging.country_id,
    staging.partition_date
)