SELECT
ct.contract_id,
ct.financing_customer_id,
ct.limits,
ct.fees,
ct.status,
ct.repayment_days,
DATETIME(ct.created_at, cmt.country_timezone) as created_at,
DATETIME(ct.updated_at, cmt.country_timezone) as updated_at,
DATETIME(ct.deleted_at, cmt.country_timezone) as deleted_at,
ct.created_by_name,
ct.created_by_id,
ct.updated_by_name,
ct.updated_by_id,
ct.deleted_by_name,
ct.deleted_by_id,
ct.min_loan_amount,
ROUND((select ct.min_loan_amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ct.created_at), INTERVAL 1 DAY)), 2) as min_loan_amount_usd,
ct.max_loan_amount,
ROUND((select ct.max_loan_amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ct.created_at), INTERVAL 1 DAY)), 2) as max_loan_amount_usd,
ct.down_payment,
ROUND((select ct.down_payment / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ct.created_at), INTERVAL 1 DAY)), 2) as down_payment_usd,
ct.security_deposit,
ROUND((select ct.min_loan_amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(ct.created_at), INTERVAL 1 DAY)), 2) as security_deposit_usd,
TRIM(ct.country_id) as country_id
FROM `{{params.project_name}}.staging.FinancingContracts` ct
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on (ct.country_id) = cmt.country_id
WHERE ct.updated_at >= '{{params.start_ts}}' AND ct.updated_at < '{{params.end_ts}}'
