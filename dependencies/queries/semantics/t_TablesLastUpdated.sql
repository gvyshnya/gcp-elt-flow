SELECT 
table_name, 
updated_at,
CAST (TIMESTAMP_SUB( CAST (updated_at as TIMESTAMP), INTERVAL cm.country_timezone_offset_minutes MINUTE) as DATETIME) as updated_at_utc, 
latest.country_id
FROM (
	SELECT 
		'{{params.entity_name}}' as table_name, 
		MAX({{update_field}}) as updated_at, 
		e.country_id
	FROM `{{params.project_name}}.semantics_central.{{params.entity_name}}` e
	group by country_id
) latest
JOIN `{{params.project_name}}.semantics_central.CountryMetadata` cm 
    ON cm.country_id = latest.country_id