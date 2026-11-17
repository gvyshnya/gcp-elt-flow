MERGE `{{params.project_name}}.semantics_central.CrmTasks` final
USING (
{{range_query}}
) staging
ON final.task_id = staging.task_id
WHEN MATCHED THEN
UPDATE SET
final.country_id = staging.country_id,
final.customer_id = staging.customer_id,
final.task_subject = staging.task_subject,
final.task_description = staging.task_description,
final.task_subtype = staging.task_subtype,
final.task_status = staging.task_status,
final.task_duedate = staging.task_duedate,
final.task_responsible = staging.task_responsible,
final.task_responsible_name = staging.task_responsible_name,
final.task_priority = staging.task_priority,
final.task_created = staging.task_created,
final.task_created_by_id = staging.task_created_by_id,
final.task_created_by = staging.task_created_by,
final.task_last_modified = staging.task_last_modified,
final.task_last_modified_by_id = staging.task_last_modified_by_id,
final.task_last_modified_by = staging.task_last_modified_by,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by = staging.deleted_by
WHEN NOT MATCHED THEN
INSERT (
task_id,
country_id,
customer_id,
task_subject,
task_description,
task_subtype,
task_status,
task_duedate,
task_responsible,
task_responsible_name,
task_priority,
task_created,
task_created_by_id,
task_created_by,
task_last_modified,
task_last_modified_by_id,
task_last_modified_by,
deleted_at,
deleted_by_id,
deleted_by
) VALUES (
staging.task_id,
staging.country_id,
staging.customer_id,
staging.task_subject,
staging.task_description,
staging.task_subtype,
staging.task_status,
staging.task_duedate,
staging.task_responsible,
staging.task_responsible_name,
staging.task_priority,
staging.task_created,
staging.task_created_by_id,
staging.task_created_by,
staging.task_last_modified,
staging.task_last_modified_by_id,
staging.task_last_modified_by,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by
)