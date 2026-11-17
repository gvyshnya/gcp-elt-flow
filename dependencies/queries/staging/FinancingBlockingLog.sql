SELECT 
bl."id"::"varchar" as blocking_log_id,
bl."customerId"::"varchar" as customer_id,
bl."mode"::"varchar" as mode,
bl."type"::"varchar" as blocking_type,
bl."status"::"varchar" as blocking_status,
bl."reason"::"varchar" as blocking_reason,
bl."comments"::"varchar" as blocking_comments,
bl."createdAt" as created_at,
bl."updatedAt" as updated_at,
bl."deletedAt" as deleted_at,
bl."createdByName"::"varchar" as created_by_name,
bl."createdById"::"varchar" as created_by_id,
bl."updatedByName"::"varchar" as updated_by_name,
bl."updatedById"::"varchar" as updated_by_id,
bl."deletedByName"::"varchar" as deleted_by_name,
bl."deletedById"::"varchar" as deleted_by_id,
cust."country"::"varchar" as country_id
FROM "fcgFinancing"."public"."blockingLog" bl 
JOIN "fcgFinancing"."public"."customer" cust 
ON cust.id = bl."customerId" 
WHERE bl."updatedAt" >= '{{params.start_ts}}' AND bl."updatedAt" < '{{params.end_ts}}'