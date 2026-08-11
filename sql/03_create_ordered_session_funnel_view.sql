-- 03_create_ordered_session_funnel_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.ordered_session_funnel` AS
WITH 
  events_with_sessions AS (
    SELECT
      event_date, 
      event_timestamp,
      user_pseudo_id,
      event_name, 
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  ),

  session_funnel AS ( 
    SELECT 
      user_pseudo_id,
      session_id,
      MIN(PARSE_DATE('%Y%m%d', event_date)) AS session_start_date,
      MIN(event_timestamp) AS session_start_timestamp,
      MAX(event_timestamp) AS session_end_timestamp,
      MIN(IF(event_name = 'view_item', event_timestamp, NULL)) AS first_view_item,
      MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL)) AS first_add_to_cart,
      MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS first_begin_checkout,
      MIN(IF(event_name = 'add_shipping_info', event_timestamp, NULL)) AS first_add_shipping,
      MIN(IF(event_name = 'add_payment_info', event_timestamp, NULL)) AS first_add_payment, 
      MIN(IF(event_name = 'purchase', event_timestamp, NULL)) AS first_purchase
    FROM events_with_sessions
    WHERE session_id IS NOT NULL
    GROUP BY user_pseudo_id, session_id
  ),

  ordered_funnel AS (
    SELECT
      user_pseudo_id,
      session_id,
      session_start_date,
      session_start_timestamp,
      session_end_timestamp,

      IF(first_view_item IS NOT NULL, 1, 0) AS reached_view_item,
      IF(
        first_view_item IS NOT NULL 
        AND first_add_to_cart >= first_view_item,
        1,
        0
      ) AS reached_add_to_cart,
      IF(
        first_view_item IS NOT NULL 
        AND first_add_to_cart >= first_view_item
        AND first_begin_checkout >= first_add_to_cart,
        1,
        0
      ) AS reached_begin_checkout,
      IF(
        first_view_item IS NOT NULL
        AND first_add_to_cart >= first_view_item
        AND first_begin_checkout >= first_add_to_cart
        AND first_add_shipping >= first_begin_checkout,
        1,
        0
      ) AS reached_add_shipping,
      IF(
        first_view_item IS NOT NULL
        AND first_add_to_cart >= first_view_item
        AND first_begin_checkout >= first_add_to_cart
        AND first_add_shipping >= first_begin_checkout
        AND first_add_payment >= first_add_shipping,
        1,
        0
      ) AS reached_add_payment,
      IF(
        first_view_item IS NOT NULL
        AND first_add_to_cart >= first_view_item
        AND first_begin_checkout >= first_add_to_cart
        AND first_add_shipping >= first_begin_checkout
        AND first_add_payment >= first_add_shipping
        AND first_purchase >= first_add_payment,
        1,
        0
      ) AS reached_purchase
    FROM session_funnel
  )

SELECT 
  user_pseudo_id,
  session_id,
  session_start_date,
  session_start_timestamp,
  session_end_timestamp,
  reached_view_item,
  reached_add_to_cart,
  reached_begin_checkout,
  reached_add_shipping,
  reached_add_payment,
  reached_purchase
FROM ordered_funnel;