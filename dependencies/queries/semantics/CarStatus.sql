SELECT
    car_status_id,
    car_id,
    country_id,
    car_status_type,
    car_status,
    status_reason,
    DATETIME(created_at, cmt.country_timezone) as created_at, 
    DATETIME(updated_at, cmt.country_timezone) as updated_at, 
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at, 
    created_by_id,
    created_by,
    updated_by_id,
    updated_by,
    deleted_by_id,
    deleted_by 
FROM `{{params.project_name}}.staging.CarStatus`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'