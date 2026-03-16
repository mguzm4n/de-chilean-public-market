{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
      "field": "ingestion_date",
      "data_type": "date",
      "granularity": "month",
    },
    cluster_by = ["order_id"],
  )
}}

with data as (
  select * from {{ ref('int_historical_buys') }}
  {% if is_incremental() %}
    {% set logical_date = var('logical_date') %}
    where DATE(ingestion_date) = DATE('{{ logical_date }}')
  {% endif %}
)

select *
from data