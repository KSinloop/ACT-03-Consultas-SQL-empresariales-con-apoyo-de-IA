-- Provoca el error 1055 (ONLY_FULL_GROUP_BY, activo por defecto en MySQL 8).
-- Selecciona producto_id_origen y nombre pero agrupa solo por región.
SELECT
    s.region,
    p.producto_id_origen,
    p.nombre,
    SUM(f.margen) AS rentabilidad_q2
FROM saludplus_dm.fact_venta f
JOIN saludplus_dm.dim_sucursal s USING (sucursal_key)
JOIN saludplus_dm.dim_producto p USING (producto_key)
JOIN saludplus_dm.dim_fecha d USING (fecha_hora_key)
WHERE d.anio = 2026
  AND d.trimestre = 2
GROUP BY s.region;
