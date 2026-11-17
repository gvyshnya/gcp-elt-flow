SELECT
iu.user_id,
iu.user_name,
iu.user_email,
DATETIME(iu.user_created, cmt.country_timezone) as user_created,
DATETIME(iu.user_last_modified, cmt.country_timezone) as user_last_modified,
iu.user_company_name,
iu.user_groups,
DATETIME(iu.deleted_at, cmt.country_timezone) as deleted_at,
iu.meta_info,
iu.country_id
FROM `{{params.project_name}}.staging.Drivers` iu
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where iu.user_last_modified >= '{{params.start_ts}}' and iu.user_last_modified < '{{params.end_ts}}'