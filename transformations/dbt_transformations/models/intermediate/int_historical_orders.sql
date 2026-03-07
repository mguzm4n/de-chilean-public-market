-- here clean, filter nulls or something.
select *
from {{ ref('stg_historical_orders') }}
