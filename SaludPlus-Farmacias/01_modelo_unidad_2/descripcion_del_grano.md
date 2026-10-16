# Modelo de referencia y grano

Esquema estrella con la tabla de hechos `fact_venta` y siete dimensiones: `dim_producto`, `dim_lote`, `dim_cliente`, `dim_sucursal`, `dim_empleado`, `dim_canal` y `dim_fecha`. Ver `diagrama_estrella.png` (generado a partir del DDL) y los PDF originales de la Unidad 2.

**Grano:** una fila por combinación de **venta, producto y lote**, después de consolidar líneas duplicadas de la misma transacción. Se garantiza con la restricción `UNIQUE (venta_id_origen, producto_key, lote_key)`.

**Medidas atómicas:** `cantidad`, `precio_unitario`, `descuento`, `costo_unitario`.
**Medidas generadas:** `monto_total = cantidad × precio_unitario − descuento`, `costo_total = cantidad × costo_unitario` y `margen = monto_total − costo_total`.

**Justificación:** cada medida corresponde al mismo ítem de la transacción (producto y lote vendidos en una venta), por lo que son compatibles con ese grano y se pueden sumar sin duplicar importes.
