with src as (
  select
    *
  from {{ ref('stg_historical_orders') }}
)

select 
  id_item as item_id,
  codigo as order_id,
  
  nombre_producto_generico,
  codigo_producto_onu,

  categoria,
  codigo_categoria

  rubro_n1,
  rubro_n2,
  rubro_n3,

  especificacion_comprador,
  especificacion_proveedor

  item_cantidad as cantidad,
  unidad_medida,
  moneda_item as moneda,

  precio_neto, -- sin impuesto
  total_impuestos,
  total_linea_neto, -- monto final

  total_cargos,
  total_descuentos,

  forma_de_pago,
from src