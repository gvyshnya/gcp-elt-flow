SELECT 
    ch.id as 'customer_history_id', 
    ch.contactId as 'customer_id',
    ch.type as 'customer_history_type',
    ch.typeId as 'customer_history_type_id',
    ch.field,
    ch.value,
    ch.updatedById as 'updated_by_id',
    ch.updatedByEmail as 'updated_by',
    ch.operation,
    UNIX_TIMESTAMP(ch.createdAt) as 'created_at', 
    UNIX_TIMESTAMP(ch.updatedAt) as 'updated_at', 
    UNIX_TIMESTAMP(ch.deletedAt) as 'deleted_at',
    c.country as 'country_id'
FROM fcgContact.history ch
    JOIN fcgContact.contact c ON c.id = ch.contactId
where ch.updatedAt >= '{{params.start_ts}}' and ch.updatedAt < '{{params.end_ts}}'