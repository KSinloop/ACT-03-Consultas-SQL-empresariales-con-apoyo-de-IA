# Registro de decisiones sobre la respuesta de la IA

Se conserva la primera respuesta de la IA (`consulta_v1_ia.sql`) y se documenta cada cambio importante: qué propuso la IA, qué decidió el equipo y con qué evidencia.

| # | Propuesta de la IA | Decisión del equipo | Evidencia |
|---|---|---|---|
| 1 | Agregar el margen por región, producto y trimestre en una CTE y unir Q1 con `LEFT JOIN` | Aceptada | La consulta corre y devuelve 20 filas; el `LEFT JOIN` conserva productos sin Q1 |
| 2 | `ROW_NUMBER()` con `PARTITION BY region` y desempate por `producto_key` | Aceptada | Máximo 5 filas por región y resultado determinista |
| 3 | No restar el descuento otra vez (ya está en `margen`) | Aceptada | DDL: `margen` es columna generada que ya incluye el descuento |
| 4 | Usar solo tablas y columnas del esquema | Verificada | Revisión contra el DDL; la consulta se ejecuta sin errores |
| 5 | `sin_datos_q1` como booleano | Aceptada con nota | En MySQL se muestra como 1/0 |
| 6 | (Observación del equipo) El plan de la v1 genera 122 filas de agregado, recorre 20 veces el agregado de Q1 y hace 2,048 búsquedas en `dim_producto` | **Cambio del equipo:** calcular Q1 y Q2 en una sola agregación con `SUM(CASE WHEN ...)` y unir el producto al final | `EXPLAIN ANALYZE` antes y después; `EXCEPT ALL` entre v1 y final: 0 diferencias |
| 7 | El prompt 01 indicó PostgreSQL; el docente pidió MySQL 8 | **Cambio del equipo:** migrar todo a MySQL 8 (prompt 02); la v1 corre sin cambios y la final se reescribe porque MySQL no tiene `FILTER` | Mismos resultados: 2,048 filas, 20 filas y 8 totales de control |
