SELECT
    car_offer_pricing_id,
    car_id,
    offer_price,
    /* TODO: Should we convert this to USD? */
    offer_price_type,
    offer_price_subtype,
    created_by,
    created_by_id,
    DATETIME(created_at,cmt.country_timezone) as created_at,
    updated_by,
    updated_by_id,
    DATETIME(updated_at,cmt.country_timezone) as updated_at,
    deleted_by,
    deleted_by_id,
    DATETIME(deleted_at,cmt.country_timezone) as deleted_at,
    country_id
FROM `{{params.project_name}}.staging.CarOfferPrices`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'