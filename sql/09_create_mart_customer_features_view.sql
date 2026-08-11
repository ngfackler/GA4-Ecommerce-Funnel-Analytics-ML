-- 09_create_mart_customer_features_view.sql

CREATE OR REPLACE VIEW `ga4-ecommerce-portfolio-504020.ga4_ecommerce.mart_customer_features` AS
WITH
  event_features AS (
    SELECT
      user_pseudo_id, 
      MIN(event_date) AS first_seen_date,
      MAX(event_date) AS last_seen_date,
      DATE_DIFF(DATE '2020-12-31', MAX(event_date), DAY) AS days_since_last_seen,
      COUNT(DISTINCT event_date) AS active_days,
      DATE_DIFF(MAX(event_date), MIN(event_date), DAY) AS customer_span_days,
      COUNT(DISTINCT IF(event_date >= DATE '2020-12-25', event_date, NULL)) AS active_days_last_7_days,
      COUNT(DISTINCT IF(event_date >= DATE '2020-12-18', event_date, NULL)) AS active_days_last_14_days,
      COUNT(*) AS total_events,
      COUNTIF(event_date >= DATE '2020-12-25') AS events_last_7_days,
      COUNTIF(event_date >= DATE '2020-12-18') AS events_last_14_days,
      COUNTIF(event_name = 'view_item') AS view_item_events, 
      COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
      COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events, 
      COUNTIF(event_name = 'add_shipping_info') AS add_shipping_info_events,
      COUNTIF(event_name = 'add_payment_info') AS add_payment_info_events,
      COUNTIF(event_name = 'purchase') AS purchase_events,
      SUM(IFNULL(purchase_revenue, 0)) AS total_revenue,
      ARRAY_AGG(country ORDER BY event_timestamp DESC LIMIT 1)[OFFSET(0)] AS last_country,
      ARRAY_AGG(device_category ORDER BY event_timestamp DESC LIMIT 1)[OFFSET(0)] AS last_device_category,
      ARRAY_AGG(traffic_source_source ORDER BY event_timestamp DESC LIMIT 1)[OFFSET(0)] AS last_traffic_source,
      ARRAY_AGG(traffic_source_medium ORDER BY event_timestamp DESC LIMIT 1)[OFFSET(0)] AS last_traffic_medium
    FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events`
    WHERE event_date BETWEEN DATE '2020-11-01' AND DATE '2020-12-31'
    GROUP BY user_pseudo_id 
  ),
  session_features AS(
    SELECT
      user_pseudo_id,
      COUNT (*) AS session_count, 
      AVG(session_duration_seconds) AS avg_session_duration_seconds,
      MAX(session_duration_seconds) AS max_session_duration_seconds,
      COUNTIF(had_purchase = 1) AS purchase_sessions
    FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_sessions`
    WHERE session_start_date BETWEEN DATE '2020-11-01' AND DATE '2020-12-31'
    GROUP BY user_pseudo_id
  ),
  funnel_features AS(
    SELECT
      user_pseudo_id,
      SUM(reached_view_item) AS ordered_view_item_sessions,
      SUM(reached_add_to_cart) AS ordered_add_to_cart_sessions, 
      SUM(reached_begin_checkout) AS ordered_begin_checkout_sessions, 
      SUM(reached_add_shipping) AS ordered_add_shipping_sessions, 
      SUM(reached_add_payment) AS ordered_add_payment_sessions, 
      SUM(reached_purchase) AS ordered_purchase_sessions
    FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.ordered_session_funnel`
    WHERE session_start_date BETWEEN DATE '2020-11-01' AND DATE '2020-12-31'
    GROUP BY user_pseudo_id 
  ),
  january_users AS(
    SELECT
      DISTINCT user_pseudo_id
    FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events`
    WHERE event_date BETWEEN DATE '2021-01-01' AND DATE '2021-01-31'
  ),
  january_purchasers AS(
    SELECT
      DISTINCT user_pseudo_id
    FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.stg_events`
    WHERE event_date BETWEEN DATE '2021-01-01' AND DATE '2021-01-31' 
      AND event_name = 'purchase'
  )
SELECT
  ef.user_pseudo_id, 
  ef.first_seen_date, 
  ef.last_seen_date, 
  ef.days_since_last_seen,
  ef.customer_span_days,
  ef.active_days_last_7_days,
  ef.active_days_last_14_days,
  ef.events_last_7_days,
  ef.events_last_14_days,
  ef.active_days,
  ef.total_events,
  ef.view_item_events,
  ef.add_to_cart_events,
  ef.begin_checkout_events,
  ef.add_shipping_info_events,
  ef.add_payment_info_events,
  ef.purchase_events,
  ef.total_revenue,
  ef.last_country,
  ef.last_device_category,
  ef.last_traffic_source,
  ef.last_traffic_medium, 
  
  IFNULL(sf.session_count, 0) AS session_count,
  IFNULL(sf.avg_session_duration_seconds, 0) AS avg_session_duration_seconds,
  IFNULL(sf.max_session_duration_seconds, 0) AS max_session_duration_seconds,
  IFNULL(sf.purchase_sessions, 0) AS purchase_sessions,

  IFNULL(ff.ordered_view_item_sessions, 0) AS ordered_view_item_sessions,
  IFNULL(ff.ordered_add_to_cart_sessions, 0) AS ordered_add_to_cart_sessions,
  IFNULL(ff.ordered_begin_checkout_sessions, 0) AS ordered_begin_checkout_sessions,
  IFNULL(ff.ordered_add_shipping_sessions, 0) AS ordered_add_shipping_sessions,
  IFNULL(ff.ordered_add_payment_sessions, 0) AS ordered_add_payment_sessions,
  IFNULL(ff.ordered_purchase_sessions, 0) AS ordered_purchase_sessions,

  ROUND(SAFE_DIVIDE(ef.total_events, sf.session_count), 2) AS avg_events_per_session,
  ROUND(SAFE_DIVIDE(ef.purchase_events, sf.session_count), 4) AS purchases_per_session,
  ROUND(SAFE_DIVIDE(ef.total_revenue, sf.session_count), 2) AS revenue_per_session,

  IF(ju.user_pseudo_id IS NOT NULL, 1, 0) AS came_back_in_january,
  IF(jp.user_pseudo_id IS NOT NULL, 1, 0) AS purchased_in_january

FROM event_features AS ef
  LEFT JOIN session_features AS sf ON ef.user_pseudo_id = sf.user_pseudo_id
  LEFT JOIN funnel_features AS ff ON ef.user_pseudo_id = ff.user_pseudo_id
  LEFT JOIN january_users AS ju ON ef.user_pseudo_id = ju.user_pseudo_id
  LEFT JOIN january_purchasers AS jp ON ef.user_pseudo_id = jp.user_pseudo_id;
