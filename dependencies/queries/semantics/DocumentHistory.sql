SELECT
    doc.document_history_id,
    doc.car_id,
    doc.document_type_id,
    doc.document_history_type, 
    doc.document_field,
    doc.document_field_value, 
    doc.operation,
    doc.updated_by_id,
    doc.updated_by,
    DATETIME(doc.created_at, cmt.country_timezone) AS created_at,
    DATETIME(doc.updated_at, cmt.country_timezone) AS updated_at,
    DATETIME(doc.deleted_at, cmt.country_timezone) AS deleted_at,
    c.country_id,
    date(DATETIME(doc.created_at, cmt.country_timezone)) as partition_date
FROM
    `{{params.project_name}}.staging.DocumentHistory` doc
    INNER JOIN `{{params.project_name}}.staging.Cars` c USING(car_id)
    INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt USING (country_id)
WHERE
    doc.updated_at >= '{{params.start_ts}}'
    AND doc.updated_at < '{{params.end_ts}}'