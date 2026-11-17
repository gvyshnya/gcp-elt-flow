SELECT 
    fl.loan_id,
    fl.financing_customer_id,
    fl.contract_id,
    fl.car_id,
    fl.status,
    fl.amount,
    ROUND((select fl.amount / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as amount_usd,
    fl.fees,
    CAST(JSON_EXTRACT_SCALAR(fl.fees, "$['fee.loan']") AS INT64) as fee_loan,
    ROUND((select CAST(JSON_EXTRACT_SCALAR(fl.fees, "$['fee.loan']") AS INT64) / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as fee_loan_usd,
    fl.due_at,
    fl.settled_at,
    fl.disbursed_at ,
    DATETIME(fl.created_at, cmt.country_timezone) as created_at,
    DATETIME(fl.updated_at, cmt.country_timezone) as updated_at,
    DATETIME(fl.deleted_at, cmt.country_timezone) as deleted_at,
    fl.created_by_name,
    fl.created_by_id,
    fl.updated_by_name, 
    fl.updated_by_id,
    fl.deleted_by_name, 
    fl.deleted_by_id,
    fl.penalty,
    ROUND((select fl.penalty / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as penalty_usd,
    fl.sale_price,
    ROUND((select fl.sale_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as sale_price_usd,
    fl.paid_interest,
    ROUND((select fl.paid_interest / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as paid_interest_usd,
    fl.accrued_interest,
    ROUND((select fl.accrued_interest / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as accrued_interest_usd,
    fl.amount_due,
    ROUND((select fl.amount_due / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(fl.created_at), INTERVAL 1 DAY)), 2) as amount_due_usd,
    fl.car_data,
    TRIM(fl.country_id) as country_id
FROM `{{params.project_name}}.staging.FinancingLoans` fl
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on TRIM(fl.country_id) = cmt.country_id
WHERE fl.updated_at >= '{{params.start_ts}}' AND fl.updated_at < '{{params.end_ts}}'