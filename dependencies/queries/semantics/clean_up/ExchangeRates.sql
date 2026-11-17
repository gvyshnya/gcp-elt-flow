DELETE FROM `{{params.project_name}}.semantics_central.ExchangeRates`
WHERE DATE(exchange_rate_date) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'