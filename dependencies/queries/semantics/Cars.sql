  SELECT * EXCEPT(dedup) FROM (
  SELECT
      c.car_id,
      c.internal_car_id,
      DATETIME(c.car_created, cmt.country_timezone) as car_created,
      DATETIME(GREATEST(
          coalesce(c.car_last_modified, '1970-01-01'), 
          coalesce(i.inspection_last_modified, '1970-01-01'), 
          coalesce(cc.updated_at, '1970-01-01'), 
          coalesce(timestamp(purchase_dates.a_purchase_date), '1970-01-01'), 
          coalesce(cp.updated_at, '1970-01-01'), 
          coalesce(cfd.updated_at, '1970-01-01'), 
          coalesce(cpay.payment_last_modified, '1970-01-01'),
          coalesce(csts.updated_at, '1970-01-01'), 
          coalesce(document.updated_at, '1970-01-01'),
          coalesce(cloc.updated_at, '1970-01-01'),
          coalesce(purchase_user.user_last_modified, '1970-01-01'), 
          coalesce(sell_user.user_last_modified, '1970-01-01')
      ), cmt.country_timezone) as car_last_modified,
      DATETIME(c.car_handedover_from_seller, cmt.country_timezone) as car_handedover_from_seller,
      DATETIME(c.car_handedover_to_buyer, cmt.country_timezone) as car_handedover_to_buyer,
      DATETIME(c.car_pick_up_from_date, cmt.country_timezone) as available_for_pickup,
      coalesce(replace(json_extract_scalar(i.inspection_report, '$.fuel'), "inspection.field.fuelType.", ""), "Unknown") as car_fuel,
      c.car_mileage,
      coalesce(lower(replace(json_extract_scalar(i.inspection_report, '$.transmission'), "inspection.field.transmissionType.", "")), "Unknown") as car_transmission,
      c.year_manufactured,
      c.car_color,
      c.car_vin,
      c.car_license_plate,
      c.car_engine_number,
      c.car_registered_city,
      DATETIME(c.car_technical_check_expiration, cmt.country_timezone) as car_technical_check_expiration,
      csts.car_selling_status,
      csts.car_physical_status,
      csts.car_legal_status,
      csts.car_purchase_payment_status,
      csts.car_selling_payment_status,
      csts.selling_status_reason,
      csts.physical_status_reason,
      csts.legal_status_reason,
      csts.purchase_payment_status_reason,
      csts.selling_payment_status_reason,
      document.doc_status as car_document_status,
      c.car_type,
      cloc.car_current_location,
      cloc.car_purchase_location,
      cloc.car_selling_location,
      (select count(1) from `{{params.project_name}}.staging.CarTransits` ct where ct.car_id = c.car_id and ct.deleted_at is null) as number_of_transits,
      /* USD conversions */
      COALESCE(cp.car_purchase_price_car, 0) as car_purchase_price_car,
      ROUND(COALESCE(cp.car_purchase_price_car, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_car_usd,
      COALESCE(cp.car_purchase_price_transport, 0) as car_purchase_price_transport,
      ROUND(COALESCE(cp.car_purchase_price_transport, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_transport_usd,
      COALESCE(cp.car_purchase_price_delivery, 0) as car_purchase_price_delivery,
      ROUND(COALESCE(cp.car_purchase_price_delivery, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_delivery_usd,
      COALESCE(cp.car_purchase_price_repairs, 0) as car_purchase_price_repairs,
      ROUND(COALESCE(cp.car_purchase_price_repairs, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_repairs_usd,
      COALESCE(cp.car_purchase_price_documentation, 0) as car_purchase_price_documentation,
      ROUND(COALESCE(cp.car_purchase_price_documentation, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_documentation_usd,
      COALESCE(cp.car_purchase_price_delivery_driver, 0) as car_purchase_price_delivery_driver,
      ROUND(COALESCE(cp.car_purchase_price_delivery_driver, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_delivery_driver_usd,
      COALESCE(cp.car_purchase_price_penalty, 0) as car_purchase_price_penalty,
      ROUND(COALESCE(cp.car_purchase_price_penalty, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_penalty_usd,
      COALESCE(cp.car_purchase_price_debts, 0) as car_purchase_price_debts,
      ROUND(COALESCE(cp.car_purchase_price_debts, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_debts_usd,
      COALESCE(cp.car_purchase_price_penalty_projected, 0) as car_purchase_price_penalty_projected,
      ROUND(COALESCE(cp.car_purchase_price_penalty_projected, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_penalty_projected_usd,
      COALESCE(cp.car_purchase_price_logistics, 0) as car_purchase_price_logistics,
      ROUND(COALESCE(cp.car_purchase_price_logistics, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_logistics_usd,
      COALESCE(cp.car_purchase_price_others, 0) as car_purchase_price_others,
      ROUND(COALESCE(cp.car_purchase_price_others, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_others_usd,
      COALESCE(cp.car_purchase_price_total, 0) as car_purchase_price_total,
      ROUND(COALESCE(cp.car_purchase_price_total, 0) / purchase_fx.exchange_rate_to_USD, 2) as car_purchase_price_total_usd,
      cfd.initial_valuation_price,
      cfd.seller_expectation_price as seller_expected_price,
      ROUND(cfd.seller_expectation_price / purchase_fx.exchange_rate_to_USD, 2) as seller_expectation_price_usd,
      cfd.seller_first_offer as first_offer_price,
      ROUND(cfd.seller_first_offer / purchase_fx.exchange_rate_to_USD, 2) as seller_first_offer_usd,
      cfd.seller_final_offer as final_offer_price,
      ROUND(cfd.seller_final_offer / purchase_fx.exchange_rate_to_USD, 2) as seller_final_offer_usd,
      cfd.competitor_price,
      ROUND(cfd.competitor_price / purchase_fx.exchange_rate_to_USD, 2) as competitor_price_usd,
      /* end USD conversion */
      if(cfd.country_id = 'IN' AND cfd.purchase_channel IS NULL, 'C2B', cfd.purchase_channel) as purchase_channel,
      purchase_user.user_email as purchased_by,
      purchase_user.user_name as purchased_by_name,
      cfd.sale_channel as sales_channel,
      DATETIME(cfd.reserved_at, cmt.country_timezone) as reserved_at_date,
      DATETIME(cfd.confirmed_at, cmt.country_timezone) as confirmed_at_date,
      sell_user.user_email as sold_by,
      sell_user.user_name as sold_by_name,
      /* sold_to not computed let's wait is further joins are required before using Users Table. */
      cfd.sold_to_id as sold_to_id,
      DATETIME(cfd.invoice_date, cmt.country_timezone) as invoice_date,
      /* More USD conversions */
      COALESCE(cp.car_selling_price_car, 0) as car_selling_price_car,
      ROUND(COALESCE(cp.car_selling_price_car, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_car_usd,
      COALESCE(cp.car_selling_price_iaas, 0) as car_selling_price_iaas,
      ROUND(COALESCE(cp.car_selling_price_iaas, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_iaas_usd,
      COALESCE(cp.car_selling_price_valuations, 0) as car_selling_price_valuations,
      ROUND(COALESCE(cp.car_selling_price_valuations, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_valuations_usd,
      COALESCE(cp.car_selling_price_penalty, 0) as car_selling_price_penalty,
      ROUND(COALESCE(cp.car_selling_price_penalty, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_penalty_usd,
      COALESCE(cp.car_selling_price_interest_bank, 0) as car_selling_price_interest_bank,
      ROUND(COALESCE(cp.car_selling_price_interest_bank, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_interest_bank_usd,
      COALESCE(cp.car_selling_price_interest, 0) as car_selling_price_interest,
      ROUND(COALESCE(cp.car_selling_price_interest, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_interest_usd,
      COALESCE(cp.car_selling_price_discount_fleet, 0) as car_selling_price_discount_fleet,
      ROUND(COALESCE(cp.car_selling_price_discount_fleet, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_discount_fleet_usd,
      COALESCE(cp.car_selling_price_other, 0) as car_selling_price_other,
      ROUND(COALESCE(cp.car_selling_price_other, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_other_usd,
      COALESCE(cp.car_selling_price_total, 0) as car_selling_price_total,
      ROUND(COALESCE(cp.car_selling_price_total, 0) / sale_fx.exchange_rate_to_USD, 2) as car_selling_price_total_usd,
      COALESCE(cpay.car_outgoing_payment_total, 0) as car_outgoing_payment_total,
      ROUND((select COALESCE(cpay.car_outgoing_payment_total, 0) / ex.exchange_rate_to_USD
      from `{{params.project_name}}.staging.ExchangeRates` ex
      where cmt.country_currency = ex.currency_symbol
      and date(ex.exchange_rate_date) = DATE_SUB(date(cpay.latest_outgoing_payment_date), INTERVAL 1 DAY)), 2) as car_outgoing_payment_total_usd,
      COALESCE(cpay.car_outgoing_payment_total_net, 0) as car_outgoing_payment_total_net,
      ROUND((select COALESCE(cpay.car_outgoing_payment_total_net, 0) / ex.exchange_rate_to_USD
      from `{{params.project_name}}.staging.ExchangeRates` ex
      where cmt.country_currency = ex.currency_symbol
      and date(ex.exchange_rate_date) = DATE_SUB(date(cpay.latest_outgoing_payment_date), INTERVAL 1 DAY)), 2) as car_outgoing_payment_total_net_usd,
      COALESCE(cpay.car_incoming_payment_total, 0) as car_incoming_payment_total,
      ROUND((select COALESCE(cpay.car_incoming_payment_total, 0) / ex.exchange_rate_to_USD
      from `{{params.project_name}}.staging.ExchangeRates` ex
      where cmt.country_currency = ex.currency_symbol
      and date(ex.exchange_rate_date) = DATE_SUB(date(cpay.latest_incoming_payment_date), INTERVAL 1 DAY)), 2) as car_incoming_payment_total_usd,
      COALESCE(cpay.car_incoming_payment_total_net, 0) as car_incoming_payment_total_net,
      ROUND((select COALESCE(cp.car_selling_price_car, 0) / ex.exchange_rate_to_USD
      from `{{params.project_name}}.staging.ExchangeRates` ex
      where cmt.country_currency = ex.currency_symbol
      and date(ex.exchange_rate_date) = DATE_SUB(date(cpay.latest_incoming_payment_date), INTERVAL 1 DAY)), 2) as car_incoming_payment_total_net_usd,
      /* End of USD conversions */
      DATETIME(cfd.sold_at, cmt.country_timezone) as car_sold_date,
      DATETIME(cpay.latest_outgoing_payment_date, cmt.country_timezone) as latest_outgoing_payment_date,
      DATETIME(cpay.latest_incoming_payment_date, cmt.country_timezone) as latest_incoming_payment_date,
      DATETIME(cfd.bought_at, cmt.country_timezone) as car_purchased_date,
      DATETIME(c.deleted_at, cmt.country_timezone) as deleted_at,
      c.car_manufacturer, /* Discuss normalization with the Team */
      c.car_model , /* Also normalization */
      c.country_id,
      cc.contact_subtype as client_subtype,
      (select count(1) from `{{params.project_name}}.staging.Auctions` a where a.car_id = c.car_id and a.deleted_at is null) as visible_in_auctions_count,
      round(if(car_selling_price_total = 0, NULL, (cp.car_selling_price_total - cp.car_purchase_price_total) / cp.car_selling_price_total),4) as margin,
      c.source_car_id,
      cfd.b2b_deal,
      COALESCE(cfd.reserve_auction_price, 0) as reserve_auction_price,
      ROUND((select COALESCE(cfd.reserve_auction_price, 0) / ex.exchange_rate_to_USD
      from `{{params.project_name}}.staging.ExchangeRates` ex
      where cmt.country_currency = ex.currency_symbol
      and date(ex.exchange_rate_date) = DATE_SUB(date(cfd.reserved_at), INTERVAL 1 DAY)), 2) as reserve_auction_price_usd,
      cloc.car_selling_location_place_id,
      cloc.car_purchase_location_place_id,
      cloc.car_current_location_place_id,
      cc.tax_id as seller_tax_id,
      cc.zip as seller_zip_code,
      cc.bank_account_owner_tax_id as seller_registration_id,
      cfd.purchase_comment,
      c.car_trim,
      document.doc_location as car_document_location,
      cfd.invoice_number,
      c.created_by,
      c.created_by_id,
      cfd.purchase_cancellation_reason,
      cfd.chosen_financing_options,
      c.booking_id,
      c.car_grade,
      car_purchase_documents.purchase_doc_count,
      ROUND(car_selling_prices_vat.car_selling_price_excl_vat, 6) as car_selling_price_excl_vat,
      row_number() over(partition by c.car_id order by car_last_modified desc) as dedup 
  FROM `{{params.project_name}}.staging.Cars` c
  INNER JOIN `{{params.project_name}}.staging.CountryMetadata` as cmt using(country_id)
  LEFT JOIN (select * except(dedup) from (
  select *, row_number() over(partition by car_id order by inspection_last_modified desc) as dedup from `{{params.project_name}}.staging.Inspections`
  where deleted_at is null and inspection_type ='seller')
  where dedup = 1) i on i.car_id = c.car_id
  LEFT JOIN (select * except(dedup) from (
  select *, row_number() over(partition by car_id order by updated_at desc) as dedup from `{{params.project_name}}.staging.CarContacts`
  where deleted_at is null and contact_type  ='seller')
  where dedup = 1) cc on cc.car_id = c.car_id
  LEFT JOIN (
    SELECT car_id, 
    (
      CASE WHEN (car_selling_status = 'NOTAVAILABLE' and car_physical_status = 'ATOWNER' AND car_legal_status = 'OWNER') THEN NULL
        WHEN (car_handedover_from_seller IS NULL) THEN car_purchased_date
        ELSE car_handedover_from_seller
      END
    ) AS a_purchase_date
    FROM `{{params.project_name}}.semantics_central.Cars`
  ) purchase_dates on purchase_dates.car_id = c.car_id
  LEFT JOIN (
      select cars.car_id,
      (
        CASE -- Standards for SALES measures
            WHEN (cars.country_id = 'AR' 
                AND cars.confirmed_at_date IS NOT NULL
                AND cars.car_sold_date IS NOT NULL)
            THEN IF(car_sold_date < cars.confirmed_at_date, car_sold_date, cars.confirmed_at_date)

            WHEN cars.country_id = 'CO' THEN cars.car_sold_date

            WHEN cars.country_id = 'CL' THEN
                CASE
                    WHEN (DATE(cars.confirmed_at_date) >= "2019-06-01"
                        AND cars.sales_channel in ( 'OnlineAuction', 'YardsaleBuyNow')
                    ) THEN cars.confirmed_at_date
                    ELSE IF(cars.invoice_date IS NOT NULL, cars.invoice_date,cars.car_sold_date)
                END

            WHEN cars.country_id = 'IN' THEN cars.car_sold_date     
     
            WHEN cars.country_id = 'NG' THEN
                CASE
                    WHEN cars.car_sold_date IS NOT NULL
                        AND auction.a_yardsale_start_date IS NULL
                        AND (cars.invoice_date IS NULL
                        OR DATETIME_DIFF(cars.invoice_date, car_sold_date, MONTH) > 0
                        ) --THEN "Lock Down - Available" 
                    THEN cars.car_sold_date
                    WHEN cars.car_sold_date IS NOT NULL
                        AND cars.invoice_date IS NOT NULL
                        AND DATETIME_DIFF(cars.invoice_date, car_sold_date, MONTH) = 0
                        AND DATE(cars.car_sold_date) <> DATE(cars.invoice_date) --THEN "Lock Down - Sold Same Month" 
                    THEN cars.invoice_date
                    WHEN cars.car_sold_date IS NOT NULL
                        AND cars.invoice_date IS NOT NULL
                        AND DATE(cars.car_sold_date) = DATE(cars.invoice_date) --THEN "Outright Sales" 
                    THEN cars.invoice_date
                END

            WHEN cars.country_id = 'PK' THEN cars.car_handedover_to_buyer 

            WHEN cars.country_id = 'PL' AND (cars.invoice_date IS NOT NULL) THEN cars.invoice_date

            WHEN cars.country_id = 'ID' AND cars.car_sold_date IS NOT NULL THEN cars.car_sold_date
   
            WHEN cars.country_id not in ('ID') THEN
                CASE
                    WHEN (cars.sales_channel in ('OnlineAuction', 'YardsaleBuyNow')) 
                        AND (cars.confirmed_at_date IS NOT NULL) 
                    THEN cars.confirmed_at_date           
                    WHEN (cars.sales_channel in ('OnlineAuction', 'YardsaleBuyNow'))
                        AND cars.confirmed_at_date IS NULL
                        AND cars.reserved_at_date IS NOT NULL 
                    THEN cars.reserved_at_date
                    WHEN (cars.sales_channel in ('OnlineAuction', 'YardsaleBuyNow'))
                        AND cars.confirmed_at_date IS NULL
                        AND cars.reserved_at_date IS NULL
                        AND cars.car_sold_date IS NOT NULL
                    THEN cars.car_sold_date          
                END   
         
            WHEN cars.car_sold_date IS NULL AND cars.country_id not in ('ID') 
                THEN cars.car_handedover_to_buyer

            ELSE cars.car_sold_date
        END
      ) AS a_sales_date
      FROM `{{params.project_name}}.semantics_central.Cars` cars
      LEFT JOIN (
        SELECT
            car_id,
            auction_type,
            MAX(auction_start_date) AS a_yardsale_start_date
        FROM `{{params.project_name}}.semantics_central.Auctions`
        WHERE
            auction_type = 'yardsale'
        GROUP BY
            car_id,
            auction_type) AS auction
        ON
            cars.car_id = auction.car_id
  ) sales_dates on sales_dates.car_id = c.car_id
  LEFT JOIN (
      SELECT reference_id as car_id, count(*) as purchase_doc_count 
      FROM `{{params.project_name}}.staging.Documents`
      WHERE document_entity = 'purchase' AND deleted_at IS NULL
      GROUP BY reference_id
  ) car_purchase_documents on car_purchase_documents.car_id = c.car_id
  LEFT JOIN (
      WITH inspections as
      (
          SELECT 
          inspection_id, 
          car_id,
          JSON_EXTRACT_SCALAR(inspection_report, '$.carLength') AS car_length,
          SAFE_CAST(JSON_EXTRACT_SCALAR(inspection_report, '$.cubicCapacity') as float64) AS cubic_capacity,
          REPLACE (regexp_replace(JSON_EXTRACT(inspection_report, '$.fuel'), 'inspection.field.fuelType.', ''),'\"','') as fuel_type
          FROM `{{params.project_name}}.staging.Inspections`
          WHERE country_id = 'IN'
      )
      SELECT
          cc2.car_id, 
          round(CASE --sales price VAT excluding process
          WHEN cc2.country_id = 'IN' THEN 
              CASE
              WHEN cpp.car_selling_price_car > cpp.car_purchase_price_car THEN
                      CASE
                          WHEN car_length = 'Greater than/Equal to 4 metres' AND 
                              fuel_type in ('CGNpetrol','petrol') 
                              AND cubic_capacity > 1200
                           THEN cpp.car_selling_price_car-(((cpp.car_selling_price_car - cpp.car_purchase_price_car)/1.18)*0.18)

                          WHEN car_length = 'Greater than/Equal to 4 metres' AND fuel_type in ('diesel') 
                                  AND cubic_capacity >= 1500
                           THEN cpp.car_selling_price_car-(((cpp.car_selling_price_car - cpp.car_purchase_price_car)/1.18)*0.18)
                          WHEN fuel_type in ('Electric')
                           THEN cpp.car_selling_price_car-(((cpp.car_selling_price_car - cpp.car_purchase_price_car)/1.18)*0.18)
                          ELSE cpp.car_selling_price_car-(((cpp.car_selling_price_car - cpp.car_purchase_price_car)/1.12)*0.12)
                      END
              ELSE cpp.car_selling_price_car
              END

          WHEN cc2.country_id = 'PL'THEN 
              CASE
              WHEN cpp.car_selling_price_car > cpp.car_purchase_price_car
                  THEN IF (purchase_channel in ('B2BWithoutVAT','C2B')
                      ,cpp.car_selling_price_car - ((cpp.car_selling_price_car - cpp.car_purchase_price_car)*0.23/1.23)
                      ,cpp.car_selling_price_car/1.23)
              WHEN  cpp.car_selling_price_car <= cpp.car_purchase_price_car
                  THEN IF (purchase_channel in ('B2BVAT')
                      ,cpp.car_selling_price_car/1.23
                      ,cpp.car_selling_price_car)
              END
          ELSE 
          CASE -- catching errors 
            WHEN cpp.car_purchase_price_car  is null then -2
            WHEN cpp.car_purchase_price_car = 0 then -3
            WHEN cpp.car_selling_price_car is null then -4
            WHEN cpp.car_selling_price_car = 0 then -5 
            WHEN cpp.car_selling_price_car = 0 or cpp.car_purchase_price_car = 0 then -6
            WHEN cpp.car_selling_price_car is null or cpp.car_purchase_price_car is null then -7

            ELSE -1 -- a dummy placeholder for countries not implemented yet
            END
          END,3) as car_selling_price_excl_vat
      FROM `{{params.project_name}}.staging.Cars` cc2
      LEFT JOIN inspections i USING (car_id)
      LEFT JOIN `{{params.project_name}}.staging.vCarPricingDenorm` cpp on cpp.car_id = cc2.car_id
      LEFT JOIN `{{params.project_name}}.staging.CarFinancialDetails` cfd_vat on cfd_vat.car_id = cc2.car_id
      WHERE cfd_vat.sold_at IS NOT NULL 
  ) as car_selling_prices_vat on car_selling_prices_vat.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.vCarPricingDenorm` cp on cp.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.CarFinancialDetails` cfd on cfd.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.ExchangeRates` purchase_fx on cmt.country_currency = purchase_fx.currency_symbol and date(purchase_fx.exchange_rate_date) = DATE_SUB(date(purchase_dates.a_purchase_date), INTERVAL 1 DAY)
  LEFT JOIN `{{params.project_name}}.staging.ExchangeRates` sale_fx on cmt.country_currency = sale_fx.currency_symbol and date(sale_fx.exchange_rate_date) = DATE_SUB(date(sales_dates.a_sales_date), INTERVAL 1 DAY)
  LEFT JOIN `{{params.project_name}}.staging.vCarPaymentsDenorm` cpay on cpay.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.vCarStatusDenorm` csts on csts.car_id = c.car_id
  LEFT JOIN (select * except(dedup) from (
  select *, row_number() over(partition by car_id order by updated_at desc) as dedup from `{{params.project_name}}.staging.CarPaperWork`)
  where dedup = 1) document on document.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.vCarLocationsDenorm` cloc on cloc.car_id = c.car_id
  LEFT JOIN `{{params.project_name}}.staging.InternalUsers` purchase_user on cfd.purchased_by_id = purchase_user.user_id
  LEFT JOIN `{{params.project_name}}.staging.InternalUsers` sell_user on cfd.sale_rep = sell_user.user_id
  where (
      c.car_last_modified >= '{{params.start_ts}}' and c.car_last_modified < '{{params.end_ts}}'
      or
      cfd.updated_at >= '{{params.start_ts}}' and cfd.updated_at < '{{params.end_ts}}'
      or
      cloc.updated_at >= '{{params.start_ts}}' and cloc.updated_at < '{{params.end_ts}}'
      or
      cpay.payment_last_modified >= '{{params.start_ts}}' and cpay.payment_last_modified < '{{params.end_ts}}'
      or
      cp.updated_at >= '{{params.start_ts}}' and cp.updated_at < '{{params.end_ts}}'
      or
      csts.updated_at >= '{{params.start_ts}}' and csts.updated_at < '{{params.end_ts}}'
      or
      document.updated_at >= '{{params.start_ts}}' and document.updated_at < '{{params.end_ts}}'
  )
  ) WHERE dedup = 1