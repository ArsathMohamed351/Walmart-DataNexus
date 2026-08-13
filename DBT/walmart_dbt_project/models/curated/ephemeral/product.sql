SELECT
    product_id,
    product_name,
    category AS product_category,
    subcategory AS product_subcategory,
    brand AS product_brand,
    supplier_name AS product_supplier_name,
    product_created_timestamp,
    product_updated_timestamp,
    product_is_active
FROM
    {{ ref('OBT') }}