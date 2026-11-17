SELECT
    cp.payment_id,
    cp.car_id,
    cp.payment_type,
    cp.payment_subtype,
    cp.payment_sum,
    ROUND((select cp.payment_sum / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cp.transaction_date), INTERVAL 1 DAY)), 2) as payment_sum_usd,
    cp.payment_vat_percentage,
    cp.payment_vat,
    ROUND((select cp.payment_vat / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cp.transaction_date), INTERVAL 1 DAY)), 2) as payment_vat_usd,
    cp.payment_comment,
    cp.country_id,
    DATETIME(cp.transaction_date, cmt.country_timezone) as transaction_date,
    DATETIME(cp.payment_created, cmt.country_timezone) as payment_created,
    DATETIME(cp.payment_last_modified, cmt.country_timezone) as payment_last_modified,
    DATETIME(cp.deleted_at, cmt.country_timezone) as deleted_at
FROM `{{params.project_name}}.staging.CarPayments` cp
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where cp.payment_last_modified >= '{{params.start_ts}}' and cp.payment_last_modified < '{{params.end_ts}}'
/* TODO: Validate with Product how the transaction date is picked */