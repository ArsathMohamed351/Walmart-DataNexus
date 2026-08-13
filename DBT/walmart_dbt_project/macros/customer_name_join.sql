{% macro customer_name_join(first_name, last_name) %}
    concat({{ first_name }}, ' ', {{ last_name }})
{% endmacro %}