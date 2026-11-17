SELECT
    b.booking_id,
    b.external_id,
    DATETIME(b.booking_appointment_date) as booking_appointment_date,
    b.booking_location,
    b.place_id,
    p.city as inspection_center_city,
    p.place_location as inspection_center_name,
    b.booking_status as booking_status,
    COALESCE(co.bi_mapping, 'BI Mapping Missing') as booking_status_internal,
    b.booking_comments,
    b.booking_source,
    b.cancelled_in_status,
    b.call_status,
    b.discarded_reason,
    b.assigned_to,
    b.assigned_to_name,
    b.cancellation_reason,
    b.rejection_reason,
    DATETIME(b.cancelled_at, cmt.country_timezone) as cancelled_at,
    b.booking_type,
    DATETIME(b.booking_created, cmt.country_timezone) as booking_created,
    DATETIME(b.booking_last_modified, cmt.country_timezone) as booking_last_modified,
    DATETIME(b.deleted_at, cmt.country_timezone) as deleted_at,
    b.booking_source as booking_channel,
    b.lead_id,
    b.customer_id,
    b.country_id,
    b.created_by
FROM `{{params.project_name}}.staging.Bookings` b
inner join `{{params.project_name}}.staging.CountryMetadata` cmt USING(country_id)
inner join `{{params.project_name}}.staging.Places` p on p.place_id = b.place_id
left join (
    SELECT DISTINCT
	    country_id,
        country_options_name,
        bi_mapping
    FROM `{{params.project_name}}.staging.CountryOptions` 
    where
        country_options_type = 'appointmentStatus' AND
        bi_mapping is not null and
        country_id <> 'IN'
    UNION ALL
    SELECT  DISTINCT
	    country_id,
        country_options_name,
        bi_mapping
    FROM `{{params.project_name}}.staging.CountryOptions`  
    where
        country_options_type = 'appointmentStatus' AND
        bi_mapping is not null and
        country_id = 'IN' and
        country_options_name <> 'Inspector Assigned'
    UNION ALL
    SELECT DISTINCT
	    country_id,
        country_options_name,
        bi_mapping
    FROM `{{params.project_name}}.staging.CountryOptions` 
    where
        country_id = 'IN' and
        bi_mapping is not null and
        country_options_type = 'appointmentStatus' AND
        (country_options_name = 'Inspector Assigned' and deleted_at is null)
) co on b.country_id = co.country_id and b.booking_status = co.country_options_name 
where b.booking_last_modified >= '{{params.start_ts}}' and b.booking_last_modified < '{{params.end_ts}}'
