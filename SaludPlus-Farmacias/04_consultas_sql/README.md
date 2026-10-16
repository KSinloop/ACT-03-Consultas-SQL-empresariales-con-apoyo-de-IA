# Consultas SQL (MySQL 8)

| Archivo | Descripción |
|---|---|
| `consulta_v1_ia.sql` | **Versión inicial** generada por la IA, sin modificaciones. Corre sin cambios en MySQL 8. |
| `consulta_final.sql` | **Versión final validada.** Calcula Q1 y Q2 en una sola agregación con `SUM(CASE WHEN ...)`, elimina el `LEFT JOIN` entre trimestres y une `dim_producto` después del ranking. |

Ambas devuelven las mismas 20 filas; la equivalencia se comprobó con `EXCEPT ALL` en ambas direcciones (0 diferencias). Ver `05_validacion_y_explain`. En MySQL el indicador `sin_datos_q1` se muestra como `1` o `0`.
