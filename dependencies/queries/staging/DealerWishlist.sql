SELECT 
	ad.userId as 'dealer_id',
    ad.wishlist as 'wish_list',
    UNIX_TIMESTAMP(ad.createdAt) as 'created_at',
    UNIX_TIMESTAMP(ad.updatedAt) as 'updated_at',
    UNIX_TIMESTAMP(ad.deletedAt) as 'deleted_at'
    /* , u.country as country_id */
FROM fcgAuction.dealer ad
/* JOIN fcgAuth.user u ON u.id = ad.userId */
WHERE /* u.userClass = 'DEALER' AND  Romoving cross-service dependencies */
ad.updatedAt >= '{{params.start_ts}}' and ad.updatedAt < '{{params.end_ts}}'