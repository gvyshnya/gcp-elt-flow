SELECT
    ia.inspection_approval_id, 
    ia.country_id,
    ia.inspection_id, 
    ia.inspection_approval_version,
    ia.quality_check_status,
    ia.quality_check_rating,
    ia.approval_reason,
    ia.approval_comments,
    DATETIME(ia.created_at, cmt.country_timezone) as created_at, 
    DATETIME(ia.updated_at, cmt.country_timezone) as updated_at,
    DATETIME(ia.deleted_at, cmt.country_timezone) as deleted_at,
    ia.updated_by_name,
    ia.updated_by_id
FROM `{{params.project_name}}.staging.InspectionApprovals` ia
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)
WHERE ia.updated_at >= '{{params.start_ts}}' AND ia.updated_at < '{{params.end_ts}}'