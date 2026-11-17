SELECT 
    b.id as 'bid_id', 
    UNIX_TIMESTAMP(b.createdAt) as 'bid_datetime', 
    b.amount as 'bid_amount', 
	UNIX_TIMESTAMP(b.updatedAt) as 'bid_last_modified', 
    b.status as 'bid_status',
    b.bidType as 'bid_type', 
    UNIX_TIMESTAMP(b.deletedAt) as 'deleted_at', 
    b.userEmail as 'dealer_email',
    b.userId as 'dealer_id', 
    b.auctionId as 'auction_id',
    a.country as 'country_id',
    b.placedByEmail as 'placed_by_name',
    b.causedByUserId as 'caused_by_user_id',
    b.causedByUserEmail as 'caused_by_name',
    b.placedById as 'placed_by_user_id'
FROM fcgAuction.bid b 
JOIN fcgAuction.auction a ON a.id = b.auctionId
where b.updatedAt >= '{{params.start_ts}}' and b.updatedAt < '{{params.end_ts}}'