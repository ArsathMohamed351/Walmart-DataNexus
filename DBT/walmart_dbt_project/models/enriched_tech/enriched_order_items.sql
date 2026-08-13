{{ config( unique_key='order_id' ) }}

SELECT 
    *,
    current_timestamp() AS processed_at
FROM 
    {{ref('orders_items_raw') }}

{% if is_incremental() %}
    WHERE updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}