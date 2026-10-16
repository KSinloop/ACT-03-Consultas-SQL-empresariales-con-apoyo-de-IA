/*
  SaludPlus Farmacias - Stored procedure: Top 5 de productos más rentables por región
  Motor: PostgreSQL 15 o superior. Esquema: saludplus_dm.

  Reutiliza la lógica de consulta_final.sql (versión final validada) y la
  parametriza por periodo. Compara el trimestre indicado contra el trimestre
  inmediato anterior (si p_trimestre = 1, contra el trimestre 4 del año previo).

  Nota de PostgreSQL: un PROCEDURE ejecutado con CALL no devuelve filas por sí
  mismo, por eso entrega el resultado mediante un cursor de salida (INOUT).
  El cursor solo existe dentro de una transacción, así que se llama entre
  BEGIN y COMMIT y se leen las filas con FETCH.

  Columnas de salida (equivalen a las de consulta_final.sql con p_anio=2026,
  p_trimestre=2): rentabilidad_actual = Q2, rentabilidad_anterior = Q1,
  sin_datos_anterior = sin_datos_q1.
*/

CREATE OR REPLACE PROCEDURE saludplus_dm.sp_top5_rentables_region(
    IN    p_anio      INTEGER,
    IN    p_trimestre INTEGER,
    INOUT p_cursor    REFCURSOR DEFAULT 'cur_top5_rentables'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anio_ant INTEGER;
    v_trim_ant INTEGER;
BEGIN
    IF p_anio IS NULL OR p_trimestre IS NULL OR p_trimestre NOT BETWEEN 1 AND 4 THEN
        RAISE EXCEPTION 'Parámetros inválidos: año % y trimestre % (el trimestre debe estar entre 1 y 4)',
            p_anio, p_trimestre
            USING ERRCODE = '22023';
    END IF;

    IF p_trimestre = 1 THEN
        v_anio_ant := p_anio - 1;
        v_trim_ant := 4;
    ELSE
        v_anio_ant := p_anio;
        v_trim_ant := p_trimestre - 1;
    END IF;

    OPEN p_cursor FOR
    WITH agregado AS (
        SELECT
            s.region,
            f.producto_key,
            SUM(f.margen) FILTER (WHERE d.anio = p_anio
                                    AND d.trimestre = p_trimestre) AS rentabilidad_actual,
            SUM(f.margen) FILTER (WHERE d.anio = v_anio_ant
                                    AND d.trimestre = v_trim_ant)  AS rentabilidad_anterior
        FROM saludplus_dm.fact_venta   f
        JOIN saludplus_dm.dim_sucursal s USING (sucursal_key)
        JOIN saludplus_dm.dim_fecha    d USING (fecha_hora_key)
        WHERE (d.anio, d.trimestre) IN ((p_anio, p_trimestre),
                                        (v_anio_ant, v_trim_ant))
        GROUP BY s.region, f.producto_key
        HAVING COUNT(*) FILTER (WHERE d.anio = p_anio
                                  AND d.trimestre = p_trimestre) > 0
    ),
    ranking AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY region
                                  ORDER BY rentabilidad_actual DESC, producto_key) AS posicion
        FROM agregado
    )
    SELECT
        r.region,
        r.posicion,
        p.producto_id_origen,
        p.nombre,
        ROUND(r.rentabilidad_actual, 2)                       AS rentabilidad_actual,
        ROUND(r.rentabilidad_anterior, 2)                     AS rentabilidad_anterior,
        ROUND(r.rentabilidad_actual - r.rentabilidad_anterior, 2) AS variacion_absoluta,
        ROUND(100 * (r.rentabilidad_actual - r.rentabilidad_anterior)
              / NULLIF(r.rentabilidad_anterior, 0), 2)        AS variacion_porcentual,
        (r.rentabilidad_anterior IS NULL)                     AS sin_datos_anterior
    FROM ranking r
    JOIN saludplus_dm.dim_producto p USING (producto_key)
    WHERE r.posicion <= 5
    ORDER BY r.region, r.posicion;
END;
$$;

COMMENT ON PROCEDURE saludplus_dm.sp_top5_rentables_region(INTEGER, INTEGER, REFCURSOR) IS
'Top 5 de productos más rentables por región en (año, trimestre) comparado con el trimestre anterior. Devuelve un cursor.';

/* ---------------- PRUEBAS ----------------
   Cada prueba se ejecuta completa (BEGIN ... COMMIT).

   -- Prueba principal: Q2 2026 contra Q1 2026 (debe dar 20 filas)
   BEGIN;
   CALL saludplus_dm.sp_top5_rentables_region(2026, 2, 'cur');
   FETCH ALL FROM cur;
   COMMIT;

   -- Caso límite: Q1 2026 (el trimestre anterior, Q4 2025, no tiene datos;
   -- todas las filas salen con sin_datos_anterior = true)
   BEGIN;
   CALL saludplus_dm.sp_top5_rentables_region(2026, 1, 'cur');
   FETCH ALL FROM cur;
   COMMIT;

   -- Caso de error: trimestre inválido (debe lanzar la excepción 22023)
   CALL saludplus_dm.sp_top5_rentables_region(2026, 5, 'cur');
*/
