# Stored procedure `sp_top5_rentables_region` (MySQL 8)

Recibe **año** y **trimestre** y compara contra el trimestre inmediato anterior (si el trimestre es 1, contra el trimestre 4 del año previo). Reutiliza la lógica de `consulta_final.sql` sin copiarla fuera del procedimiento y valida que el trimestre esté entre 1 y 4 (si no, lanza `SIGNAL SQLSTATE '45000'`).

En MySQL, un `SELECT` dentro del procedimiento devuelve sus filas directamente al ejecutar `CALL`:

```sql
CALL saludplus_dm.sp_top5_rentables_region(2026, 2);
```

| Archivo | Contenido |
|---|---|
| `sp_top5_rentables_region.sql` | Script de creación (usa `DELIMITER`) |
| `prueba_call.sql` | Llamadas de prueba: caso principal (2026, 2), Q1 sin trimestre anterior, periodo sin ventas y parámetro inválido |
| `salida_prueba.txt` | Salida obtenida al ejecutar las pruebas |

Con `(2026, 2)` devuelve las mismas 20 filas que `consulta_final.sql`; las columnas se llaman `rentabilidad_actual`, `rentabilidad_anterior` y `sin_datos_anterior` (equivalen a Q2, Q1 y `sin_datos_q1`). El último `CALL` de la prueba termina en el error 1644 (SQLSTATE 45000), que es el comportamiento esperado.
