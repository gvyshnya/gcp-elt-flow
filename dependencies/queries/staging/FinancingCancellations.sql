SELECT 
lc."id" as cancellation_id,
lc."customerId" as customer_id,
lc."loanId" as loan_id,
lc."reason" as reason,
lc."customerComments" as customer_comments,
lc."date" as cancelled_at,
lc."officerComments" as officer_comments,
lc."principalUtr" as principal_utr,
lc."interestUtr" as interest_utr,
lc."chargeUtr" as charge_utr,
lc."createdAt" as created_at,
lc."updatedAt" as updated_at,
lc."deletedAt" as deleted_at,
lc."createdByName" as created_by_name,
lc."createdById" as created_by_id,
lc."updatedByName" as updated_by_name,
lc."updatedById" as updated_by_id,
lc."deletedByName" as deleted_by_name,
lc."deletedById" as deleted_by_id,
l."country" as country_id
FROM "fcgFinancing"."public"."cancellation" lc
join "fcgFinancing"."public"."loan" l 
on l.id = lc."loanId" 
WHERE lc."updatedAt" >= '{{params.start_ts}}' AND lc."updatedAt" < '{{params.end_ts}}'