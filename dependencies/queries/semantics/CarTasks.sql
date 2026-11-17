SELECT
    car_task_id,
    car_id,
    country_id,
    subject,
    description,
    car_task_group,
    car_task_type,
    car_task_status,
    DATETIME(due_date, cmt.country_timezone) as due_date,
    responsible_user_id,
    task_priority,
    DATETIME(created_at, cmt.country_timezone) as created_at,
    created_by,
    created_by_id,
    DATETIME(updated_at, cmt.country_timezone) as updated_at,
    updated_by,
    updated_by_id,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    deleted_by,
    deleted_by_id
FROM `{{params.project_name}}.staging.CarTasks`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where updated_at >= '{{params.start_ts}}' and updated_at < '{{params.end_ts}}'