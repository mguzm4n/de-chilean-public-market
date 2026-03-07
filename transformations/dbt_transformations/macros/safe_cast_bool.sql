{% macro safe_cast_bool(col) -%}
  case
    when {{ col }} is null then null
    when trim({{ col }}) = '1' then true
    when trim({{ col }}) = '0' then false
    else null
  end
{%- endmacro %}