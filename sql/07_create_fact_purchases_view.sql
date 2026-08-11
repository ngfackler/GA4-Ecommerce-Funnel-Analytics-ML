-- 07_create_fact_purchases_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.fact_purchases` AS
SELECT 
  event_date, 
  event_time,
  user_pseudo_id,
  session_id,
  traffic_source_source,
  traffic_source_medium,
  traffic_source_name,
  device_category,
  country,
  region,
  city,
  purchase_revenue,
  ROW_NUMBER() OVER (
    PARTITION BY user_pseudo_id
    ORDER BY event_time
  ) AS user_purchase_number
FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events`
WHERE event_name = 'purchase'