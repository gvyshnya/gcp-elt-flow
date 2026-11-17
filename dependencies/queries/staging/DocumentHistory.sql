SELECT
dh.id as document_history_id,
referenceId as car_id,
typeId as document_type_id,
type as document_history_type, 
field as document_field,
value as document_field_value, 
operation as operation,
updatedById as updated_by_id,
updatedByEmail as updated_by,
UNIX_TIMESTAMP(createdAt) as created_at, 
UNIX_TIMESTAMP(updatedAt) as updated_at, 
UNIX_TIMESTAMP(deletedAt) as deleted_at
FROM fcgDocument.documentHistory dh
WHERE dh.updatedAt >= '{{params.start_ts}}' and dh.updatedAt < '{{params.end_ts}}'