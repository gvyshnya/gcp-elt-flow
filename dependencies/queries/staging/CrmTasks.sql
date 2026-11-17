SELECT  
task.id as 'task_id', 
task.country as 'country_id', 
task.contactId as 'customer_id',
task.subject as 'task_subject', 
task.description as 'task_description',
task.subtype as 'task_subtype', 
task.status as 'task_status', 
UNIX_TIMESTAMP(task.dueDate) as 'task_duedate',
task.responsible as 'task_responsible', 
task.responsibleName as 'task_responsible_name',
task.priority as 'task_priority', 
UNIX_TIMESTAMP(task.createdAt) as 'task_created',
task.createdByUser as 'task_created_by_id',
task.createdByUserEmail as 'task_created_by',
UNIX_TIMESTAMP(task.updatedAt) as 'task_last_modified',
task.updatedByUser as 'task_last_modified_by_id',
task.updatedByUserEmail as 'task_last_modified_by',
UNIX_TIMESTAMP(task.deletedAt) as 'deleted_at',
task.deletedByUser as 'deleted_by_id',
task.deletedByUserEmail as 'deleted_by'
FROM fcgContact.comment task
JOIN fcgContact.contact c ON task.contactId = c.id
WHERE task.type = 'task'
and task.updatedAt >= '{{params.start_ts}}' and task.updatedAt < '{{params.end_ts}}'