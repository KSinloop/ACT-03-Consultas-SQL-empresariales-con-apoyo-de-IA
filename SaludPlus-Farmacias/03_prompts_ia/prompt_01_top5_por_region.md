# Prompt 01 – Top 5 de productos más rentables por región

**IA utilizada:** Claude (Anthropic) · **Fecha:** octubre de 2026
**Nota:** este prompt se redactó cuando el equipo trabajaba en PostgreSQL. La consulta obtenida usa SQL estándar y se ejecuta sin cambios en MySQL 8 (ver prompt 02).

```text
Actúa como analista SQL senior especializado en PostgreSQL 15.

CONTEXTO
Trabajamos con el Data Mart de ventas de SaludPlus Farmacias, en el esquema
saludplus_dm. Necesitamos un reporte con los 5 productos más rentables por
región en el segundo trimestre de 2026, comparado con el primer trimestre
de 2026.

GRANO
fact_venta tiene una fila por combinación de venta, producto y lote
(UNIQUE venta_id_origen, producto_key, lote_key).

ESQUEMA (usa SOLO estas tablas y columnas; no inventes ninguna):

fact_venta(fact_venta_key PK, venta_id_origen, producto_key FK, lote_key FK,
  cliente_key FK nulo, empleado_key FK, sucursal_key FK, canal_key FK,
  fecha_hora_key FK, cantidad, precio_unitario, descuento, costo_unitario,
  monto_total = cantidad*precio_unitario - descuento (columna generada),
  costo_total = cantidad*costo_unitario (columna generada),
  margen = monto_total - costo_total (columna generada))
dim_producto(producto_key PK, producto_id_origen, nombre, marca, categoria,
  subcategoria, unidad)
dim_sucursal(sucursal_key PK, sucursal_id_origen, nombre, ciudad, region)
dim_fecha(fecha_hora_key PK, fecha_hora, fecha, hora, rango_horario,
  dia_semana, mes SMALLINT, trimestre SMALLINT, anio SMALLINT)

REGLAS DE NEGOCIO
- Rentabilidad = SUM(margen) por producto y región.
- La región viene de dim_sucursal.region (unida por sucursal_key).
- Q2 2026 = dim_fecha.anio = 2026 y trimestre = 2.
  Q1 2026 = dim_fecha.anio = 2026 y trimestre = 1.
- El descuento ya está restado dentro de monto_total y margen; no lo restes
  otra vez.
- El Data Mart no tiene tabla de devoluciones ni estado de cancelación; no los
  consideres ni inventes columnas para ellos.
- Hay productos que se vendieron en Q2 pero no tienen ventas en Q1.

SALIDA REQUERIDA (ordenada por región y posición)
region, posicion (ranking del producto dentro de su región en Q2),
producto_id_origen, nombre, rentabilidad_q2, rentabilidad_q1,
variacion_absoluta, variacion_porcentual, sin_datos_q1 (booleano).
Máximo 5 productos por región.

REQUISITOS TÉCNICOS
- Usa JOINs, al menos una CTE y ROW_NUMBER() con PARTITION BY región.
  Desempata por producto_key para que el resultado sea determinista.
- Agrega primero por región y producto en cada trimestre (CTE), y hasta
  después une las dos agregaciones, para no duplicar importes por los JOINs.
- El top 5 se calcula sobre Q2. A esos productos se les busca su Q1 con LEFT
  JOIN; si no tienen Q1, rentabilidad_q1 queda en NULL, las variaciones en NULL
  y sin_datos_q1 en TRUE.
- Evita la división entre cero con NULLIF.
- Redondea a 2 decimales y usa nombres de columnas en minúsculas con guion bajo.

ANTES DE ESCRIBIR EL SQL, enumera tus supuestos. DESPUÉS del SQL, explica cada
CTE, cada JOIN y la función de ventana, y cómo evitas duplicados y división
entre cero.

```
