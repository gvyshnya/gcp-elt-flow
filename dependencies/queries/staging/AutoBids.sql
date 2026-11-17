SELECT
a.id as 'auto_bid_id',
a.auctionId as 'auction_id',
a.userId as 'dealer_id',
a.userEmail as 'dealer_email',
a.maxBid as 'max_bid_sum',
a.currentPrice as 'current_price',
if(a.isValid = 1, true, false) as 'is_valid',
UNIX_TIMESTAMP(a.createdAt) as 'created_at',
UNIX_TIMESTAMP(a.updatedAt) as 'updated_at',
UNIX_TIMESTAMP(a.deletedAt) as 'deleted_at',
a.type as 'auto_bid_type',
aa.country as 'country_id'
FROM fcgAuction.autoBid a
JOIN fcgAuction.auction aa on a.auctionId = aa.id
where a.updatedAt >= '{{params.start_ts}}' and a.updatedAt < '{{params.end_ts}}'