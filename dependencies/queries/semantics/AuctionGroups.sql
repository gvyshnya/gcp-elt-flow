SELECT
    ag.group_id, 
    ag.group_name, 
    ag.group_description,
    ag.country_id,
    ag.group_hide, 
    ag.group_created_by_id,
    ag.group_created_by, 
    DATETIME(ag.group_created_at, cmt.country_timezone) as group_created_at,
    DATETIME(ag.group_updated_at, cmt.country_timezone) as group_updated_at,
    DATETIME(ag.group_deleted_at, cmt.country_timezone) as group_deleted_at
FROM `{{params.project_name}}.staging.AuctionGroups` ag
 inner join `{{params.project_name}}.staging.CountryMetadata` cmt using(country_id)
where ag.group_updated_at >= '{{params.start_ts}}' and ag.group_updated_at < '{{params.end_ts}}'
