-- 02_user_funnel_counts_conversion.sql

WITH funnel_users AS(
  SELECT
    CASE event_name
      WHEN 'view_item' THEN 1
      WHEN 'add_to_cart' THEN 2
      WHEN 'begin_checkout' THEN 3
      WHEN 'add_shipping_info' THEN 4
      WHEN 'add_payment_info' THEN 5
      WHEN 'purchase' THEN 6
    END AS funnel_step,
    event_name, 
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS user_count
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201201' AND '20201207'
    AND event_name IN(
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase'
    )
  GROUP BY funnel_step, event_name
),
funnel_users_with_previous AS(  
  SELECT
    funnel_step,
    event_name, 
    event_count,
    user_count,
    LAG(user_count) OVER(ORDER BY funnel_step) AS previous_user_count
  FROM funnel_users
), 
overall_rate AS(
  SELECT
    MAX(IF(event_name = 'view_item', user_count, NULL)) AS view_item_users,
    MAX(IF(event_name = 'purchase', user_count, NULL)) AS purchase_users
  FROM funnel_users
)
SELECT
  funnel_step,
  event_name,
  event_count,
  user_count,
  previous_user_count,
  ROUND(SAFE_DIVIDE(user_count, previous_user_count), 4) AS conversion_rate,
  ROUND(SAFE_DIVIDE(purchase_users, view_item_users), 4) AS view_to_purchase_conv_rate
FROM funnel_users_with_previous
  CROSS JOIN overall_rate
ORDER BY funnel_step; 




