SELECT DISTINCT u.id as 'dealer_id',
CONCAT(u.firstname, ' ', u.lastname) as 'dealer_name',
If(u.metaInfo ->> '$.email' IN ('null', ''), null, u.metaInfo ->> '$.email') as 'dealer_email',
0 as 'dealer_number_of_favorites',
/* ad.maxBidAmount as 'dealer_bid_limit',
UNIX_TIMESTAMP(ad.updatedAt) as 'dealer_bid_limit_date',  --Cross Service fields */
UNIX_TIMESTAMP(u.createdAt) as 'dealer_created',
UNIX_TIMESTAMP(u.updatedAt) as 'dealer_last_modified',
u.metaInfo ->> '$.companyName' as 'dealer_company_name',
u.metaInfo ->> '$.dealerManager' as 'dealer_manager_id',
(CASE WHEN
(u.metaInfo ->> '$.dealerManager' IS NOT NULL
AND u.metaInfo ->> '$.dealerManager' <> ' ')
THEN (SELECT CONCAT(U.firstname, ' ', U.lastname) FROM fcgAuth.user U
WHERE U.id = (u.metaInfo ->> '$.dealerManager')) ELSE NULL
END) AS 'dealer_manager_name',
u.metaInfo ->> '$.onboardingAgent' as 'dealer_onboarding_agent_id',
(CASE WHEN
(u.metaInfo ->> '$.onboardingAgent' IS NOT NULL
AND u.metaInfo ->> '$.onboardingAgent' <> ' ')
THEN (SELECT CONCAT(U.firstname, ' ', U.lastname) FROM fcgAuth.user U
WHERE U.id = (u.metaInfo ->> '$.onboardingAgent')) ELSE NULL
END) AS 'dealer_onboarding_agent_name',
u.metaInfo ->> '$.legalCompanyName' as 'dealer_company_legal_name',
u.metaInfo ->> '$.legalCompanyTax' as 'dealer_company_legal_tax',
u.metaInfo ->> '$.taxId' as 'dealer_tax_id',
u.metaInfo ->> '$.street' as 'dealer_address',
u.metaInfo ->> '$.city' as 'dealer_city',
u.metaInfo ->> '$.phone' as 'dealer_phone',
u.metaInfo ->> '$.zipCode' as 'dealer_zipecode',
u.metaInfo ->> '$.maxAmountBids' as 'max_amount_of_bids',
u.metaInfo ->> '$.blockedReason' as 'blocked_reason',
u.metaInfo ->> '$.businessCategory' as 'dealer_category',
u.metaInfo ->> '$.dealerSize' as 'dealer_size',
u.metaInfo ->> '$.registrationId' as 'registration_id',
u.metaInfo ->> '$.taxOffice' as 'tax_office',
u.metaInfo ->> '$.authorizedPickupPersons' as 'authorized_pickup_persons',
u.metaInfo ->> '$.paymentTerms' as 'payment_terms',
u.metaInfo ->> '$.bankDetails' as 'bank_details',
u.metaInfo ->> '$.comments' as 'dealer_comments',
u.metaInfo ->> '$.internalId' as 'internal_id',
(CASE WHEN
(u.metaInfo ->> '$.systemSetCreditLimit' IS NOT NULL
AND (u.metaInfo ->> '$.systemSetCreditLimit' = ' ' OR u.metaInfo ->> '$.systemSetCreditLimit' = 'null'))
THEN 0 
WHEN (u.metaInfo ->> '$.systemSetCreditLimit' IS NOT NULL) THEN u.metaInfo ->> '$.systemSetCreditLimit'
ELSE NULL
END) AS 'system_set_credit_limit',
(CASE WHEN
(u.metaInfo ->> '$.systemSetDepositAmount' IS NOT NULL
AND (u.metaInfo ->> '$.systemSetDepositAmount' = ' ' OR u.metaInfo ->> '$.systemSetDepositAmount' = 'null'))
THEN 0 
WHEN (u.metaInfo ->> '$.systemSetDepositAmount' IS NOT NULL) THEN u.metaInfo ->> '$.systemSetDepositAmount'
ELSE NULL
END) AS 'system_set_deposit_amount',
if(lower(u.email) REGEXP '[.]int|[.]doe[.]|@dubizzle[.]com|@acgargentina[.]com[.]ar|@vendenostuauto[.]com|@autobastas[.]cl|@acgcol[.]com|@belimobilgue[.]co[.]id|@redicar[.]co[.]id|@olx[.]com|@fcglatam[.]com|@americascargroup[.]com|@cars45[.]com|@carfirst[.]com|@test[.]com' = 1, true, false) as 'is_internal',
UNIX_TIMESTAMP(u.deletedAt) as 'deleted_at', 
UPPER(u.country) as 'country_id',
COALESCE(SUBSTRING_INDEX(u.metaInfo ->> '$.status', '.', -1), 'inactive') as 'dealer_status', /* TODO: Should we replicate browsing logic? */
u.internalId as 'dealer_number',
COALESCE(SUBSTRING(TRIM(BOTH '\"' FROM JSON_EXTRACT(u.metaInfo, '$.status')), 1, 64), 'inactive') as 'dealer_cms_status',
u.metaInfo ->> '$.virtualAccountOrWalletId' as 'virtual_account',
u.email as 'dealer_login',
u.metaInfo ->> '$.dealerBidManager' as 'dealer_bid_manager',
u.metaInfo as 'meta_info' /* ,
u.metaInfo ->> '$.personType' as 'person_type',
u.metaInfo ->> '$.legalRepresentativeName' as 'legal_representative_name' */
FROM fcgAuth.user u
WHERE
u.userClass = 'DEALER'
and u.updatedAt >= '{{params.start_ts}}' and u.updatedAt < '{{params.end_ts}}'