-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `walmart`.`enriched_tech`.`enriched_order_items` as DBT_INTERNAL_DEST
    using
        `enriched_order_items__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.`order_id` <=> DBT_INTERNAL_DEST.`order_id`
          
    when matched
        then update set
            *
    when not matched
        then insert
            *
