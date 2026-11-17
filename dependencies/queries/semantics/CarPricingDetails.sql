SELECT
    GENERATE_UUID() AS car_pricing_detail_guid,
    car_pricing_detail_id,
    country_id,
    make,
    model,
    trim,
    year, 
    price,
    min_price,
    max_price,
    transmission,
    min_market_price, 
    max_market_price,
    min_price_b,
    max_price_b,
    price_b,
    location,
    price_text,
    DATETIME(CURRENT_TIMESTAMP(), cmt.country_timezone) as created_at
FROM `{{params.project_name}}.staging.CarPricingDetails` cp
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)