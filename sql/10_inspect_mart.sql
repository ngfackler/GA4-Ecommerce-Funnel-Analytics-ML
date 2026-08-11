-- 10_inspect_mart.sql

SELECT
  COUNT(*) AS users,
  SUM(came_back_in_january) AS came_back_in_january_users,
  SUM(purchased_in_january) AS purchased_in_january_users,
  ROUND(AVG(came_back_in_january) * 100, 2) AS came_back_in_january_rate_pct,
  ROUND(AVG(purchased_in_january) * 100, 2) AS purchased_in_january_rate_pct
FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.mart_customer_features`;

SELECT
  MIN(first_seen_date) AS min_first_seen_date,
  MAX(last_seen_date) AS max_last_seen_date,
  AVG(active_days) AS avg_active_days,
  AVG(session_count) AS avg_sessions,
  AVG(total_events) AS avg_events,
  AVG(total_revenue) AS avg_revenue
FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.mart_customer_features`;