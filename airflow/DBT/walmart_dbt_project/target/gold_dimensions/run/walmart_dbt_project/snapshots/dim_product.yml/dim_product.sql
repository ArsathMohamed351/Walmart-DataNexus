
      merge into `walmart`.`curated`.`dim_product` as DBT_INTERNAL_DEST
        using `dim_product__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and ( DBT_INTERNAL_DEST.`dbt_valid_to` = to_date('9999-12-31') or
                DBT_INTERNAL_DEST.`dbt_valid_to` is null )
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`product_id`, `product_name`, `product_category`, `product_subcategory`, `product_brand`, `product_supplier_name`, `product_created_timestamp`, `product_updated_timestamp`, `product_is_active`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`product_id`, `product_name`, `product_category`, `product_subcategory`, `product_brand`, `product_supplier_name`, `product_created_timestamp`, `product_updated_timestamp`, `product_is_active`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  