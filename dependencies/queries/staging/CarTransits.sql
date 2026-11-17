select 
	t.id as 'transit_id',
    t.carId as 'car_id',
    c.country as 'country_id',
	ifnull(t.type, 'not specified') as 'transit_type',
	t.status as 'transit_status',
	t.startLocation as 'transit_start_location',
	/* t.startPlace as 'transit_start_place', ---> Always NULL */
	t.endLocation as 'transit_end_location',
	/* t.endPlace as 'transit_end_place', ----> Always NULL */
	t.driver as 'transit_driver',
	t.driverId as 'transit_driver_id',
	t.driverCompany as 'transit_driver_company',
	t.startMileage as 'start_mileage',
	t.endMileage as 'end_mileage',
	t.comment as 'transit_comment',
	UNIX_TIMESTAMP(t.startTime) as 'transit_start_time',
	UNIX_TIMESTAMP(t.endTime) as 'transit_end_time',
	UNIX_TIMESTAMP(t.createdAt) as 'transit_created_at',
	t.createdById as 'transit_created_by_id',
	t.createdByName as 'transit_created_by',
	UNIX_TIMESTAMP(t.updatedAt) as 'transit_last_modified',
	t.updatedById as 'transit_last_modified_by_id',
	t.updatedByName as 'transit_last_modified_by',
	UNIX_TIMESTAMP(t.deletedAt) as 'deleted_at',
	t.deletedById as 'deleted_by_id',
	t.deletedByName as 'deleted_by',
	t.availableAtStart as 'available_at_start',
	t.availableAtEnd as 'available_at_end',
	t.transitJobId  as 'transit_job_id'
from fcgCar.transit t
join fcgCar.car c on t.carId=c.id
where t.updatedAt >= '{{params.start_ts}}' and t.updatedAt < '{{params.end_ts}}'