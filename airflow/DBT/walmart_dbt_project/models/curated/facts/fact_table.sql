SELECT
    order_id,
    customer_id,
    product_id,
    order_item_id,
    store_id,
    employee_id,
    order_discount_amount,
    order_tax_amount,
    shipping_cost,
    total_amount,
    quantity,
    unit_price,
    item_discount_amount,
    item_tax_amount,
    line_amount,
    product_price,
    cost_price,
    store_size_sqft
FROM
    {{ref('OBT')}}    

    