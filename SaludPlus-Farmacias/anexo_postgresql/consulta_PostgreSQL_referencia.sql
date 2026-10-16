/*
  Consulta de referencia en PostgreSQL (la versión final entregada es la de MySQL, en 04_consultas_sql) - Top 5 de productos más rentables por región,
  Q2 2026 vs Q1 2026. Motor: PostgreSQL 15 o superior. Esquema: saludplus_dm.

  Optimización respecto a consulta_v1_ia.sql (versión inicial de la IA):
  - Agrupa por clave y calcula Q1 y Q2 en una sola agregación con FILTER.
  - Elimina el LEFT JOIN entre Q2 y Q1 (en el plan original, el agregado de
    Q1 se recorría 20 veces).
  - Une los datos del producto después del ranking.
  Validación: equivalente a la v1 (EXCEPT ALL en ambas direcciones: 20 filas,
  0 diferencias). Comparación de planes en 05_validacion_y_explain.
*/
WITH agregado AS (
 SELECT s.region,f.producto_key,
 SUM(f.margen) FILTER(WHERE d.trimestre=2) AS rentabilidad_q2,
 SUM(f.margen) FILTER(WHERE d.trimestre=1) AS rentabilidad_q1
 FROM saludplus_dm.fact_venta f
 JOIN saludplus_dm.dim_sucursal s USING(sucursal_key)
 JOIN saludplus_dm.dim_fecha d USING(fecha_hora_key)
 WHERE d.anio=2026 AND d.trimestre IN(1,2)
 GROUP BY s.region,f.producto_key
 HAVING COUNT(*) FILTER(WHERE d.trimestre=2)>0
), ranking AS (
 SELECT *,ROW_NUMBER() OVER(PARTITION BY region
 ORDER BY rentabilidad_q2 DESC,producto_key) AS posicion FROM agregado
)
SELECT r.region,r.posicion,p.producto_id_origen,p.nombre,
 ROUND(r.rentabilidad_q2,2) AS rentabilidad_q2,
 ROUND(r.rentabilidad_q1,2) AS rentabilidad_q1,
 ROUND(r.rentabilidad_q2-r.rentabilidad_q1,2) AS variacion_absoluta,
 ROUND(100*(r.rentabilidad_q2-r.rentabilidad_q1)
 /NULLIF(r.rentabilidad_q1,0),2) AS variacion_porcentual,
 r.rentabilidad_q1 IS NULL AS sin_datos_q1
FROM ranking r JOIN saludplus_dm.dim_producto p USING(producto_key)
WHERE r.posicion<=5 ORDER BY r.region,r.posicion;
