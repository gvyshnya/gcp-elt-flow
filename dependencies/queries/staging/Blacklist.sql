SELECT 
bl.id as "blacklist_id",
bl.auctionId as "auction_id",
bl.dealerId as "dealer_id",
UNIX_TIMESTAMP(bl.createdAt) as "created_at",
UNIX_TIMESTAMP(bl.updatedAt) as "updated_at",
UNIX_TIMESTAMP(bl.deletedAt) as "deleted_at",
a.country as 'country_id'
from fcgAuction.blacklist bl
JOIN fcgAuction.auction a ON a.id = bl.auctionId
where bl.updatedAt >= '{{params.start_ts}}' and bl.updatedAt < '{{params.end_ts}}'
