SELECT * 
FROM {{ source('raw_data', 'raw_orders') }}