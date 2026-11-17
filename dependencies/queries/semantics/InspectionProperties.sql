SELECT 
inspection_property_id,
inspection_id,
property_name,
property_value,
DATETIME(created_at, cmt.country_timezone) as created_at,
DATETIME(updated_at,cmt.country_timezone) as updated_at,
DATETIME(deleted_at,cmt.country_timezone) as deleted_at,
country_id
FROM `{{params.project_name}}.staging.InspectionProperties`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'