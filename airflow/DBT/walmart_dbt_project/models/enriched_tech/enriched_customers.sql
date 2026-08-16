{{ config(unique_key='customer_id') }}

SELECT 
    *,
    {{ customer_name_join('first_name', 'last_name') }} AS customer_full_name,
    current_timestamp() AS processed_at
FROM 
    {{ ref('customers_raw') }}

{% if is_incremental() %}
    WHERE updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}