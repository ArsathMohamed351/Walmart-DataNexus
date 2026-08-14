
    
    

select
    store_id as unique_field,
    count(*) as n_records

from (select * from `walmart`.`enriched_tech`.`enriched_stores` where store_size_sqft > 0) dbt_subquery
where store_id is not null
group by store_id
having count(*) > 1


