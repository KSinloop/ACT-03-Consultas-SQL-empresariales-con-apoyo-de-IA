-- Consulta de control: recalcula la rentabilidad desde las medidas atómicas
-- (cantidad, precio_unitario, descuento, costo_unitario), sin usar la columna
-- generada margen, y se compara contra los totales de la consulta final.
USE saludplus_dm;

WITH control AS (
    SELECT s.region, d.trimestre,
           ROUND(SUM(f.cantidad * f.precio_unitario - f.descuento
                     - f.cantidad * f.costo_unitario), 2) AS total_control
    FROM fact_venta f
    JOIN dim_sucursal s USING (sucursal_key)
    JOIN dim_fecha    d USING (fecha_hora_key)
    WHERE d.anio = 2026 AND d.trimestre IN (1, 2)
    GROUP BY s.region, d.trimestre
),
consulta AS (
    SELECT s.region, d.trimestre, ROUND(SUM(f.margen), 2) AS total_consulta
    FROM fact_venta f
    JOIN dim_sucursal s USING (sucursal_key)
    JOIN dim_fecha    d USING (fecha_hora_key)
    WHERE d.anio = 2026 AND d.trimestre IN (1, 2)
    GROUP BY s.region, d.trimestre
)
SELECT c.region, CONCAT('Q', c.trimestre, ' 2026') AS trimestre,
       c.total_control, q.total_consulta,
       c.total_control - q.total_consulta AS diferencia
FROM control c
JOIN consulta q ON q.region = c.region AND q.trimestre = c.trimestre
ORDER BY c.region, c.trimestre;

-- Verificación de unicidad del grano (debe devolver 0 filas)
SELECT venta_id_origen, producto_key, lote_key, COUNT(*) AS repeticiones
FROM fact_venta
GROUP BY venta_id_origen, producto_key, lote_key
HAVING COUNT(*) > 1;
