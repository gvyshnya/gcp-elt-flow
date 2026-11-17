MERGE `{{params.project_name}}.semantics_central.CarComments` final
USING (
{{range_query}}
) staging
ON final.car_comment_id = staging.car_comment_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id, 
final.comment_title = staging.comment_title,
final.comment_description = staging.comment_description, 
final.mentions = staging.mentions,
final.created_at = staging.created_at,
final.created_by_id = staging.created_by_id,
final.created_by_name = staging.created_by_name,
final.updated_at = staging.updated_at,
final.updated_by_id = staging.updated_by_id,
final.updated_by_name = staging.updated_by_name,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by_name = staging.deleted_by_name
WHEN NOT MATCHED THEN
INSERT (
car_comment_id, 
car_id,
country_id, 
comment_title,
comment_description, 
mentions,
created_at,
created_by_id,
created_by_name,
updated_at,
updated_by_id,
updated_by_name,
deleted_at,
deleted_by_id,
deleted_by_name
) VALUES (
staging.car_comment_id, 
staging.car_id,
staging.country_id, 
staging.comment_title,
staging.comment_description, 
staging.mentions,
staging.created_at,
staging.created_by_id,
staging.created_by_name,
staging.updated_at,
staging.updated_by_id,
staging.updated_by_name,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by_name
)