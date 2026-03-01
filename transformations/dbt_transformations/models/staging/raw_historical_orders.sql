with source as (
    select * from {{ source('raw_data', 'raw_orders') }}
),

renamed as (
    select
        id,
        codigo,
        link,
        nombre,
        descripcion_obervaciones,
        tipo,
        procedenciaoc as procedencia_aoc,
        estratodirecto as estrato_directo,
        escompraagil as es_compra_agil,
        codigotipo as codigo_tipo,
        codigoabreviadotipooc as codigo_abreviado_tipo_oc,
        descripciontipooc as descripcion_tipo_oc,
        codigoestado as codigo_estado,
        estado,
        codigoestadoproveedor as codigo_estado_proveedor,
        estadoproveedor as estado_proveedor, -- renamed
        fechacreacion as fecha_creacion, -- renamed
        fechaenvio as fecha_envio, -- renamed
        fechasolicitudcancelacion as fecha_solicitud_cancelacion, -- renamed
        fechaultimamodificacion as fecha_ultima_modificacion, -- renamed
        fechaaceptacion as fecha_aceptacion, -- renamed
        fechacancelacion as fecha_cancelacion, -- renamed
        tieneitems as tiene_items, -- renamed
        promediocalificacion as promedio_calificacion, -- renamed
        cantidadevaluacion as cantidad_evaluacion, -- renamed
        montototaloc as monto_total_oc, -- renamed
        tipomonedaoc as tipo_moneda_oc, -- renamed
        montototaloc_pesoschilenos as monto_total_oc_pesos_chilenos, -- renamed
        impuestos,
        tipoimpuesto as tipo_impuesto, -- renamed
        descuentos,
        cargos,
        totalnetooc as total_neto_oc, -- renamed
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
        financiamiento,
        porcentajeiva as porcentaje_iva, -- renamed
        pais,
        tipodespacho as tipo_despacho, -- renamed
        formapago as forma_pago, -- renamed
        codigolicitacion as codigo_licitacion, -- renamed
        codigo_conveniomarco as codigo_convenio_marco, -- renamed
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
        precioneto as precio_neto, -- renamed
        totalcargos as total_cargos, -- renamed
        totaldescuentos as total_descuentos, -- renamed
        totalimpuestos as total_impuestos, -- renamed
        totallineaneto as total_linea_neto, -- renamed
        forma_de_pago -- ambiguous: can be duplicate/overlap
    from source
)

select * from renamed