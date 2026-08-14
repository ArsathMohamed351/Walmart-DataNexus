with __dbt__cte__customer as (

SELECT 
    DISTINCT
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_full_name,
    customer_segment,
    customer_city,
    customer_province,
    customer_created_timestamp,
    customer_updated_timestamp,
    customer_is_active,
    customer_country,
    current_timestamp() AS curated_customer_processed_at
FROM 
    `walmart`.`enriched_business`.`obt`
) select * from __dbt__cte__customer