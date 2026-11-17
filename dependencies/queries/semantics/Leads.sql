SELECT
    l.lead_id,
    l.customer_id,
    l.make,
    l.model,
    l.trim,
    l.transmission,
    l.year,
    l.mileage,
    l.plate,
    l.user_google_id,
    l.lead_source,
    l.lead_status,
    l.lead_comment,
    l.latest_booking_id,
    l.rejection_reasons,
    l.cancellation_reason,
    l.responsible,
    l.responsible_name,
    l.service_type,
    l.created_by_crm,
    l.cancelled_in_status,
    l.owner_name,
    l.owner_phone,
    l.call_status,
    l.discarded_reason,
    l.external_lead_id,
    l.referral_code,
    DATETIME(l.lead_created_at, cmt.country_timezone) as lead_created_at,
    l.lead_created_by_id,
    l.lead_created_by,
    DATETIME(l.lead_last_modified, cmt.country_timezone) as lead_last_modified,
    l.lead_last_modified_by_id,
    l.lead_last_modified_by,
    DATETIME(l.deleted_at, cmt.country_timezone) as deleted_at,
    l.deleted_by_id,
    l.deleted_by,
    l.country_id,
    l.price,
    ROUND((select l.price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(l.lead_created_at), INTERVAL 1 DAY)), 2) as price_usd,
    l.min_price,
    ROUND((select l.min_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(l.lead_created_at), INTERVAL 1 DAY)), 2) as min_price_usd,
    l.max_price,
    ROUND((select l.max_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(l.lead_created_at), INTERVAL 1 DAY)), 2) as max_price_usd,
    l.utm_source,
    l.utm_campaign,
    l.utm_medium,
    l.utm_term,
    l.utm_content,
    l.utm_campaign_id,
    l.utm_ad_group_id,
    l.selling_urgency,
    l.gclid,
    l.vin,
    l.last_offer_price,
    l.seller_expectation_price,
    l.self_inspection,
    l.inspection_type,
    l.lead_area,
    l.responsible_person,
    l.responsible_person_name,
    l.lead_system_locale
FROM `{{params.project_name}}.staging.Leads` l
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)
where l.lead_last_modified >= '{{params.start_ts}}' and l.lead_last_modified < '{{params.end_ts}}'