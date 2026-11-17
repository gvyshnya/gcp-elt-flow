
SELECT 
cp.id as 'car_pricing_detail_id',
cp.country as 'country_id',
cp.make,
cp.model,
cp.trim,
cp.year, 
cp.price,
cp.minprice as 'min_price',
cp.maxprice as 'max_price',
cp.transmission,
cp.minmarketprice as 'min_market_price', 
cp.maxmarketprice as 'max_market_price',
cp.minpriceb as 'min_price_b',
cp.maxpriceb as 'max_price_b',
cp.priceb as 'price_b',
cp.location,
cp.priceText as 'price_text'
FROM fcg.{{params.table_name}} cp