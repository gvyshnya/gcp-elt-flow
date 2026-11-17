SELECT
    cc.id as car_contact_id,
    cc.carId as car_id,
    cc.company as car_company,
    cc.salutation,
    cc.firstName as first_name,
    cc.lastName as last_name,
    cc.email,
    cc.phone,
    cc.street as contact_address,
    cc.zip,
    cc.city, 
    cc.comment as contact_comment, 
    cc.type as contact_type,
    cc.subtype as contact_subtype, 
    UNIX_TIMESTAMP(cc.createdAt) as created_at, 
    UNIX_TIMESTAMP(cc.updatedAt) as updated_at, 
    UNIX_TIMESTAMP(cc.deletedAt) as deleted_at, 
    cc.createdById as created_by_id,
    cc.createdByName as created_by,
    cc.updatedById as updated_by_id,
    cc.updatedByName as updated_by,
    cc.deletedById as deleted_by_id,
    cc.deletedByName as deleted_by,
    cc.taxId as tax_id,
    cc.bankAccountOwner as bank_account_owner,
    cc.bankCode as bank_code,
    cc.bankAccountNumber as bank_account_number,
    cc.bankName as bank_name,
    cc.accountType as account_type,
    cc.bankAccountOwnerTaxId as bank_account_owner_tax_id,
    cc.bankContactDetails as bank_account_details,
    cc.occupation,
    cc.maritalStatus as marital_status,
    cc.reasonForSelling as selling_reason,
    cc.referrerCode as referrer_code,
    c.country as country_id
FROM fcgCar.contact cc
    JOIN fcgCar.car c on cc.carId = c.id
where cc.updatedAt >= '{{params.start_ts}}' and cc.updatedAt < '{{params.end_ts}}'

/*
Table: contact
Columns:
id char(36) PK 
carId char(36) 
company varchar(256) 
salutation varchar(256) 
firstName varchar(256) 
lastName varchar(256) 
email varchar(256) 
phone varchar(256) 
street varchar(256) 
zip varchar(256) 
city varchar(256) 
comment text 
type enum('seller','contactPersonSeller','buyer','consignee','shippingCompany','customs') 
subtype text 
createdAt datetime 
updatedAt datetime 
deletedAt datetime 
createdById varchar(256) 
createdByName varchar(256) 
updatedById varchar(256) 
updatedByName varchar(256) 
deletedById varchar(256) 
deletedByName varchar(256) 
taxId varchar(256) 
bankAccountOwner varchar(256) 
bankCode varchar(256) 
bankAccountNumber varchar(256) 
bankName varchar(256) 
accountType varchar(256) 
bankAccountOwnerTaxId varchar(256) 
bankContactDetails varchar(256) 
occupation varchar(64) 
maritalStatus varchar(64) 
reasonForSelling varchar(256)

*/