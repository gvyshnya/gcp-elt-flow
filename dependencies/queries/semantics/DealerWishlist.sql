SELECT
    dw.dealer_id,
    dw.wish_list,
    d.country_id,
    DATETIME(dw.created_at, cmt.country_timezone) as created_at,
    DATETIME(dw.updated_at, cmt.country_timezone) as updated_at,
    DATETIME(dw.deleted_at, cmt.country_timezone) as deleted_at
FROM `{{params.project_name}}.staging.DealerWishlist` dw
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
INNER JOIN `{{params.project_name}}.staging.Dealers` d using (dealer_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'