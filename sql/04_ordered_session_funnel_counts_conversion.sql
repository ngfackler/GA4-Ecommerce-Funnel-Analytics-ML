-- 04_ordered_session_funnel_counts_conversion.sql

WITH ordered_counts AS (
  SELECT 
    SUM(reached_view_item) AS view_item,
    SUM(reached_add_to_cart) AS add_to_cart,
    SUM(reached_begin_checkout) AS begin_checkout,
    SUM(reached_add_shipping) AS add_shipping_info,
    SUM(reached_add_payment) AS add_payment_info, 
    SUM(reached_purchase) AS purchase
  FROM `ga4-ecommerce-portfolio-504020.ga4_ecommerce.ordered_session_funnel`
  WHERE session_start_date BETWEEN '2020-12-01' AND '2020-12-31'
)
SELECT
  *,
  ROUND(SAFE_DIVIDE(add_to_cart, view_item), 4) AS add_to_cart_conv_rate, 
  ROUND(SAFE_DIVIDE(begin_checkout, add_to_cart), 4) AS begin_checkout_conv_rate,
  ROUND(SAFE_DIVIDE(add_shipping_info, begin_checkout), 4) AS add_shipping_conv_rate,
  ROUND(SAFE_DIVIDE(add_payment_info, add_shipping_info), 4) AS add_payment_conv_rate,
  ROUND(SAFE_DIVIDE(purchase, add_payment_info), 4) AS purchase_conv_rate,
  ROUND(SAFE_DIVIDE(purchase, view_item), 4) AS view_to_purchase_conv_rate
FROM ordered_counts;

