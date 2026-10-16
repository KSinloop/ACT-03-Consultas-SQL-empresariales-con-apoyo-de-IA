/*
  Consulta v1 generada por IA (Claude, Anthropic) - versión inicial, sin modificaciones.
  Reporte: Top 5 de productos más rentables por región, Q2 2026 vs Q1 2026.
  Fue generada con el prompt 01 (motor indicado: PostgreSQL). Usa solo SQL estándar
  (CTE, ROW_NUMBER, LEFT JOIN, NULLIF, ROUND), por lo que se ejecuta SIN cambios
  en MySQL 8. Única diferencia observada: sin_datos_q1 se muestra como 1/0 en
  lugar de true/false. Base de datos: saludplus_dm.
*/

WITH agregado AS (
    SELECT
        s.region,
        p.producto_key,
        p.producto_id_origen,
        p.nombre,
        d.trimestre,
        SUM(f.margen) AS rentabilidad
    FROM saludplus_dm.fact_venta   AS f
    JOIN saludplus_dm.dim_sucursal AS s ON s.sucursal_key   = f.sucursal_key
    JOIN saludplus_dm.dim_producto AS p ON p.producto_key   = f.producto_key
    JOIN saludplus_dm.dim_fecha    AS d ON d.fecha_hora_key = f.fecha_hora_key
    WHERE d.anio = 2026
      AND d.trimestre IN (1, 2)
    GROUP BY s.region, p.producto_key, p.producto_id_origen,
             p.nombre, d.trimestre
),
q2 AS (
    SELECT
        region, producto_key, producto_id_origen, nombre, rentabilidad,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY rentabilidad DESC, producto_key
        ) AS posicion
    FROM agregado
    WHERE trimestre = 2
),
q1 AS (
    SELECT region, producto_key, rentabilidad
    FROM agregado
    WHERE trimestre = 1
)
SELECT
    q2.region,
    q2.posicion,
    q2.producto_id_origen,
    q2.nombre,
    ROUND(q2.rentabilidad, 2)                    AS rentabilidad_q2,
    ROUND(q1.rentabilidad, 2)                    AS rentabilidad_q1,
    ROUND(q2.rentabilidad - q1.rentabilidad, 2)  AS variacion_absoluta,
    ROUND(100 * (q2.rentabilidad - q1.rentabilidad)
          / NULLIF(q1.rentabilidad, 0), 2)       AS variacion_porcentual,
    (q1.rentabilidad IS NULL)                    AS sin_datos_q1
FROM q2
LEFT JOIN q1
       ON q1.region       = q2.region
      AND q1.producto_key = q2.producto_key
WHERE q2.posicion <= 5
ORDER BY q2.region, q2.posicion;
