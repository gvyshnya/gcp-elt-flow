SELECT 
lc."id"::"varchar" as eligibility_criteria_id,
lc."dealerId"::"varchar" as dealer_id,
lc."unjustCarRejection" as unjust_car_rejection, 
lc."accountBlocked" as account_blocked,      
lc."paymentDelayed" as payment_delayed,      
lc."createdAt" as created_at,
lc."updatedAt" as updated_at,
lc."deletedAt" as deleted_at,
lc."createdByName"::"varchar" as created_by_name,
lc."createdById"::"varchar" as created_by_id,
lc."updatedByName"::"varchar" as updated_by_name,
lc."updatedById"::"varchar" as updated_by_id,
lc."deletedByName"::"varchar" as deleted_by_name,
lc."deletedById"::"varchar" as deleted_by_id,
lc."country"::"varchar" as country_id
FROM "fcgFinancing"."public"."eligibilityCriteria" lc 
WHERE lc."updatedAt" >= '{{params.start_ts}}' AND lc."updatedAt" < '{{params.end_ts}}'