SELECT
    customer_history_id, 
    customer_id,
    customer_history_type,
    customer_history_type_id,
    field,
    value,
    updated_by_id,
    updated_by,
    operation,
    DATETIME(created_at, cmt.country_timezone) as created_at, 
    DATETIME(updated_at, cmt.country_timezone) as updated_at,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    country_id,
    date(DATETIME(created_at, cmt.country_timezone)) as partition_date
FROM `{{params.project_name}}.staging.CustomerHistory`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'