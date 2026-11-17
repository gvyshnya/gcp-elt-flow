/*
	BI 2.O Auction Staging Design Notes/Changes
    - car_id eliminated as Auctions-to-Cars reference won't be maintained directly
        Added directly from Auctions table.
    - winning_dealer_id column introduced
    - attributes below decided to be implemented as view attributes down the road
    -- has_winner redesigned -> Done
    -- auction_number_of_comments -> Done
    -- auction_number_of_damages -> Done
    -- auction_car_quality_score -> We will get the categories field.
    -- auction_number_added_to_favorites -> Done
    -- auction_buy_now_price_usd (?)
    -- auction_start_price_usd (?)
    -- number_of_bids - from Bids
    -- number_of_bidders - from Bids
    -- first_bid_date - from Bids
    -- last_bid_date - from Bids
    -- winning_bid_price - from Bids
    -- winning_bid_price_usd (?)
    -- price_increase_pcnt - needs Bids Data
    -- won_by_buy_now - from Bibs
    
*/ 
SELECT
	a.id as 'auction_id', 
    UNIX_TIMESTAMP(a.createdAt) as 'auction_created_date',
    if(a.buyNowPossible=1, true, false) as 'buy_now_enabled',
    if(aww.winner_dealer_id is not null, 1, 0) as 'has_winner',
    aww.winner_dealer_id,
	a.status as 'auction_status',
    a.type as 'auction_type',
	a.start/1000 as 'auction_start_date',
	a.end/1000 as 'auction_end_date',
	UNIX_TIMESTAMP(a.updatedAt) as 'auction_last_modified',
    COALESCE(JSON_LENGTH(a.comments), 0) as 'auction_number_of_comments',
    COALESCE(JSON_LENGTH(a.damages), 0) as 'auction_number_of_damages',
    a.categories as 'categories_score',
    (select count(f.id) from fcgAuction.favorite f where f.inspectionId = a.inspectionId) as 'auction_number_added_to_favorites',
	a.originalEnd/1000 as 'auction_original_end_date',
	ROUND(1 + a.stepId / 2, 0) as 'runs', 
    a.price as 'auction_start_price',
    a.buyNowPrice as 'auction_buy_now_price',
	a.totalExtensions as 'number_of_extensions', 
    a.visibleRound as 'visible_round',
    a.schedulerId as 'scheduler_id',
    a.make, 
    a.model,
    a.trim, 
    a.year, 
    a.fuel,
    a.mileage,
    substring_index(a.transmission, '.', -1) as 'transmission',
    a.createdByName as 'created_by',
    a.cancellationReason as 'cancellation_reason',
    if(a.preAutoBidPossible=1, true, false) as 'pre_autobid_possible', 
    a.flow as 'flow',
	UNIX_TIMESTAMP(a.deletedAt) as 'deleted_at',
	a.inspectionId as 'inspection_id',
    a.carId as 'car_id',
    a.sellerExpectationPrice as 'seller_expected_price',
    a.country as 'country_id'
FROM fcgAuction.auction a
LEFT OUTER JOIN (
    SELECT 
        aa.id as 'auction_id', 
        aa.highestBidderId as 'winner_dealer_id' 
	FROM fcgAuction.auction aa 
	WHERE aa.deletedAt is null and aa.highestBidderId is not null and
	aa.status IN ('stopped' , 'started') AND
		FROM_UNIXTIME(aa.end/1000) < now()
) aww ON  /* auctions with winners */
a.id = aww.auction_id
where a.updatedAt >= '{{params.start_ts}}' and a.updatedAt < '{{params.end_ts}}'