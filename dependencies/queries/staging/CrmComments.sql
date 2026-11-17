SELECT  
comment.id as 'comment_id', 
comment.country as 'country_id', 
comment.contactId as 'customer_id',
comment.subject as 'comment_subject', 
comment.description as 'comment_description',
comment.subtype as 'comment_subtype', 
comment.status as 'comment_status',
UNIX_TIMESTAMP(comment.dueDate) as 'comment_duedate', 
comment.responsible as 'comment_responsible', 
comment.responsibleName as 'comment_responsible_name', 
comment.priority as 'comment_priority',
UNIX_TIMESTAMP(comment.createdAt) as 'comment_created',
comment.createdByUser as 'comment_created_by_id',
comment.createdByUserEmail as 'comment_created_by',
UNIX_TIMESTAMP(comment.updatedAt) as 'comment_last_modified',
comment.updatedByUser as 'comment_last_modified_by_id',
comment.updatedByUserEmail as 'comment_last_modified_by',
UNIX_TIMESTAMP(comment.deletedAt) as 'deleted_at',
comment.deletedByUser as 'deleted_by_id',
comment.deletedByUserEmail as 'deleted_by'
FROM fcgContact.comment comment
JOIN fcgContact.contact c ON comment.contactId = c.id
WHERE comment.type = 'comment'
and comment.updatedAt >= '{{params.start_ts}}' and comment.updatedAt < '{{params.end_ts}}'