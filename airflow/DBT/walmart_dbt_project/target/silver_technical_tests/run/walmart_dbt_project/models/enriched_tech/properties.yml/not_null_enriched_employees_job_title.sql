
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select job_title
from (select * from `walmart`.`enriched_tech`.`enriched_employees` where salary > 0) dbt_subquery
where job_title is null



  
  
      
    ) dbt_internal_test