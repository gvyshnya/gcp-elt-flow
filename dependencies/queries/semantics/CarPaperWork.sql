SELECT
    cpw.car_paperwork_id,
    cpw.car_id,
    cpw.country_id,
    cpw.doc_status,
    cpw.doc_handover_to_buyer_status,
    cpw.doc_location,
    cpw.doc_comment, 
    DATETIME(cpw.created_at, cmt.country_timezone) as created_at, 
    DATETIME(cpw.updated_at, cmt.country_timezone) as updated_at, 
    DATETIME(cpw.deleted_at, cmt.country_timezone) as deleted_at, 
    cpw.created_by_id,
    cpw.created_by,
    cpw.updated_by_id,
    cpw.updated_by,
    cpw.deleted_by_id,
    cpw.deleted_by,
    DATETIME(cpw.doc_handover_from_seller_date, cmt.country_timezone) as doc_handover_from_seller_date, 
    DATETIME(cpw.doc_handover_to_buyer_date, cmt.country_timezone) as doc_handover_to_buyer_date
FROM `{{params.project_name}}.staging.CarPaperWork` cpw
inner join `{{params.project_name}}.staging.CountryMetadata` cmt using(country_id)
where cpw.updated_at >= '{{params.start_ts}}' and cpw.updated_at < '{{params.end_ts}}'
