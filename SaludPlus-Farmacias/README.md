# SaludPlus Farmacias – Consultas SQL empresariales con apoyo de IA (Unidad 3)

**Curso:** Business Intelligence · **Profesor:** Ing. Miguel Ángel Gómez Marroquín · **Fecha:** 12/10/2026
**Equipo 5:** Mariana Flores Rosales (2143017), Luis Ricardo Salinas De la Peña (2142924), Kenner Shahid López Ramírez (2142291)

## Objetivo
Obtener los **5 productos más rentables por región en el segundo trimestre de 2026**, comparados contra el primer trimestre, sobre el Data Mart de ventas de SaludPlus Farmacias (Unidad 2). La consulta se generó con apoyo de IA (Claude, Anthropic), se validó, se depuró (error 1055), se optimizó con EXPLAIN ANALYZE y se integró en un stored procedure.

**Motor:** MySQL 8.0 o superior · **Base de datos:** `saludplus_dm`
(El trabajo se desarrolló inicialmente en PostgreSQL y se migró a MySQL 8; las versiones originales y las diferencias de sintaxis están en `anexo_postgresql`.)

## Estructura del repositorio
| Carpeta | Contenido |
|---|---|
| `01_modelo_unidad_2` | Diagrama estrella, descripción del grano y definiciones de negocio |
| `02_ddl_y_datos` | DDL del Data Mart y script de datos simulados (MySQL) |
| `03_prompts_ia` | Prompts enviados a la IA, sus respuestas completas, iteraciones y registro de decisiones |
| `04_consultas_sql` | Consulta inicial de la IA (`consulta_v1_ia.sql`) y consulta final validada (`consulta_final.sql`) |
| `05_validacion_y_explain` | Consulta de control, error 1055, planes EXPLAIN ANALYZE antes y después |
| `06_stored_procedure` | Procedimiento almacenado, llamadas de prueba y salida obtenida |
| `07_conclusion` | Conclusión de una página |
| `anexo_postgresql` | Versiones originales en PostgreSQL y tabla de diferencias de sintaxis |
| `Reporte_SaludPlus_SQL.docx` | Reporte completo de la actividad |

## Cómo reproducir (en MySQL 8.0.31 o superior)
1. Ejecutar `02_ddl_y_datos/Equipo5_SaludPlus_DDL_MySQL.sql`.
2. Ejecutar `02_ddl_y_datos/Datos_simulados_MySQL.sql`. Resultado esperado: **2,048 filas** en `fact_venta`.
3. Ejecutar `04_consultas_sql/consulta_final.sql`. Resultado esperado: **20 filas** (4 regiones × 5 productos).
4. Ejecutar `05_validacion_y_explain/consulta_control.sql`: los ocho totales deben coincidir (diferencia 0.00).
5. Ejecutar `06_stored_procedure/sp_top5_rentables_region.sql` y luego las llamadas de `06_stored_procedure/prueba_call.sql`.

Nota: en el cliente `mysql` hay que conectarse con `--default-character-set=utf8mb4` para ver bien los acentos.
