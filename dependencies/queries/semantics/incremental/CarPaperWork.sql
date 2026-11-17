MERGE `{{params.project_name}}.semantics_central.CarPaperWork` final
USING (
{{range_query}}
) staging
ON final.car_paperwork_id = staging.car_paperwork_id
WHEN MATCHED THEN
UPDATE SET
    final.car_id = staging.car_id,
    final.country_id = staging.country_id,
    final.doc_status = staging.doc_status,
    final.doc_handover_to_buyer_status = staging.doc_handover_to_buyer_status,
    final.doc_location = staging.doc_location,
    final.doc_comment = staging.doc_comment, 
    final.created_at = staging.created_at, 
    final.updated_at = staging.updated_at, 
    final.deleted_at = staging.deleted_at, 
    final.created_by_id = staging.created_by_id,
    final.created_by = staging.created_by,
    final.updated_by_id = staging.updated_by_id,
    final.updated_by = staging.updated_by,
    final.deleted_by_id = staging.deleted_by_id,
    final.deleted_by = staging.deleted_by,
    final.doc_handover_from_seller_date = staging.doc_handover_from_seller_date, 
    final.doc_handover_to_buyer_date = staging.doc_handover_to_buyer_date
WHEN NOT MATCHED THEN
INSERT (
    car_paperwork_id,
    car_id,
    country_id,
    doc_status,
    doc_handover_to_buyer_status,
    doc_location,
    doc_comment, 
    created_at, 
    updated_at, 
    deleted_at, 
    created_by_id,
    created_by,
    updated_by_id,
    updated_by,
    deleted_by_id,
    deleted_by,
    doc_handover_from_seller_date, 
    doc_handover_to_buyer_date
) VALUES (
    staging.car_paperwork_id,
    staging.car_id,
    staging.country_id,
    staging.doc_status,
    staging.doc_handover_to_buyer_status,
    staging.doc_location,
    staging.doc_comment, 
    staging.created_at, 
    staging.updated_at, 
    staging.deleted_at, 
    staging.created_by_id,
    staging.created_by,
    staging.updated_by_id,
    staging.updated_by,
    staging.deleted_by_id,
    staging.deleted_by,
    staging.doc_handover_from_seller_date, 
    staging.doc_handover_to_buyer_date
)