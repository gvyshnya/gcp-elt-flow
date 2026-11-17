SELECT
    b.blacklist_id,
    b.auction_id,
    b.dealer_id,
    DATETIME(b.created_at, cmt.country_timezone) as created_at,
    DATETIME(b.updated_at, cmt.country_timezone) as updated_at,
    DATETIME(b.deleted_at, cmt.country_timezone) as deleted_at,
    b.country_id
FROM `{{params.project_name}}.staging.Blacklist` b
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)