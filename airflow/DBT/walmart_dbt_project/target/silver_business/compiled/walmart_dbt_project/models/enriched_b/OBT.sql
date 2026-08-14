

SELECT 

    
            o.order_id,
            o.customer_id,
            o.store_id,
            o.order_timestamp,
            o.order_status,
            o.payment_method,
            o.sales_channel,
            o.discount_amount AS order_discount_amount,
            o.tax_amount AS order_tax_amount,
            o.shipping_cost,
            o.created_timestamp AS order_created_timestamp,
            o.updated_timestamp AS order_updated_timestamp,
            o.is_active AS order_is_active,
            o.total_amount
         
    ,

    
            c.first_name AS customer_first_name,
            c.last_name AS customer_last_name,
            c.customer_full_name,
            c.customer_segment,
            c.loyalty_tier,
            c.city AS customer_city,
            c.created_timestamp AS customer_created_timestamp,
            c.updated_timestamp AS customer_updated_timestamp,
            c.is_active AS customer_is_active,
            c.province AS customer_province,
            c.country AS customer_country
         
    ,

    
            oi.order_item_id,
            oi.quantity,
            oi.unit_price,
            oi.discount_amount AS item_discount_amount,
            oi.tax_amount AS item_tax_amount,
            oi.line_amount
         
    ,

    
            p.product_id,
            p.product_name,
            p.category,
            p.subcategory,
            p.brand,
            p.price AS product_price,
            p.cost_price,
            p.created_timestamp AS product_created_timestamp,
            p.updated_timestamp AS product_updated_timestamp,
            p.is_active AS product_is_active,
            p.supplier_name
         
    ,

    
            s.store_name,
            s.city AS store_city,
            s.province AS store_province,
            s.country AS store_country,
            s.store_type,
            s.created_timestamp AS store_created_timestamp,
            s.updated_timestamp AS store_updated_timestamp,
            s.is_active AS store_is_active,
            s.store_size_sqft
         
    ,

    
            e.employee_id,
            e.first_name AS employee_first_name,
            e.last_name AS employee_last_name,
            e.email AS employee_email,
            e.job_title AS employee_job_title,
            e.department AS employee_department,
            e.updated_timestamp AS employee_updated_timestamp,
            e.created_timestamp AS employee_created_timestamp,
            e.is_active AS employee_is_active,
            e.employment_type AS employee_employment_type
         
    

FROM 


    walmart.enriched_tech.enriched_order AS o



    LEFT JOIN walmart.enriched_tech.enriched_customers AS c ON o.customer_id = c.customer_id



    LEFT JOIN walmart.enriched_tech.enriched_order_items AS oi ON o.order_id = oi.order_id



    LEFT JOIN walmart.enriched_tech.enriched_products AS p ON oi.product_id = p.product_id



    LEFT JOIN walmart.enriched_tech.enriched_stores AS s ON o.store_id = s.store_id



    LEFT JOIN walmart.enriched_tech.enriched_employees AS e ON o.store_id = e.store_id

