SELECT
    transit_id,
    transit_job_id,
    car_id,
    country_id,
    transit_type,
    transit_status,
    transit_start_location,
    transit_end_location,
    transit_driver,
    transit_driver_id,
    transit_driver_company,
    start_mileage,
    end_mileage,
    transit_comment,
    DATETIME(transit_start_time, cmt.country_timezone) as transit_start_time,
    DATETIME(transit_end_time, cmt.country_timezone) as transit_end_time,
    DATETIME(transit_created_at, cmt.country_timezone) as transit_created_at,
    transit_created_by_id,
    transit_created_by,
    DATETIME(transit_last_modified, cmt.country_timezone) as transit_last_modified,
    transit_last_modified_by_id,
    transit_last_modified_by,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    deleted_by_id,
    deleted_by 
FROM `{{params.project_name}}.staging.CarTransits`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where transit_last_modified >= '{{params.start_ts}}' and transit_last_modified < '{{params.end_ts}}'
/* TODO: Validate with Product the Start and End times */