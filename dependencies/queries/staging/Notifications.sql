SELECT 
	id as 'notification_id', 
	type as 'notification_type',
	user as 'user_name',
	userId as 'user_id', 
    meta,
	locale,
	platform,
	CAST(fcmVersion as CHAR(50)) as 'fcm_version',
	application,
	UNIX_TIMESTAMP(createdAt) as 'created_at',
	UNIX_TIMESTAMP(updatedAt) as 'updated_at',
	UNIX_TIMESTAMP(deletedAt) as 'deleted_at', 
    UPPER(market) as 'country_id'
FROM fcgContact.notification n
WHERE n.updatedAt >= '{{params.start_ts}}' and n.updatedAt < '{{params.end_ts}}'