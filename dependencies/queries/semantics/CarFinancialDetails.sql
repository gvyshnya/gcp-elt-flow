SELECT
    cfd.car_financial_details_id,
    cfd.car_id,
    cfd.competitor_price,
    ROUND((select cfd.competitor_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as competitor_price_usd,
    cfd.initial_valuation_price,
    cfd.seller_expectation_price,
    ROUND((select cfd.seller_expectation_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as seller_expectation_price_usd,
    cfd.seller_first_offer,
    ROUND((select cfd.seller_first_offer / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as seller_first_offer_usd,
    cfd.seller_final_offer,
    ROUND((select cfd.seller_final_offer / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as seller_final_offer_usd,
    cfd.reserve_auction_price,
    ROUND((select cfd.reserve_auction_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as reserve_auction_price_usd,
    DATETIME(cfd.reserved_at, cmt.country_timezone) as reserved_at,
    cfd.purchase_channel,
    cfd.purchased_by_id,
    cfd.purchase_comment,
    cfd.sale_comment,
    cfd.sale_rep,
    cfd.sold_to_id,
    cfd.sold_to_phone_number,
    DATETIME(cfd.bought_at, cmt.country_timezone) as bought_at,
    DATETIME(cfd.sold_at, cmt.country_timezone) as sold_at,
    cfd.country_id,
    cfd.invoice_date,
    cfd.invoice_number,
    cfd.b2b_deal,
    DATETIME(cfd.created_at, cmt.country_timezone) as created_at,
    cfd.created_by,
    cfd.created_by_id,
    DATETIME(cfd.updated_at, cmt.country_timezone) as updated_at,
    cfd.updated_by,
    cfd.updated_by_id,
    DATETIME(cfd.deleted_at, cmt.country_timezone) as deleted_at,
    cfd.deleted_by,
    cfd.deleted_by_id,
    cfd.is_marketplace_visible,
    cfd.marketplace_price,
    ROUND((select cfd.marketplace_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.created_at), INTERVAL 1 DAY)), 2) as marketplace_price_usd,
    cfd.available_financing_options,
    cfd.chosen_financing_options,
    cfd.is_featured,
    DATETIME(cfd.confirmed_at, cmt.country_timezone) as confirmed_at,
    cfd.purchase_cancellation_reason,
    cfd.marketplace_images,
    cfd.old_marketplace_price,
    cfd.payment_recipient,
    cfd.payment_type,
    cfd.selected_marketplaces,
    cfd.risk_index,
    cfd.dealer_executive
FROM `{{params.project_name}}.staging.CarFinancialDetails` cfd
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where cfd.updated_at >= '{{params.start_ts}}' and cfd.updated_at < '{{params.end_ts}}'