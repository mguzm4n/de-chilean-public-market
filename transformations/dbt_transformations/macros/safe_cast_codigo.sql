{% macro safe_cast_codigo(column_name) %}
  SAFE_CAST(NULLIF(TRIM({{ column_name }}), '') AS INT64)
{% endmacro %}