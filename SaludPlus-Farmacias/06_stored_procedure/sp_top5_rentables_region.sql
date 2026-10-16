/*
  SaludPlus Farmacias - Stored procedure: Top 5 de productos más rentables por región
  Motor: MySQL 8.0 o superior. Base de datos: saludplus_dm.

  Reutiliza la lógica de consulta_final.sql (versión final validada) y la
  parametriza por periodo. Compara el trimestre indicado contra el trimestre
  inmediato anterior (si p_trimestre = 1, contra el trimestre 4 del año previo).

  En MySQL, un SELECT dentro del procedimiento devuelve su resultado
  directamente al ejecutar CALL.

  Columnas de salida (equivalen a las de consulta_final.sql con p_anio = 2026
  y p_trimestre = 2): rentabilidad_actual = Q2, rentabilidad_anterior = Q1,
  sin_datos_anterior = sin_datos_q1.
*/

USE saludplus_dm;

DROP PROCEDURE IF EXISTS sp_top5_rentables_region;

DELIMITER $$

CREATE PROCEDURE sp_top5_rentables_region(
    IN p_anio      INT,
    IN p_trimestre INT
)
COMMENT 'Top 5 de productos más rentables por región en (año, trimestre) comparado con el trimestre anterior.'
BEGIN
    DECLARE v_anio_ant INT;
    DECLARE v_trim_ant INT;

    IF p_anio IS NULL OR p_trimestre IS NULL OR p_trimestre NOT BETWEEN 1 AND 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parámetros inválidos: el trimestre debe estar entre 1 y 4';
    END IF;

    IF p_trimestre = 1 THEN
        SET v_anio_ant = p_anio - 1;
        SET v_trim_ant = 4;
    ELSE
        SET v_anio_ant = p_anio;
        SET v_trim_ant = p_trimestre - 1;
    END IF;

    WITH agregado AS (
        SELECT
            s.region,
            f.producto_key,
            SUM(CASE WHEN d.anio = p_anio AND d.trimestre = p_trimestre
                     THEN f.margen END)                          AS rentabilidad_actual,
            SUM(CASE WHEN d.anio = v_anio_ant AND d.trimestre = v_trim_ant
                     THEN f.margen END)                          AS rentabilidad_anterior
        FROM saludplus_dm.fact_venta   f
        JOIN saludplus_dm.dim_sucursal s USING (sucursal_key)
        JOIN saludplus_dm.dim_fecha    d USING (fecha_hora_key)
        WHERE (d.anio = p_anio AND d.trimestre = p_trimestre)
           OR (d.anio = v_anio_ant AND d.trimestre = v_trim_ant)
        GROUP BY s.region, f.producto_key
        HAVING COUNT(CASE WHEN d.anio = p_anio AND d.trimestre = p_trimestre
                          THEN 1 END) > 0
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
        ROUND(r.rentabilidad_actual, 2)                           AS rentabilidad_actual,
        ROUND(r.rentabilidad_anterior, 2)                         AS rentabilidad_anterior,
        ROUND(r.rentabilidad_actual - r.rentabilidad_anterior, 2) AS variacion_absoluta,
        ROUND(100 * (r.rentabilidad_actual - r.rentabilidad_anterior)
              / NULLIF(r.rentabilidad_anterior, 0), 2)            AS variacion_porcentual,
        r.rentabilidad_anterior IS NULL                           AS sin_datos_anterior
    FROM ranking r
    JOIN saludplus_dm.dim_producto p USING (producto_key)
    WHERE r.posicion <= 5
    ORDER BY r.region, r.posicion;
END$$

DELIMITER ;
