SELECT 
    adg.id as 'dealer_group_id',
    adg.dealerId as 'dealer_id', 
    adg.groupId as 'group_id',  
    UNIX_TIMESTAMP(adg.createdAt) as 'group_created_at', 
    UNIX_TIMESTAMP(adg.updatedAt) as 'group_updated_at', 
	UNIX_TIMESTAMP(adg.deletedAt) as 'group_deleted_at', 
    g.country as 'country_id'
FROM fcgAuction.dealerGroup adg 
JOIN fcgAuction.group g ON g.id = adg.groupId
where adg.updatedAt >= '{{params.start_ts}}' and adg.updatedAt < '{{params.end_ts}}'