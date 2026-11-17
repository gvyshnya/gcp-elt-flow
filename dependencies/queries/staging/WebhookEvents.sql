SELECT
we.id::"varchar" AS webhook_event_id,
we."webhookId"::"varchar" AS webhook_id,
we.event as webhook_event,
w.country AS country_id,
we."createdAt" AS created_at,
we."updatedAt" AS updated_at,
we."deletedAt" AS deleted_at,
we."createdByName" AS created_by_name,
we."createdById"::"varchar" AS created_by_id,
we."updatedByName" AS updated_by_name,
we."updatedById"::"varchar" AS updated_by_id,
we."deletedByName" AS deleted_by_name,
we."deletedById"::"varchar" AS deleted_by_id
FROM "fcgWebhooks"."public"."webhookEvent"  we
INNER JOIN "fcgWebhooks"."public"."webhook" w ON we."webhookId" = w.id   
WHERE we."updatedAt" >= '{{params.start_ts}}' AND we."updatedAt" < '{{params.end_ts}}'