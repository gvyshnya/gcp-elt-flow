SELECT 
	cco.id as car_checkout_option_id,
	cco.carId as car_id,
	cco.status as status,
	cco.checkoutOptionId as internal_checkout_option_id,
	UNIX_TIMESTAMP(cco.fromDate) as from_date, 
	cco.decidedById as decided_by,
	cco.requestedById as requested_by,
	UNIX_TIMESTAMP(cco.createdAt) as created_at, 
	UNIX_TIMESTAMP(cco.updatedAt) as updated_at, 
	UNIX_TIMESTAMP(cco.deletedAt) as deleted_at
	/* ,c.country as country_id */
FROM fcgOrder.carCheckoutOption cco
/* JOIN fcgCar.car c on cco.carId = c.id */ -- Removing cross service dependencies
WHERE cco.updatedAt >= '{{params.start_ts}}' and cco.updatedAt < '{{params.end_ts}}'