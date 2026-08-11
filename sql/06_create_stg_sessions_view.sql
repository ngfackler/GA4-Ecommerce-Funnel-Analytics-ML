-- 06_create_stg_sessions_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_sessions` AS
SELECT
  session_id, 
  user_pseudo_id,
  MIN(event_date) AS session_start_date,
  MIN(event_time) AS session_start_time,
  MAX(event_time) AS session_end_time,
  TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_duration_seconds,  
  COUNT(*) AS session_event_count,
  COUNT(DISTINCT event_name) AS distinct_event_count,
  ANY_VALUE(traffic_source_source) AS traffic_source_source,
  ANY_VALUE(traffic_source_medium) AS traffic_source_medium,
  ANY_VALUE(traffic_source_name) AS traffic_source_name,
  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(country) AS country,
  ANY_VALUE(region) AS region, 
  ANY_VALUE(city) AS city,
  MAX(IF(event_name = 'purchase', 1, 0)) AS had_purchase,
  COUNTIF(event_name = 'purchase') AS purchase_count,
  SUM(IFNULL(purchase_revenue, 0)) AS session_revenue
FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events`
GROUP BY session_id, user_pseudo_id; 
