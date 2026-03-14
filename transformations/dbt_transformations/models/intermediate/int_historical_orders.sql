-- int_historical_orders.sql
with src as (
  select
    *
  from {{ ref('stg_historical_orders') }}
),


dedup as (
  select
    s.*,
    count(*) over (partition by s.codigo) as items_cantidad,
  from src s
  qualify row_number() over (
    partition by codigo
    order by
      fecha_creacion desc,
      codigo desc
  ) = 1

)

select
  id as row_id,
  codigo as order_id,
  
  nombre,
  codigo_estado,
  codigo_licitacion,
  descripcion_obervaciones as descripcion,
  codigo_tipo,
  tipo,
  tipo_moneda_oc as tipo_moneda,
  codigo_estado_proveedor,
  estado_proveedor,

  -- fechas
  fecha_creacion,
  fecha_aceptacion,
  fecha_cancelacion,
  fecha_ultima_modificacion,

  tiene_items,
  promedio_calificacion,
  cantidad_evaluacion,
  descuentos,
  cargos,
  
  total_neto_oc as monto_total_neto, -- monto neto sim impuesto
  porcentaje_iva,
  monto_total_oc as monto_total, -- monto con impuesto en moneda original
  monto_total_oc_pesos_chilenos as monto_total_clp,
  impuesto, -- monto del impuesto sobre monto_total_neto

  pais,
  tipo_despacho,
  forma_pago as forma_de_pago,

  -- comprador
  codigo_organismo_publico as codigo_organismo,
  organismo_publico as nombre_organismo,
  rut_unidad_compra as rut_unidad,
  codigo_unidad_compra as codigo_unidad,
  unidad_compra as nombre_unidad,
  actividad_comprador,
  -- direccion unidad
  ciudad_unidad_compra as comuna_unidad,
  region_unidad_compra as region_unidad,
  pais_unidad_compra as pais_comprador,
  -- contacto: nombre, cargo, fono, mail
  
  -- proveedor
  codigo_proveedor,
  actividad_proveedor,
  codigo_sucursal,
  sucursal as nombre_sucursal,
  rut_sucursal,
  comuna_proveedor,
  region_proveedor,
  -- direccion
  pais_proveedor,
  -- contacto: nombre, cargo, fono mail

  -- total de items (diferente de item_cantidad especifico de un producto)
  items_cantidad
from dedup