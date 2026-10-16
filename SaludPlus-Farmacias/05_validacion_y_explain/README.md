# Validación, depuración y EXPLAIN ANALYZE (MySQL 8)

## Validación
- `consulta_control.sql`: recalcula la rentabilidad desde `cantidad`, `precio_unitario`, `descuento` y `costo_unitario` y la compara con los totales de la consulta. Los ocho totales por región y trimestre coinciden (diferencia 0.00). También verifica que no haya duplicados del grano venta + producto + lote.
- `equivalencia_v1_vs_final.sql`: comprueba con `EXCEPT ALL` que `consulta_final.sql` devuelve lo mismo que la v1 (20 filas, 0 diferencias).

| Región | Trimestre | Total de control | Total de consulta | Diferencia |
|---|---|---:|---:|---:|
| Centro | Q1 2026 | 41,270.28 | 41,270.28 | 0.00 |
| Centro | Q2 2026 | 38,451.40 | 38,451.40 | 0.00 |
| Norte | Q1 2026 | 30,116.02 | 30,116.02 | 0.00 |
| Norte | Q2 2026 | 41,438.57 | 41,438.57 | 0.00 |
| Occidente | Q1 2026 | 30,321.69 | 30,321.69 | 0.00 |
| Occidente | Q2 2026 | 40,393.27 | 40,393.27 | 0.00 |
| Sur | Q1 2026 | 33,204.92 | 33,204.92 | 0.00 |
| Sur | Q2 2026 | 37,094.21 | 37,094.21 | 0.00 |

## Depuración del error 1055
- `error_1055_provocado.sql` provoca el error con el modo `ONLY_FULL_GROUP_BY`, activo por defecto en MySQL 8. MySQL responde:

```text
ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains
nonaggregated column 'saludplus_dm.p.producto_id_origen' which is not functionally
dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```
- **Diagnóstico:** "Expression #2" es la segunda columna del `SELECT` (`producto_id_origen`). Una región tiene varios productos; al agrupar solo por región no existe un único id ni nombre de producto por grupo, y esa columna no depende funcionalmente de `s.region`.
- `error_1055_corregido.sql` incluye `producto_key`, `producto_id_origen` y `nombre` en el `GROUP BY` y devuelve 62 filas (una por región y producto con ventas en Q2).
- No se desactivó `ONLY_FULL_GROUP_BY`: es preferible corregir la consulta que ocultar el error.

## EXPLAIN ANALYZE
Planes en `explain_antes.txt` (consulta v1) y `explain_despues.txt` (consulta final), obtenidos con `EXPLAIN ANALYZE` después de `ANALYZE TABLE`.

| Medida observada | Consulta original | Consulta optimizada |
|---|---:|---:|
| Filas del resultado | 20 | 20 |
| Filas del agregado (tabla temporal) | 122 | 62 |
| Búsquedas en `dim_producto` durante la agregación | 2,048 | 20 (se une al final) |
| Recorridos del agregado de Q1 (`Nested loop left join`) | 20 | Eliminados |
| Tiempo de ejecución (mediana de 8 corridas) | 11.65 ms | 8.75 ms |

La reescritura eliminó el `Nested loop left join` que buscaba 20 veces en el agregado de Q1 y evitó 2,048 búsquedas en `dim_producto`, porque el nombre del producto se une solo para los 20 productos del resultado. Ambos planes entran a `fact_venta` por el índice `idx_fact_venta_fecha`. Los tiempos se midieron en una sola máquina con 2,048 filas: la diferencia es pequeña en valores absolutos, así que la conclusión principal es estructural (menos trabajo en el plan) y no una afirmación de velocidad general.
