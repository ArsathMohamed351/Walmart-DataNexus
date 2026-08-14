

SELECT 
    *,
    
    concat(first_name, ' ', last_name)
 AS customer_full_name,
    current_timestamp() AS processed_at
FROM 
    `walmart`.`raw`.`customers_raw`


    WHERE updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM `walmart`.`enriched_tech`.`enriched_customers`)
