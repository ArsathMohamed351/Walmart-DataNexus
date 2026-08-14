
      merge into `walmart`.`curated`.`dim_employees` as DBT_INTERNAL_DEST
        using `dim_employees__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and ( DBT_INTERNAL_DEST.`dbt_valid_to` = to_date('9999-12-31') or
                DBT_INTERNAL_DEST.`dbt_valid_to` is null )
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`employee_id`, `employee_first_name`, `employee_last_name`, `employee_email`, `employee_job_title`, `employee_updated_timestamp`, `employee_created_timestamp`, `employee_department`, `employee_is_active`, `employee_employment_type`, `curated_employee_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`employee_id`, `employee_first_name`, `employee_last_name`, `employee_email`, `employee_job_title`, `employee_updated_timestamp`, `employee_created_timestamp`, `employee_department`, `employee_is_active`, `employee_employment_type`, `curated_employee_processed_at`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  