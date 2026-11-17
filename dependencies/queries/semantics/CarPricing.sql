SELECT
    cp.car_pricing_id,
    cp.car_id,
    cp.type,
    cp.amount,
    ROUND((select cp.amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cp.created_at), INTERVAL 1 DAY)), 2) as amount_usd,
    cp.subtype,
    cp.comments,
    cp.country_id,
    cp.vat_percentage,
    cp.vat,
    ROUND((select cp.vat / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cp.created_at), INTERVAL 1 DAY)), 2) as vat_usd,
	DATETIME(cp.created_at, cmt.country_timezone) as created_at,
	DATETIME(cp.updated_at, cmt.country_timezone) as updated_at,
	DATETIME(cp.deleted_at, cmt.country_timezone) as deleted_at,
    cp.created_by_email,
    cp.created_by_id,
    cp.updated_by_id,
    cp.updated_by_email,
    cp.deleted_by_id,
    cp.created_by,
    cp.updated_by,
    cp.deleted_by,
    cp.reference_id,
    cp.entity
FROM `{{params.project_name}}.staging.CarPricing` cp
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'