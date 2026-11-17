SELECT
le.ledger_entry_id,
le.loan_id,
le.item,
le.amount,
ROUND((select le.amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(le.created_at), INTERVAL 1 DAY)), 2) as amount_usd,
le.type,
le.date,
le.reference_id,
le.purpose,
DATETIME(le.created_at, cmt.country_timezone) as created_at,
DATETIME(le.updated_at, cmt.country_timezone) as updated_at,
DATETIME(le.deleted_at, cmt.country_timezone) as deleted_at,
le.created_by_name,
le.created_by_id,
le.updated_by_name,
le.updated_by_id,
le.deleted_by_name,
le.deleted_by_id,
TRIM(le.country_id) as country_id
FROM `{{params.project_name}}.staging.FinancingLedgerEntries` le
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(le.country_id) = cmt.country_id
WHERE le.updated_at >= '{{params.start_ts}}' AND le.updated_at < '{{params.end_ts}}'