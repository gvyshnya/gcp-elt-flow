SELECT
    b.bid_id,
    DATETIME(b.bid_datetime, cmt.country_timezone) as bid_datetime,
    DATETIME(b.bid_last_modified, cmt.country_timezone) as bid_last_modified,
    b.bid_status,
    (b.placed_by_user_id IS NOT NULL) AS bid_placed_on_behalf,
    DATETIME(b.deleted_at, cmt.country_timezone) as deleted_at,
    d.is_internal AS is_internal,
    b.bid_type,
    b.dealer_id,
    b.auction_id,
    b.country_id,
    b.bid_amount,
    ROUND((select b.bid_amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(b.bid_datetime), INTERVAL 1 DAY)), 2) as bid_amount_usd
FROM `{{params.project_name}}.staging.Bids` b
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)
LEFT JOIN `{{params.project_name}}.staging.Dealers` d on b.dealer_id = d.dealer_id
where b.bid_last_modified >= '{{params.start_ts}}' and b.bid_last_modified < '{{params.end_ts}}'
--TODO: Find a proper way to tag internal dealers