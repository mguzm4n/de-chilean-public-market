with source as (
    select *  from {{ source('raw_data', 'raw_orders') }}
),

renamed as (
    select
        -- order-specific fields
        id,
        codigo,
        link,
        nombre,
        descripcion_obervaciones,
        tipo,
        procedenciaoc as procedencia_aoc,
        estratodirecto as estrato_directo,
        escompraagil as es_compra_agil,
        {{ safe_cast_codigo('codigotipo') }} as codigo_tipo,
        codigoabreviadotipooc as codigo_abreviado_tipo_oc,
        descripciontipooc as descripcion_tipo_oc,
        {{ safe_cast_codigo('codigoestado') }} as codigo_estado,
        estado,
        {{ safe_cast_codigo('codigoestadoproveedor') }} as codigo_estado_proveedor,
        estadoproveedor as estado_proveedor, -- renamed

        -- dates
        {{ safe_cast_fecha('fechacreacion') }} as fecha_creacion, -- renamed
        {{ safe_cast_fecha('fechaenvio') }} as fecha_envio, -- renamed
        {{ safe_cast_fecha('fechasolicitudcancelacion') }} as fecha_solicitud_cancelacion, -- renamed
        {{ safe_cast_fecha('fechaultimamodificacion') }} as fecha_ultima_modificacion, -- renamed
        {{ safe_cast_fecha('fechaaceptacion') }} as fecha_aceptacion, -- renamed
        {{ safe_cast_fecha('fechacancelacion') }} as fecha_cancelacion, -- renamed

        {{ safe_cast_bool('tieneitems') }} as tiene_items, -- renamed
        promediocalificacion as promedio_calificacion, -- renamed
        cantidadevaluacion as cantidad_evaluacion, -- renamed
        {{ error_cast_money('montototaloc') }} as monto_total_oc, -- renamed, totalnetooc + IVA
        tipomonedaoc as tipo_moneda_oc, -- renamed
        {{ error_cast_money('montototaloc_pesoschilenos') }} as monto_total_oc_pesos_chilenos, -- renamed, totalnetooc + IVA
        {{ error_cast_money('impuestos') }}, -- totalnetooc*IVA
        tipoimpuesto as tipo_impuesto, -- renamed
        descuentos,
        cargos,
        {{ error_cast_money('totalnetooc') }} as total_neto_oc, -- renamed, original NO IVA
        codigounidadcompra as codigo_unidad_compra, -- renamed
        rutunidadcompra as rut_unidad_compra, -- renamed
        unidadcompra as unidad_compra, -- renamed
        codigoorganismopublico as codigo_organismo_publico, -- renamed
        organismopublico as organismo_publico, -- renamed
        sector,
        actividadcomprador as actividad_comprador, -- renamed
        ciudadunidadcompra as ciudad_unidad_compra, -- renamed
        regionunidadcompra as region_unidad_compra, -- renamed
        paisunidadcompra as pais_unidad_compra, -- renamed
        codigosucursal as codigo_sucursal, -- renamed
        rutsucursal as rut_sucursal, -- renamed
        sucursal,
        codigoproveedor as codigo_proveedor, -- renamed
        nombreproveedor as nombre_proveedor, -- renamed
        actividadproveedor as actividad_proveedor, -- renamed
        comunaproveedor as comuna_proveedor, -- renamed
        regionproveedor as region_proveedor, -- renamed
        paisproveedor as pais_proveedor, -- renamed
        {{ null_if_empty_str('financiamiento') }},
        {{ error_cast_money('porcentajeiva') }} as porcentaje_iva, -- renamed
        pais,
        {{ safe_cast_codigo('tipodespacho') }} as tipo_despacho, -- renamed
        {{ safe_cast_codigo('formapago') }} as forma_pago, -- renamed
        {{ null_if_empty_str('codigolicitacion') }} as codigo_licitacion, -- renamed
        codigo_conveniomarco as codigo_convenio_marco, -- renamed

        -- product specific types
        iditem as id_item, -- renamed
        codigocategoria as codigo_categoria, -- renamed
        categoria,
        codigoproductoonu as codigo_producto_onu, -- renamed
        nombreroductogenerico as nombre_producto_generico, -- renamed (typo? "nombreroductogenerico" looks like missing 'p' in producto)
        rubron1 as rubro_n1, -- renamed
        rubron2 as rubro_n2, -- renamed
        rubron3 as rubro_n3, -- renamed
        especificacioncomprador as especificacion_comprador, -- renamed
        especificacionproveedor as especificacion_proveedor, -- renamed
        cantidad,
        unidadmedida as unidad_medida, -- renamed
        monedaitem as moneda_item, -- renamed
        {{ error_cast_money('precioneto') }} as precio_neto, -- renamed
        totalcargos as total_cargos, -- renamed
        totaldescuentos as total_descuentos, -- renamed
        {{ error_cast_money('totalimpuestos') }} as total_impuestos, -- renamed
        {{ error_cast_money('totallineaneto') }} as total_linea_neto, -- renamed
        forma_de_pago -- forma de pago specific to this product instead of order
    from source
)

select * from renamed