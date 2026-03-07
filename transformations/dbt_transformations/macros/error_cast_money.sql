{% macro error_cast_money(column_name) %}
  CAST(ROUND(CAST(REPLACE({{ column_name }}, ',', '.') AS NUMERIC)) AS INT64)
{% endmacro %}