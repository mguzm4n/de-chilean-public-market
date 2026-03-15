{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
      "field": "fecha_creacion",
      "data_type": "date",
      "granularity": "month",
    },
    cluster_by = ["order_id"],
  )
}}

with data as (
  select * from {{ ref('int_historical_buys') }}
  {% if is_incremental() %}
    where ingestion_date >= (select max(ingestion_date) from {{ this }})
  {% endif %}
)

select *
from data