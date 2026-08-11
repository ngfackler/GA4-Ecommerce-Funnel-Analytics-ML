-- 01_inspect.sql

-- list tables
SELECT
  table_name,
  creation_time
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.INFORMATION_SCHEMA.TABLES`
ORDER BY table_name;

-- inspect columns in one daily event table
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'events_20201201'
ORDER BY ordinal_position; 

-- preview raw event rows
SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
LIMIT 10; 

-- view event names and counts for first week of December
SELECT
  event_name, 
  COUNT(*) AS event_count 
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201201' AND '20201207'
GROUP BY event_name
ORDER BY event_count DESC; 