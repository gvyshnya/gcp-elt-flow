SELECT 
fec.id::"varchar" AS financing_eligibility_check_id,
fec."loanId"::"varchar" AS loan_id,
fec."from"::"varchar" AS loan_from,
fec."to"::"varchar" AS loan_to,
fec."isOverdueCheck"::"varchar" AS is_overdue_check,
fec."creditLimitCheck"::"varchar" AS is_credit_limit_check,
fec."customerManuallyFreezedCheck"::"varchar" AS is_customer_manually_freezed_check,
fec."ltvCheck"::"varchar" AS is_ltv_check,
fec."customerFinancingStatusCheck"::"varchar" AS is_customer_financing_status_check,
fec."adminStatusCheck"::"varchar" AS is_admin_status_check,
fec."createdAt" AS created_at,
fec."updatedAt" AS updated_at,
fec."deletedAt" AS deleted_at,
fec."createdByName" AS created_by_name,
fec."createdById"::"varchar" AS created_by_id,
fec."updatedByName" AS updated_by_name, 
fec."updatedById"::"varchar" AS updated_by_id,
fec."deletedByName" AS deleted_by_name, 
fec."deletedById"::"varchar" AS deleted_by_id,
fec."unjustCarRejection"::"varchar" AS unjust_car_rejection,
fec."accountBlocked"::"varchar" AS account_blocked,
fec."paymentDelayed"::"varchar" AS payment_delayed,
c.country as country_id
FROM "fcgFinancing"."public"."eligibilityCheck" fec
INNER JOIN "fcgFinancing"."public"."loan" l ON fec."loanId" = l.id
INNER JOIN "fcgFinancing"."public"."customer" c ON l."customerId" = c.id 
WHERE fec."updatedAt" >= '{{params.start_ts}}' AND fec."updatedAt" < '{{params.end_ts}}'