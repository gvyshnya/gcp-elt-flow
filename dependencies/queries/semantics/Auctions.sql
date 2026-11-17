WITH bids_info AS (
    SELECT
        auction_id,
        COUNT(bid_id) as number_of_bids,
        COUNT(distinct dealer_id) as number_of_bidders,
        MAX(bid_datetime) as last_bid_date,
        MIN(bid_datetime) as first_bid_date,
        MAX(bid_amount) as winning_bid_price
    FROM `{{params.project_name}}.staging.Bids`
    GROUP BY auction_id),
won_by_buy_now AS (
    SELECT DISTINCT
        auction_id,
        True AS won_with_buy_now
    FROM `{{params.project_name}}.staging.Bids`
    WHERE bid_type = "buyNow")

SELECT
	a.auction_id,
    DATETIME(a.auction_created_date, cmt.country_timezone) as auction_created_date,
    a.buy_now_enabled,
    a.has_winner,
    a.winner_dealer_id,
    DATETIME(a.auction_start_date, cmt.country_timezone) as auction_start_date,
    DATETIME(a.auction_end_date, cmt.country_timezone) as auction_end_date,
    DATETIME(a.auction_last_modified, cmt.country_timezone) as auction_last_modified,
    a.auction_number_of_comments,
    a.auction_number_of_damages,
    a.categories_score,
    a.auction_number_added_to_favorites,
	DATETIME(a.auction_original_end_date, cmt.country_timezone) as auction_original_end_date,
	a.runs, 
    a.auction_start_price,
    ROUND((select a.auction_start_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(a.auction_start_date), INTERVAL 1 DAY)), 2) as auction_start_price_usd,
    a.auction_buy_now_price,
    ROUND((select a.auction_buy_now_price / ex.exchange_rate_to_USD
    from `{{params.project_name}}.staging.ExchangeRates` ex
    where cmt.country_currency = ex.currency_symbol
    and date(ex.exchange_rate_date) = DATE_SUB(date(a.auction_start_date), INTERVAL 1 DAY)), 2) as auction_buy_now_price_usd,
    b.number_of_bids,
    b.number_of_bidders,
    DATETIME(b.last_bid_date, cmt.country_timezone) as last_bid_date,
    DATETIME(b.first_bid_date, cmt.country_timezone) as first_bid_date,
    coalesce(wbn.won_with_buy_now, False) as won_with_buy_now,
	a.number_of_extensions, 
    a.visible_round,
    a.scheduler_id,
    DATETIME(a.deleted_at, cmt.country_timezone) as deleted_at,
    a.inspection_id,
    coalesce(a.car_id, "fake-car-id-xxxxxxxxxxxxxxxxxxxxxxxx") as car_id,
    a.country_id,
    a.auction_type,
    a.auction_status,
    a.make,
    a.model,
    a.trim,
    a.transmission,
    a.year,
    coalesce(replace(a.fuel, "inspection.field.fuelType.", ""), "Unknown") as fuel,
    a.mileage,
    a.pre_autobid_possible,
    a.cancellation_reason,
    a.created_by,
    a.flow,
    b.winning_bid_price,
    ROUND((SELECT b.winning_bid_price / ex.exchange_rate_to_USD
    FROM `{{params.project_name}}.staging.ExchangeRates` ex
    WHERE cmt.country_currency = ex.currency_symbol
    AND DATE(ex.exchange_rate_date) = DATE_SUB(DATE(a.auction_start_date), INTERVAL 1 DAY)), 2) as winning_bid_price_usd,
    a.seller_expected_price,
    IF(a.seller_expected_price IS NOT NULL, b.winning_bid_price >= a.seller_expected_price, NULL) as seller_expectation_met,
    IF(a.seller_expected_price <> 0, (b.winning_bid_price - a.seller_expected_price)/a.seller_expected_price, NULL) as winning_bid_seller_expected_diff
FROM `{{params.project_name}}.staging.Auctions` as a
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)
LEFT JOIN bids_info b USING(auction_id)
LEFT JOIN won_by_buy_now wbn USING(auction_id)
/*where a.auction_last_modified >= '{{params.start_ts}}' and a.auction_last_modified < '{{params.end_ts}}' */

/* We have influence on the Bids table, commenting the date where to capture all behaviors */

/* TODO: Fix the date filter */