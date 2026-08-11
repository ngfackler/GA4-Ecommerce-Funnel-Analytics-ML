-- 08_create_fact_items_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.fact_items` AS
SELECT
  event_date AS event_date_raw,
  PARSE_DATE('%Y%m%d', event_date) AS event_date,
  event_timestamp,
  TIMESTAMP_MICROS(event_timestamp) AS event_time,
  user_pseudo_id,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
  event_name,
  item.item_id AS item_id, 
  item.item_name AS item_name, 
  item.item_brand AS item_brand,
  item.item_variant AS item_variant,
  item.item_category AS item_category,
  item.item_category2 AS item_category2,
  item.item_category3 AS item_category3,
  item.price AS price,
  item.quantity AS quantity,
  item.item_revenue AS item_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item;