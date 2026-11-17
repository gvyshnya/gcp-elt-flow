SELECT
u.country_id,
aa.action_date,
aa.user_id,
aa.page_path,
aa.time_on_page_seconds,
aa.application_name,
aa.car_id
FROM `{{params.project_name}}.staging.AdminAppV1CarEdits` aa
INNER JOIN `{{params.project_name}}.staging.InternalUsers` u USING(user_id)
WHERE DATE(aa.action_date) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'