-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `walmart`.`enriched_tech`.`enriched_employees` as DBT_INTERNAL_DEST
    using
        `enriched_employees__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.`employee_id` <=> DBT_INTERNAL_DEST.`employee_id`
          
    when matched
        then update set
            *
    when not matched
        then insert
            *
