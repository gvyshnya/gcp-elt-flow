SELECT
    comment_id,
    country_id,
    customer_id,
    comment_subject,
    comment_description,
    comment_subtype,
    comment_status,
    DATETIME(comment_duedate, cmt.country_timezone) as comment_duedate,
    comment_responsible,
    comment_responsible_name,
    comment_priority,
    DATETIME(comment_created, cmt.country_timezone) as comment_created,
    comment_created_by_id,
    comment_created_by,
    DATETIME(comment_last_modified, cmt.country_timezone) as comment_last_modified,
    comment_last_modified_by_id,
    comment_last_modified_by,
    DATETIME(deleted_at, cmt.country_timezone) as deleted_at,
    deleted_by_id,
    deleted_by
FROM `{{params.project_name}}.staging.CrmComments`
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where comment_last_modified >= '{{params.start_ts}}' and comment_last_modified < '{{params.end_ts}}'