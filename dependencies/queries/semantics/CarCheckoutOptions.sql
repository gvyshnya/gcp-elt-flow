SELECT
    cco.car_checkout_option_id,
    cco.car_id,
    cco.status,
    cco.internal_checkout_option_id,
    DATETIME(cco.from_date, cmt.country_timezone) as from_date,
    cco.decided_by,
    cco.requested_by,
	DATETIME(cco.created_at, cmt.country_timezone) as created_at,
	DATETIME(cco.updated_at, cmt.country_timezone) as updated_at,
	DATETIME(cco.deleted_at, cmt.country_timezone) as deleted_at,
    c.country_id
FROM `{{params.project_name}}.staging.CarCheckoutOptions` cco
INNER JOIN `{{params.project_name}}.staging.Cars` as c on c.car_id = cco.car_id
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on c.country_id = cmt.country_id
where cco.updated_at >= '{{params.start_ts}}' and cco.updated_at < '{{params.end_ts}}'