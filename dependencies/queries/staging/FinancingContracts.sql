SELECT
ct.id::"varchar" AS contract_id,
ct."customerId"::"varchar" AS financing_customer_id,
ct.limits::"varchar" AS limits,
ct.fees::"varchar" AS fees,
ct.status::"varchar" AS status,
ct."repaymentDays" AS repayment_days,
ct."createdAt" AS created_at,
ct."updatedAt" AS updated_at,
ct."deletedAt" AS deleted_at,
ct."createdByName" AS created_by_name,
ct."createdById"::"varchar" AS created_by_id,
ct."updatedByName" AS updated_by_name,
ct."updatedById"::"varchar" AS updated_by_id,
ct."deletedByName" AS deleted_by_name,
ct."deletedById"::"varchar" AS deleted_by_id,
ct."minLoanAmount" AS min_loan_amount,
ct."maxLoanAmount" AS max_loan_amount,
ct."downPayment" AS down_payment,
ct."securityDeposit" AS security_deposit,
cm.country AS country_id
FROM "fcgFinancing"."public"."contract" ct
INNER JOIN "fcgFinancing"."public"."customer" cm ON ct."customerId" = cm.id
WHERE ct."updatedAt" >= '{{params.start_ts}}' AND ct."updatedAt" < '{{params.end_ts}}'