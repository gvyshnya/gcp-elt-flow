SELECT
    cc.id as car_paperwork_id,
    cc.carId as car_id,
    c.country as country_id,
    cc.documentStatus as doc_status,
    cc.documentHandoverToBuyer as doc_handover_to_buyer_status,
    cc.documentLocation as doc_location,
    cc.comment as doc_comment, 
    UNIX_TIMESTAMP(cc.createdAt) as created_at, 
    UNIX_TIMESTAMP(cc.updatedAt) as updated_at, 
    UNIX_TIMESTAMP(cc.deletedAt) as deleted_at, 
    cc.createdById as created_by_id,
    cc.createdByName as created_by,
    cc.updatedById as updated_by_id,
    cc.updatedByName as updated_by,
    cc.deletedById as deleted_by_id,
    cc.deletedByName as deleted_by,
    UNIX_TIMESTAMP(cc.documentHandoverfromSellerDate) as doc_handover_from_seller_date, 
    UNIX_TIMESTAMP(cc.documentHandoverToBuyerDate) as doc_handover_to_buyer_date
FROM fcgCar.paperwork cc
    JOIN fcgCar.car c on c.id = cc.carId
where cc.updatedAt >= '{{params.start_ts}}' and cc.updatedAt < '{{params.end_ts}}'

/*
Table: paperwork
Columns (as of Mar 6, 2019):

id char(36) PK 
carId char(36) 
documentStatus varchar(256) 
documentHandoverToBuyer enum('no','partially','yes') 
documentLocation varchar(256) 
comment text 
createdAt datetime 
updatedAt datetime 
deletedAt datetime 
createdById varchar(256) 
createdByName varchar(256) 
updatedById varchar(256) 
updatedByName varchar(256) 
deletedById varchar(256) 
deletedByName varchar(256) 
documentHandoverfromSellerDate datetime 
documentHandoverToBuyerDate datetime
*/