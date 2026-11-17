SELECT 
cc.car_comment_id, 
cc.car_id,
cc.country_id, 
cc.comment_title,
cc.comment_description, 
cc.mentions, 
DATETIME(cc.created_at, cmt.country_timezone) as created_at,
cc.created_by_id,
cc.created_by_name,
DATETIME(cc.updated_at,cmt.country_timezone) as updated_at,
cc.updated_by_id,
cc.updated_by_name,
DATETIME(cc.deleted_at,cmt.country_timezone) as deleted_at,
cc.deleted_by_id,
cc.deleted_by_name
FROM `{{params.project_name}}.staging.CarComments` cc
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt on cc.country_id = cmt.country_id
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'