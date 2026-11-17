DELETE FROM `{{params.project_name}}.staging.DealerActivityEvents`
WHERE DATE(TIMESTAMP_SECONDS(ts)) BETWEEN '{{params.start_ts}}' AND '{{params.end_ts}}'