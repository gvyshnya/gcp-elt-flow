MERGE `{{params.project_name}}.semantics_central.CarTasks` final
USING (
{{range_query}}
) staging
ON final.car_task_id = staging.car_task_id
WHEN MATCHED THEN
UPDATE SET
final.car_id = staging.car_id,
final.country_id = staging.country_id,
final.subject = staging.subject,
final.description = staging.description,
final.car_task_group = staging.car_task_group,
final.car_task_type = staging.car_task_type,
final.car_task_status = staging.car_task_status,
final.due_date = staging.due_date,
final.responsible_user_id = staging.responsible_user_id,
final.task_priority = staging.task_priority,
final.created_at = staging.created_at,
final.created_by = staging.created_by,
final.created_by_id = staging.created_by_id,
final.updated_at = staging.updated_at,
final.updated_by = staging.updated_by,
final.updated_by_id = staging.updated_by_id,
final.deleted_at = staging.deleted_at,
final.deleted_by = staging.deleted_by,
final.deleted_by_id = staging.deleted_by_id
WHEN NOT MATCHED THEN
INSERT (
car_task_id,
car_id,
country_id,
subject,
description,
car_task_group,
car_task_type,
car_task_status,
due_date,
responsible_user_id,
task_priority,
created_at,
created_by,
created_by_id,
updated_at,
updated_by,
updated_by_id,
deleted_at,
deleted_by,
deleted_by_id
) VALUES (
staging.car_task_id,
staging.car_id,
staging.country_id,
staging.subject,
staging.description,
staging.car_task_group,
staging.car_task_type,
staging.car_task_status,
staging.due_date,
staging.responsible_user_id,
staging.task_priority,
staging.created_at,
staging.created_by,
staging.created_by_id,
staging.updated_at,
staging.updated_by,
staging.updated_by_id,
staging.deleted_at,
staging.deleted_by,
staging.deleted_by_id
)