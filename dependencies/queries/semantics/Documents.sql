WITH car_data_file AS (
    SELECT 
        document_id,
        reference_id as country_id
    FROM `{{params.project_name}}.staging.Documents` d
    WHERE d.document_entity = 'carDataFile'
),
docs_data AS (
SELECT
    doc.document_id,
    doc.reference_id,
    doc.document_comment,
    doc.file_id,
    doc.file_type,
    doc.document_category,
    doc.document_visibility,
    doc.document_entity,
    doc.uploader,
    doc.modified_by,
    doc.file_name,
    doc.file_size,
    doc.created_at,
    doc.updated_at,
    doc.deleted_at,
    doc.document_status,
    doc.created_by,
    doc.created_by_name,
    doc.updated_by,
    doc.updated_by_name,
    doc.deleted_by,
    doc.deleted_by_name,
    doc.print_reference_id,
    doc.is_public,
    COALESCE(c.country_id, 
        i.country_id, 
        u.country_id,
        l.country_id,
        ctj.country_id,
        cd.country_id,
        cfd.country_id,
        cp.country_id,
        dl.country_id,
        dr.country_id,
        car_data_file.country_id) as country_id
FROM
    `{{params.project_name}}.staging.Documents` doc
    LEFT JOIN `{{params.project_name}}.staging.Cars` c 
		on c.car_id = doc.reference_id
    LEFT JOIN `{{params.project_name}}.staging.Inspections` i 
		on i.inspection_id = doc.reference_id
    LEFT JOIN `{{params.project_name}}.staging.InternalUsers` u 
		on u.user_id = doc.reference_id
	LEFT JOIN `{{params.project_name}}.staging.Leads` l 
		on l.lead_id = doc.reference_id
	LEFT JOIN `{{params.project_name}}.staging.CarTransitJobs` ctj 
		on ctj.transit_job_id = doc.reference_id
	LEFT JOIN `{{params.project_name}}.staging.CarDetails` cd 
		on cd.car_detail_id = doc.reference_id
	LEFT JOIN `{{params.project_name}}.staging.CarFinancialDetails` cfd 
		on cfd.car_financial_details_id = doc.reference_id	
	LEFT JOIN `{{params.project_name}}.staging.CarPayments` cp 
		on cp.payment_id = doc.reference_id
	LEFT JOIN `{{params.project_name}}.staging.Dealers` dl 
		on dl.dealer_id = doc.reference_id
    LEFT JOIN `{{params.project_name}}.staging.Drivers` dr 
		on dr.user_id = doc.reference_id
	LEFT JOIN car_data_file 
		ON car_data_file.document_id = doc.document_id
WHERE
    doc.updated_at >= '{{params.start_ts}}'
    AND doc.updated_at < '{{params.end_ts}}'
)
SELECT
    doc.document_id,
    doc.reference_id,
    doc.document_comment,
    doc.file_id,
    doc.file_type,
    doc.document_category,
    doc.document_visibility,
    doc.document_entity,
    doc.uploader,
    doc.modified_by,
    doc.file_name,
    doc.file_size,
    DATETIME(doc.created_at, cmt.country_timezone) AS created_at,
    DATETIME(doc.updated_at, cmt.country_timezone) AS updated_at,
    DATETIME(doc.deleted_at, cmt.country_timezone) AS deleted_at,
    doc.document_status,
    doc.created_by,
    doc.created_by_name,
    doc.updated_by,
    doc.updated_by_name,
    doc.deleted_by,
    doc.deleted_by_name,
    doc.print_reference_id,
    doc.is_public,
    doc.country_id
FROM docs_data doc
INNER JOIN `{{params.project_name}}.staging.CountryMetadata` cmt 
        ON doc.country_id = cmt.country_id