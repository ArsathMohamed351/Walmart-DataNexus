
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select employee_id
from `walmart`.`enriched_tech`.`enriched_employees`
where employee_id is null



  
  
      
    ) dbt_internal_test