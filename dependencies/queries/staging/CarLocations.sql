select
l.id as 'car_location_id',
l.carId as 'car_id',
l.locationType as 'location_type',
l.location as 'location',
l.oldLocation as 'old_location',
l.placeId as 'place_id',
UNIX_TIMESTAMP(l.createdAt) as 'created_at',
l.createdById as 'created_by_id',
l.createdByName as 'created_by',
UNIX_TIMESTAMP(l.updatedAt) as 'updated_at',
l.updatedById as 'updated_by_id',
l.updatedByName as 'updated_by',
UNIX_TIMESTAMP(l.deletedAt) as 'deleted_at',
l.deletedById as 'deleted_by_id',
l.deletedByName as 'deleted_by'
from fcgCar.location l
where l.updatedAt >= '{{params.start_ts}}' and l.updatedAt < '{{params.end_ts}}'