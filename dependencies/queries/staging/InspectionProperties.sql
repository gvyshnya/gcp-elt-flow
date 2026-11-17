SELECT 
    ip.id as inspection_property_id,
    ip.inspectionId as inspection_id,
    ip.propertyName as property_name,
    ip.propertyValue as property_value,
    UNIX_TIMESTAMP(ip.createdAt) as 'created_at', 
    UNIX_TIMESTAMP(ip.updatedAt) as 'updated_at', 
    UNIX_TIMESTAMP(ip.deletedAt) as 'deleted_at',
    i.country as country_id
FROM 
    fcgInspection.inspectionProperties ip
JOIN fcgInspection.inspection i
    ON i.id = ip.inspectionId
where ip.updatedAt >= '{{params.start_ts}}' and ip.updatedAt < '{{params.end_ts}}'