

SELECT
    DISTINCT
    order_id,
    order_item_id,
    order_timestamp,
    order_status,
    payment_method AS order_payment_method,
    order_created_timestamp,
    order_updated_timestamp,
    order_is_active,
    sales_channel AS order_sales_channel
FROM
    `walmart`.`enriched_business`.`obt`