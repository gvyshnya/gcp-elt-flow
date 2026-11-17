DELETE FROM `{{params.project_name}}.semantics_central.Visits`
WHERE DATE(visits_date) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'