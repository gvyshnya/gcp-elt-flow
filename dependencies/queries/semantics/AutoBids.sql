SELECT
    ab.auto_bid_id,
    ab.dealer_id,
    ab.auction_id,
    ab.dealer_email,
    ab.auto_bid_type,
    ab.max_bid_sum,
    ROUND((select ab.max_bid_sum / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ab.created_at), INTERVAL 1 DAY)), 2) as max_bid_sum_usd,
    ab.current_price,
    ROUND((select ab.current_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ab.created_at), INTERVAL 1 DAY)), 2) as current_price_usd,
    ab.is_valid,
    ab.country_id,
    DATETIME(ab.created_at, cmt.country_timezone) as created_at,
    DATETIME(ab.updated_at, cmt.country_timezone) as updated_at,
    DATETIME(ab.deleted_at, cmt.country_timezone) as deleted_at
FROM `{{params.project_name}}.staging.AutoBids` ab
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where ab.updated_at >= '{{params.start_ts}}' and ab.updated_at < '{{params.end_ts}}'