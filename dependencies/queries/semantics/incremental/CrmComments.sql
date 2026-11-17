MERGE `{{params.project_name}}.semantics_central.CrmComments` final
USING (
{{range_query}}
) staging
ON final.comment_id = staging.comment_id
WHEN MATCHED THEN
UPDATE SET
final.country_id = staging.country_id,
final.customer_id = staging.customer_id,
final.comment_subject = staging.comment_subject,
final.comment_description = staging.comment_description,
final.comment_subtype = staging.comment_subtype,
final.comment_status = staging.comment_status,
final.comment_duedate = staging.comment_duedate,
final.comment_responsible = staging.comment_responsible,
final.comment_responsible_name = staging.comment_responsible_name,
final.comment_priority = staging.comment_priority,
final.comment_created = staging.comment_created,
final.comment_created_by_id = staging.comment_created_by_id,
final.comment_created_by = staging.comment_created_by,
final.comment_last_modified = staging.comment_last_modified,
final.comment_last_modified_by_id = staging.comment_last_modified_by_id,
final.comment_last_modified_by = staging.comment_last_modified_by,
final.deleted_at = staging.deleted_at,
final.deleted_by_id = staging.deleted_by_id,
final.deleted_by = staging.deleted_by
WHEN NOT MATCHED THEN
INSERT (
comment_id,
country_id,
customer_id,
comment_subject,
comment_description,
comment_subtype,
comment_status,
comment_duedate,
comment_responsible,
comment_responsible_name,
comment_priority,
comment_created,
comment_created_by_id,
comment_created_by,
comment_last_modified,
comment_last_modified_by_id,
comment_last_modified_by,
deleted_at,
deleted_by_id,
deleted_by
) VALUES (
staging.comment_id,
staging.country_id,
staging.customer_id,
staging.comment_subject,
staging.comment_description,
staging.comment_subtype,
staging.comment_status,
staging.comment_duedate,
staging.comment_responsible,
staging.comment_responsible_name,
staging.comment_priority,
staging.comment_created,
staging.comment_created_by_id,
staging.comment_created_by,
staging.comment_last_modified,
staging.comment_last_modified_by_id,
staging.comment_last_modified_by,
staging.deleted_at,
staging.deleted_by_id,
staging.deleted_by
)