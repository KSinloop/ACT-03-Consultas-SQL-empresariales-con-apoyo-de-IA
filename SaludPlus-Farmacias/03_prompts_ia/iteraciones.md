# Iteraciones

1. **Prompt 01** → consulta v1 (`04_consultas_sql/consulta_v1_ia.sql`). Se conservó sin modificaciones como versión inicial.
2. **Revisión:** la v1 se ejecutó y cumplió la lista de verificación (tablas y columnas reales, JOINs por llaves del modelo, sin duplicados, rangos de fechas, descuento no restado dos veces, ventana por región, caso sin Q1).
3. **Optimización:** a partir del análisis con EXPLAIN ANALYZE se reescribió con agregación condicional, obteniendo `consulta_final.sql` (ver `05_validacion_y_explain`).
4. **Prompt 02:** el docente confirmó que el trabajo debía ser en MySQL 8; se migró todo y se verificó que los resultados son idénticos a los de PostgreSQL.
