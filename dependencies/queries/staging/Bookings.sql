/*
	Added new fields
    - b.assignedToEmail as 'assigned_to_email'
    - b.createdByUserEmail as 'created_by',
	- b.updatedByUserEmail as 'updated_by',
	- b.deletedByUserEmail as 'deleted_by'
    Dropped
	- booking_status_id
	- booking_channel_id
*/

SELECT
	b.id as 'booking_id', 
    b.leadId as 'lead_id', 
    b.contactId as 'customer_id',
	b.bookingId as 'external_id', 
    UNIX_TIMESTAMP(CONCAT(b.date, " ", b.time))  as 'booking_appointment_date', 
	b.location as 'booking_location',  
	b.placeId as 'place_id', 
    b.inspectionPointId as 'inspection_center_id', 
	b.inspectionPointCity as 'inspection_center_city', 
    b.inspectionPointName as 'inspection_center_name',
	b.status as 'booking_status', 
    b.comments as 'booking_comments',
	b.bookingSource as 'booking_source', 
    b.cancelledInStatus as 'cancelled_in_status',
	b.callStatus as 'call_status', 
    b.discardedReason as 'discarded_reason',
	b.assignedTo as 'assigned_to', 
    b.assignedToName as 'assigned_to_name',
	b.type as 'booking_type',
    b.cancellationReason as 'cancellation_reason',
	b.rejectionReasons as 'rejection_reason', 
    UNIX_TIMESTAMP(b.cancelledAt) as 'cancelled_at',
	b.country as 'country_id',
	UNIX_TIMESTAMP(b.createdAt) as 'booking_created', 
    UNIX_TIMESTAMP(b.updatedAt) as 'booking_last_modified', 
	UNIX_TIMESTAMP(b.deletedAt) as 'deleted_at',
    b.assignedToEmail as 'assigned_to_email',
	b.createdByUserEmail as 'created_by',
	b.updatedByUserEmail as 'updated_by',
	b.deletedByUserEmail as 'deleted_by'
FROM fcgContact.appointment b
WHERE b.contactId IS NOT NULL
AND b.bookingId IS NOT NULL
AND b.updatedAt >= '{{params.start_ts}}' and b.updatedAt < '{{params.end_ts}}'