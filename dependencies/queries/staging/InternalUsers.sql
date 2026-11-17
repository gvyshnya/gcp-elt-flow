SELECT u.id as 'user_id', 
CONCAT(u.firstname, ' ', u.lastname) as 'user_name', 
u.email as 'user_email', 
UNIX_TIMESTAMP(u.createdAt) as 'user_created', 
UNIX_TIMESTAMP(u.updatedAt) as 'user_last_modified', 
u.metaInfo ->> '$.companyName' as 'user_company_name',
UNIX_TIMESTAMP(u.deletedAt) as 'deleted_at',
u.userGroups as 'user_groups',
u.metaInfo as 'meta_info',  
(CASE 
	WHEN
		u.country IS NOT NULL
	THEN u.country 
    ELSE UPPER(RIGHT(u.userGroups, 2))
END) AS 'country_id'

FROM fcgAuth.user u
WHERE
	u.userClass = 'INTERNAL'
    AND u.updatedAt >= '{{params.start_ts}}' and u.updatedAt < '{{params.end_ts}}'