SELECT 
lc."loanId"::"varchar" as loan_id,
lc."contract"::"varchar" as contract_info,
lc."createdAt" as created_at,
lc."updatedAt" as updated_at,
lc."deletedAt" as deleted_at,
lc."createdByName"::"varchar" as created_by_name,
lc."createdById"::"varchar" as created_by_id,
lc."updatedByName"::"varchar" as updated_by_name,
lc."updatedById"::"varchar" as updated_by_id,
lc."deletedByName"::"varchar" as deleted_by_name,
lc."deletedById"::"varchar" as deleted_by_id,
l."country"::"varchar" as country_id
FROM "fcgFinancing"."public"."loanContract" lc
join "fcgFinancing"."public"."loan" l 
on l.id = lc."loanId" 
WHERE lc."updatedAt" >= '{{params.start_ts}}' AND lc."updatedAt" < '{{params.end_ts}}'