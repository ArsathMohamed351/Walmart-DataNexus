{% set walmart_b = obt_table_config() %}

SELECT 
{%for config in walmart_b %}
    {{config['columns']}} 
    {%if not loop.last%},{%endif%}
{%endfor%}
FROM 
{% for config in walmart_b %}
{% if loop.first %}
    {{config['table_name']}} AS {{config['alias']}}
{%else%}
    LEFT JOIN {{config['table_name']}} AS {{config['alias']}} ON {{config['join_condition']}}
{%endif%}
{%endfor%}