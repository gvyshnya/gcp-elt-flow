SELECT
    visits_date,
    campaign_name,
    campaign_adwords_id,
    device_type,
    total_visits_number,
    unique_visits_number,
    new_visits_number,
    if(
        country_id = 'MX',
        (select v.ad_costs / ex.exchange_rate_to_USD
        from `{{params.project_name}}.staging.ExchangeRates` ex
        where cmt.country_currency = ex.currency_symbol
        and date(ex.exchange_rate_date) = DATE_SUB(date(v.visits_date), INTERVAL 1 DAY)), v.ad_costs)
    as ad_cost,
    bookings_number,
    quotes_number,
    inspections_number,
    purchases_number,
    application_name,
    country_id
FROM `{{params.project_name}}.staging.Visits` v
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
WHERE DATE(visits_date) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'