{{ config( materialized='ephemeral') }}

SELECT 
    DISTINCT
    employee_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    employee_job_title,
    employee_updated_timestamp,
    employee_created_timestamp,
    employee_department,
    employee_is_active,
    employee_employment_type,
    current_timestamp() AS curated_employee_processed_at
FROM 
    {{ ref('OBT') }}