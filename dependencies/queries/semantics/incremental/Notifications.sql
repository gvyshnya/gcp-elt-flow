MERGE `{{params.project_name}}.semantics_central.Notifications` final
USING (
{{range_query}}
) staging
ON final.notification_id = staging.notification_id
WHEN MATCHED THEN
UPDATE SET
	final.notification_type = staging.notification_type,
	final.user_name = staging.user_name,
	final.user_id = staging.user_id, 
    final.meta = staging.meta,
	final.locale = staging.locale,
	final.platform = staging.platform, 
	final.fcm_version = staging.fcm_version,
	final.application = staging.application,
	final.created_at = staging.created_at,
	final.updated_at = staging.updated_at,
	final.deleted_at = staging.deleted_at, 
    final.country_id = staging.country_id
WHEN NOT MATCHED THEN
INSERT (
	notification_id, 
	notification_type,
	user_name,
	user_id, 
    meta,
	locale,
	platform, 
	fcm_version,
	application,
	created_at,
	updated_at,
	deleted_at, 
    country_id
) VALUES (
    staging.notification_id, 
	staging.notification_type,
	staging.user_name,
	staging.user_id, 
    staging.meta,
	staging.locale,
	staging.platform, 
	staging.fcm_version,
	staging.application,
	staging.created_at,
	staging.updated_at,
	staging.deleted_at, 
    staging.country_id
)