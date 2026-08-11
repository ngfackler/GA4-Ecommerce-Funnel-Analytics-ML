-- 05_create_stg_events_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events` AS
SELECT
  event_date AS event_date_raw,
  PARSE_DATE('%Y%m%d', event_date) AS event_date,
  event_timestamp,
  TIMESTAMP_MICROS(event_timestamp) AS event_time,
  user_pseudo_id,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
  event_name,
  traffic_source.source AS traffic_source_source,
  traffic_source.medium AS traffic_source_medium,
  traffic_source.name AS traffic_source_name,
  device.category AS device_category,
  geo.country AS country,
  geo.region AS region, 
  geo.city AS city,
  ecommerce.purchase_revenue AS purchase_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
