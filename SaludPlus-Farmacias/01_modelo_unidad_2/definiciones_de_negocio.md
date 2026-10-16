# Definiciones de negocio

| Concepto | Definición adoptada |
|---|---|
| Rentabilidad | Utilidad bruta de la línea de venta: columna generada `margen = monto_total − costo_total`, con `monto_total = cantidad × precio_unitario − descuento` y `costo_total = cantidad × costo_unitario`. En el reporte se suma por producto y región. |
| Región | Columna `region` de `dim_sucursal`, unida a la fact por `sucursal_key`. |
| Periodos | Q1 2026: `anio = 2026` y `trimestre = 1` (1 de enero al 31 de marzo). Q2 2026: `anio = 2026` y `trimestre = 2` (1 de abril al 30 de junio). |
| Descuentos | Se aplican por línea de producto en el campo `descuento` (promociones de sucursal o beneficios del cliente). Ya están restados dentro de `monto_total` y `margen`, por lo que no se restan otra vez. La restricción `ck_fact_descuento_valido` evita que superen el importe bruto. |
| Vencimientos | Cada venta se conecta con `dim_lote` mediante `lote_key`, lo que permite analizar `costo_lote` y `fecha_caducidad` para detectar rotación de productos próximos a vencer. |
| Devoluciones y cancelaciones | El Data Mart no incluye tabla de devoluciones ni estado de cancelación. Se asume que `fact_venta` recibe únicamente transacciones efectivas desde el sistema origen, por lo que no se aplican ajustes adicionales al cálculo de rentabilidad. |
