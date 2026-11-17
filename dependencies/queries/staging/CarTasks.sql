SELECT 
    ct.id as 'car_task_id',
    ct.carId as 'car_id',
    ct.country as 'country_id',
    ct.subject as 'subject',
    ct.description as 'description',
    ct.group as 'car_task_group',
    ct.type as 'car_task_type',
    ct.status as 'car_task_status',
    UNIX_TIMESTAMP(ct.dueDate) as 'due_date',
    ct.responsible as 'responsible_user_id',
    ct.priority as 'task_priority',
    UNIX_TIMESTAMP(ct.createdAt) as 'created_at',
    ct.createdByName as 'created_by',
    ct.createdById as 'created_by_id',
    UNIX_TIMESTAMP(ct.updatedAt) as 'updated_at',
    ct.updatedByName as 'updated_by',
    ct.updatedById as 'updated_by_id',
    UNIX_TIMESTAMP(ct.deletedAt) as 'deleted_at',
    ct.deletedByName as 'deleted_by',
    ct.deletedById as 'deleted_by_id'
FROM fcgCar.task ct
where ct.updatedAt >= '{{params.start_ts}}' and ct.updatedAt < '{{params.end_ts}}'