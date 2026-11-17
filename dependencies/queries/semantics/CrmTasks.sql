SELECT
    task_id ,
    country_id,
    customer_id,
    task_subject,
    task_description,
    task_subtype,
    task_status,
    DATETIME(task_duedate, cmt.country_timezone) as task_duedate,
    task_responsible,
    task_responsible_name,
    task_priority,
    DATETIME(task_created, cmt.country_timezone) as task_created,
    task_created_by_id,
    task_created_by,
    DATETIME(task_last_modified, cmt.country_timezone) as task_last_modified,
    task_last_modified_by_id,
    task_last_modified_by,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    deleted_by_id,
    deleted_by
FROM `{{params.project_name}}.staging.CrmTasks`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where task_last_modified >= '{{params.start_ts}}' and task_last_modified < '{{params.end_ts}}'