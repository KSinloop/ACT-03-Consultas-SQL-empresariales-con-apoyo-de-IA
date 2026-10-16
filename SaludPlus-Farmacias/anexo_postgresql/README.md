# Anexo: versión original en PostgreSQL y diferencias de sintaxis

El trabajo se desarrolló inicialmente en PostgreSQL 15 y se migró a MySQL 8 por indicación del docente. Este anexo conserva los scripts originales como referencia.

| Archivo | Descripción |
|---|---|
| `DDL_PostgreSQL.sql` | DDL original del Data Mart |
| `Datos_simulados_PostgreSQL.sql` | Datos simulados (mismos datos que la versión MySQL) |
| `consulta_PostgreSQL_referencia.sql` | Consulta de referencia con `FILTER` (la versión final entregada es la de `04_consultas_sql`) |
| `sp_top5_rentables_region_PostgreSQL.sql` | Procedimiento con cursor `REFCURSOR` |

La tabla de diferencias de sintaxis está en `03_prompts_ia/respuesta_ia_02_migracion_a_mysql.md`. Los resultados son idénticos en ambos motores: 2,048 filas, 20 filas en el reporte y los mismos 8 totales de control.
