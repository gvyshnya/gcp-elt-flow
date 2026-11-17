SELECT 
	notification_id, 
	notification_type,
	user_name,
	user_id, 
    meta,
	locale,
	platform, 
	fcm_version,
	application,
	DATETIME(n.created_at, cmt.country_timezone) as created_at,
	DATETIME(n.updated_at, cmt.country_timezone) as updated_at,
	DATETIME(n.deleted_at, cmt.country_timezone) as deleted_at,
    country_id
FROM `{{params.project_name}}.staging.Notifications` n
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'