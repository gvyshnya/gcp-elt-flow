SELECT
    country_options_id,
    country_options_type,
    country_options_name,
    country_id,
    bi_mapping,
    DATETIME(created_at, cmt.country_timezone) as created_at,
    DATETIME(updated_at, cmt.country_timezone) as updated_at,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at
FROM `{{params.project_name}}.staging.CountryOptions`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'