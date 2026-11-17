SELECT
    car_history_change_id,
    car_id,
    country_id,
    car_history_change_type_id,
    car_history_change_type,
    car_history_change_operation,
    affected_field,
    car_history_change_value ,
    updated_by_email,
    DATETIME(car_history_change_created, cmt.country_timezone) as car_history_change_created,
    DATETIME(car_history_change_last_modified, cmt.country_timezone) as car_history_change_last_modified,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    date(DATETIME(car_history_change_created, cmt.country_timezone)) as partition_date
FROM `{{params.project_name}}.staging.CarChangesHistory`
inner join `{{params.project_name}}.staging.CountryMetadata` cmt using(country_id)
where car_history_change_last_modified >= '{{params.start_ts}}' and car_history_change_last_modified < '{{params.end_ts}}'