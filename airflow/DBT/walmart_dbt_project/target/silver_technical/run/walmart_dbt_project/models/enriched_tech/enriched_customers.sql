-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `walmart`.`enriched_tech`.`enriched_customers` as DBT_INTERNAL_DEST
    using
        `enriched_customers__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.`customer_id` <=> DBT_INTERNAL_DEST.`customer_id`
          
    when matched
        then update set
            *
    when not matched
        then insert
            *
