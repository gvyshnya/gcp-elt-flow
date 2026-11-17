SELECT
exchange_rate_date,
currency_symbol,
exchange_rate_to_EUR,
exchange_rate_to_SEK,
exchange_rate_to_USD
FROM `{{params.project_name}}.staging.ExchangeRates`
WHERE DATE(exchange_rate_date) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'