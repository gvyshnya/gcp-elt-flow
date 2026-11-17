SELECT
    cfh.financial_detail_id,
    cfh.car_id,
    c.country_id,
    cfh.financial_detail_operation_type,
    cfh.financial_detail_operation,
    cfh.affected_field,
    cfh.financial_detail_operation_value,
    cfh.updated_by,
    cfh.updated_by_email,
    DATETIME(cfh.financial_detail_created, cmt.country_timezone) as financial_detail_created,
    DATETIME(cfh.financial_detail_last_modified, cmt.country_timezone) as financial_detail_last_modified,
    DATETIME(cfh.deleted_at, cmt.country_timezone) as deleted_at,
    date(DATETIME(cfh.financial_detail_created, cmt.country_timezone)) as partition_date
FROM `{{params.project_name}}.staging.CarFinancialDetailsHistory` cfh
INNER JOIN `{{params.project_name}}.staging.Cars` c using (car_id)
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt using (country_id)
where cfh.financial_detail_last_modified >= '{{params.start_ts}}' and cfh.financial_detail_last_modified < '{{params.end_ts}}'