SELECT
    adg.dealer_group_id,
    adg.dealer_id,
    adg.group_id,  
    DATETIME(adg.group_created_at, cmt.country_timezone) as group_created_at,
    DATETIME(adg.group_updated_at, cmt.country_timezone) as group_updated_at,
    DATETIME(adg.group_deleted_at, cmt.country_timezone) as group_deleted_at,
    adg.country_id
FROM `{{params.project_name}}.staging.AuctionDealerGroups` adg
inner join `{{params.project_name}}.staging.CountryMetadata` cmt using(country_id)
where adg.group_updated_at >= '{{params.start_ts}}' and adg.group_updated_at < '{{params.end_ts}}'
