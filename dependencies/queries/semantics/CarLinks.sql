SELECT 
link_id, 
car_id,
country_id, 
swapped_car_id,
country_swapped_car,
link_type,
DATETIME(created_at, cmt.country_timezone) as created_at,
created_by_id,
created_by_name,
DATETIME(updated_at,cmt.country_timezone) as updated_at,
DATETIME(deleted_at,cmt.country_timezone) as deleted_at,
deleted_by_id,
deleted_by_name
FROM `{{params.project_name}}.staging.CarLinks`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'
