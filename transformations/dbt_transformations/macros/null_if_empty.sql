{% macro null_if_empty_str(column_name) %}
  NULLIF(TRIM({{ column_name }}), '')
{% endmacro %}