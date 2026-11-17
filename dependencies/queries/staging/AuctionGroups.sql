SELECT 
    ag.id as 'group_id', 
    ag.name as 'group_name', 
    ag.description as 'group_description',
    ag.country as 'country_id',
    ag.hide as 'group_hide', 
    ag.createdById as 'group_created_by_id',
    ag.createdByName as 'group_created_by', 
    UNIX_TIMESTAMP(ag.createdAt) as 'group_created_at', 
	UNIX_TIMESTAMP(ag.updatedAt) as 'group_updated_at', 
    UNIX_TIMESTAMP(ag.deletedAt) as 'group_deleted_at' 
FROM fcgAuction.group ag 
where ag.updatedAt >= '{{params.start_ts}}' and ag.updatedAt < '{{params.end_ts}}'