{% macro safe_cast_fecha(column_name) %}
  SAFE.PARSE_DATE('%Y-%m-%d', NULLIF({{ column_name }}, ''))
{% endmacro %}