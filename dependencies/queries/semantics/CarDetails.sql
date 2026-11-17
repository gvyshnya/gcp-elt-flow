SELECT 
cd.car_detail_id, 
cd.car_id,
cd.country_id, 
cd.attribute_name,
cd.attribute_value,
DATETIME(cd.created_at, cmt.country_timezone) as created_at,
cd.created_by_id,
cd.created_by_name,
DATETIME(cd.updated_at,cmt.country_timezone) as updated_at,
cd.updated_by_id,
cd.updated_by_name,
DATETIME(cd.deleted_at,cmt.country_timezone) as deleted_at,
cd.deleted_by_id,
cd.deleted_by_name
FROM `{{params.project_name}}.staging.CarDetails` cd
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on cd.country_id = cmt.country_id
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'