SELECT
le.id::"varchar" AS ledger_entry_id,
le."loanId"::"varchar" AS loan_id,
le.item AS item,
le.amount AS amount,
le."type"::"varchar" AS "type" ,
le."date" AS "date",
le."referenceId"::"varchar" AS reference_id,
le.purpose::"varchar" AS purpose,
le."createdAt" AS created_at,
le."updatedAt" AS updated_at,
le."deletedAt" AS deleted_at,
le."createdByName" AS created_by_name,
le."createdById"::"varchar" AS created_by_id,
le."updatedByName" AS updated_by_name,
le."updatedById"::"varchar" AS updated_by_id,
le."deletedByName" AS deleted_by_name,
le."deletedById"::"varchar" AS deleted_by_id,
cm.country AS country_id
FROM "fcgFinancing"."public"."ledgerEntry" le
INNER JOIN "fcgFinancing".public.loan l ON le."loanId" = l.id
INNER JOIN "fcgFinancing".public.customer cm ON l."customerId" = cm.id 
WHERE le."updatedAt" >= '{{params.start_ts}}' AND le."updatedAt" < '{{params.end_ts}}'