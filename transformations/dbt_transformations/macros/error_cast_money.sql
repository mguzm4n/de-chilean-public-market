{% macro error_cast_money(column_name, null_values=['NA', 'N/A', '']) %}
  CASE
    WHEN UPPER(TRIM({{ column_name }})) IN (
      {% for val in null_values %}
        '{{ val | upper }}'{% if not loop.last %}, {% endif %}
      {% endfor %}
    ) THEN NULL
    ELSE CAST(ROUND(CAST(REPLACE(TRIM({{ column_name }}), ',', '.') AS NUMERIC)) AS INT64)
  END
{% endmacro %}