SELECT 
    ia.id as 'inspection_approval_id', 
    ia.country as 'country_id',
    ia.inspectionId as 'inspection_id', 
    ia.version as 'inspection_approval_version',
    ia.qualityCheckStatus as 'quality_check_status',
    ia.qualityCheckRating as 'quality_check_rating',
    ia.reason as 'approval_reason',
    ia.comments as 'approval_comments',
    UNIX_TIMESTAMP(ia.createdAt) as 'created_at', 
	UNIX_TIMESTAMP(ia.updatedAt) as 'updated_at', 
    UNIX_TIMESTAMP(ia.deletedAt) as 'deleted_at', 
    ia.updatedByEmail as 'updated_by_name',
    ia.updatedById as 'updated_by_id'
FROM fcgInspection.approval ia 
where ia.updatedAt >= '{{params.start_ts}}' and ia.updatedAt < '{{params.end_ts}}'