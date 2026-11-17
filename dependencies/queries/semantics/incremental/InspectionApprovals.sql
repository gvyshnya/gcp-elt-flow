MERGE `{{params.project_name}}.semantics_central.InspectionApprovals` final
USING (
{{range_query}}
) staging
ON final.inspection_approval_id = staging.inspection_approval_id
WHEN MATCHED THEN
UPDATE SET
final.country_id = staging.country_id,
final.inspection_id = staging.inspection_id, 
final.inspection_approval_version = staging.inspection_approval_version,
final.quality_check_status = staging.quality_check_status,
final.quality_check_rating = staging.quality_check_rating,
final.approval_reason = staging.approval_reason,
final.approval_comments = staging.approval_comments,
final.created_at = staging.created_at, 
final.updated_at = staging.updated_at,
final.deleted_at = staging.deleted_at,
final.updated_by_name = staging.updated_by_name,
final.updated_by_id = staging.updated_by_id
WHEN NOT MATCHED THEN
INSERT (
inspection_approval_id, 
country_id,
inspection_id, 
inspection_approval_version,
quality_check_status,
quality_check_rating,
approval_reason,
approval_comments,
created_at, 
updated_at,
deleted_at,
updated_by_name,
updated_by_id
) VALUES (
staging.inspection_approval_id, 
staging.country_id,
staging.inspection_id, 
staging.inspection_approval_version,
staging.quality_check_status,
staging.quality_check_rating,
staging.approval_reason,
staging.approval_comments,
staging.created_at, 
staging.updated_at,
staging.deleted_at,
staging.updated_by_name,
staging.updated_by_id
)