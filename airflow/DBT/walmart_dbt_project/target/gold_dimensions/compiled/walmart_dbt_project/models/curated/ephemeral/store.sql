

SELECT
    DISTINCT
    store_id,
    store_name,
    store_city,
    store_province,
    store_country,
    store_type,
    store_created_timestamp,
    store_updated_timestamp,
    store_is_active,
    current_timestamp() AS curated_store_processed_at
FROM
    `walmart`.`enriched_business`.`obt`