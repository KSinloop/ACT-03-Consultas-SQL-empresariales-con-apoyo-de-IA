# Prompt 02 – Migración a MySQL 8 (resumen de la solicitud)

**IA utilizada:** Claude (Anthropic) · **Fecha:** 12 de octubre de 2026

```text
El docente confirmó que el trabajo debe estar hecho únicamente en MySQL 8. Hasta ahora
trabajamos en PostgreSQL 15 (DDL, datos simulados, consulta de la IA, consulta final con
FILTER, error de GROUP BY, EXPLAIN y stored procedure).

Necesitamos migrar todo a MySQL 8 y probarlo en un servidor MySQL real:
1. DDL del Data Mart (mismas tablas, llaves, restricciones y columnas generadas).
2. Script de datos simulados que cargue exactamente los mismos datos.
3. Confirmar si consulta_v1_ia.sql corre sin cambios.
4. Reescribir consulta_final.sql sin la cláusula FILTER.
5. Consulta de control, error 1055 provocado y corregido, y EXPLAIN ANALYZE antes y después.
6. Stored procedure con parámetros de año y trimestre.
7. Indicar las diferencias de sintaxis entre PostgreSQL y MySQL, como pide la actividad.
No inventes resultados: todo debe salir de ejecutar los scripts.
```
