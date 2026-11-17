SELECT
w.id::"varchar" AS webhook_id,
w.country AS country_id,
w.name AS webhook_name,
w.url AS webhook_url,
w.nonce as nonce,
w.description as webhook_description,
w."createdAt" AS created_at,
w."updatedAt" AS updated_at,
w."deletedAt" AS deleted_at,
w."createdByName" AS created_by_name,
w."createdById"::"varchar" AS created_by_id,
w."updatedByName" AS updated_by_name,
w."updatedById"::"varchar" AS updated_by_id,
w."deletedByName" AS deleted_by_name,
w."deletedById"::"varchar" AS deleted_by_id
FROM "fcgWebhooks"."public"."webhook" w
WHERE w."updatedAt" >= '{{params.start_ts}}' AND w."updatedAt" < '{{params.end_ts}}'