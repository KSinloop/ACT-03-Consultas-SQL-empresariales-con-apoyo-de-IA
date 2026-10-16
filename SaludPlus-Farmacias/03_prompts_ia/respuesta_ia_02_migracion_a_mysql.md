# Respuesta de la IA – Prompt 02 (resumen)

**IA:** Claude (Anthropic) · Los scripts se ejecutaron en MySQL 8.0.46 y los resultados se compararon contra los obtenidos en PostgreSQL.

## Resultado de la migración
- Se cargan **los mismos datos**: 32 sucursales, 16 productos, 96 empleados, 2,167 fechas y **2,048 filas** en `fact_venta`.
- `consulta_v1_ia.sql` corre **sin cambios**; devuelve las mismas 20 filas.
- `consulta_final.sql` necesitó un cambio: MySQL no tiene `FILTER`, así que se usa `SUM(CASE WHEN ... THEN ... END)` y `COUNT(CASE WHEN ... THEN 1 END) > 0`.
- La v1 y la final son equivalentes (`EXCEPT ALL` en ambas direcciones: 0 diferencias).
- Los 8 totales de control coinciden con los de PostgreSQL.

## Cambios necesarios
| Tema | PostgreSQL | MySQL 8 |
|---|---|---|
| Llaves automáticas | `GENERATED ALWAYS AS IDENTITY` | `AUTO_INCREMENT` |
| Esquema | `CREATE SCHEMA` y `SET search_path` | `CREATE DATABASE` y `USE` |
| Conversión de tipo | `fecha_hora::DATE` | `DATE(fecha_hora)` |
| Fecha y hora | `TIMESTAMP` | `DATETIME` |
| Agregación condicional | `SUM(x) FILTER (WHERE ...)` | `SUM(CASE WHEN ... THEN x END)` |
| Generar secuencias | `generate_series` | CTE recursiva (`WITH RECURSIVE`) |
| Asignar fila de una dimensión | `OFFSET n LIMIT 1` en subconsulta `LATERAL` | `ROW_NUMBER() OVER (ORDER BY ...)` y unión por número |
| Insertar sin duplicar | `ON CONFLICT DO NOTHING` | `INSERT IGNORE` |
| División entera | `gs / 15` | `gs DIV 15` |
| Comentarios | `COMMENT ON ...` | `COMMENT` dentro del `CREATE TABLE` |
| Índice parcial (`WHERE cliente_key IS NOT NULL`) | Admitido | No existe; índice normal |
| Booleano | `true` / `false` | `1` / `0` |
| Error de agrupación | 42803 | 1055 (`ONLY_FULL_GROUP_BY`) |
| Procedimiento | `CREATE PROCEDURE` con cursor `REFCURSOR`; `CALL` + `FETCH` | `CREATE PROCEDURE` con `DELIMITER`; el `SELECT` devuelve las filas directo |
| Validación en el procedimiento | `RAISE EXCEPTION` | `SIGNAL SQLSTATE '45000'` |
| Plan de ejecución | `EXPLAIN (ANALYZE, BUFFERS)` | `EXPLAIN ANALYZE` (8.0.18 o superior), formato de árbol |
