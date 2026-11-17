SELECT
    ca.car_allowance_id ,
    ca.car_id ,
    ca.country_id,
    ca.allowance_sum,
    ROUND((select ca.allowance_sum / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ca.allowance_created), INTERVAL 1 DAY)), 2) as allowance_created_usd,
    ca.allowance_type,
    ca.allowance_comment,
    DATETIME(ca.allowance_created, cmt.country_timezone) as allowance_created,
    ca.allowance_created_by_id,
    ca.allowance_created_by,
    DATETIME(ca.allowance_last_modified, cmt.country_timezone) as allowance_last_modified,
    ca.allowance_last_modified_by_id,
    ca.allowance_last_modified_by,
    DATETIME(ca.deleted_at, cmt.country_timezone) as deleted_at,
    ca.deleted_by_id,
    ca.deleted_by
FROM `{{params.project_name}}.staging.CarAllowances` ca
inner join `{{params.project_name}}.staging.CountryMetadata` cmt using(country_id)
where ca.allowance_last_modified >= '{{params.start_ts}}' and ca.allowance_last_modified < '{{params.end_ts}}'