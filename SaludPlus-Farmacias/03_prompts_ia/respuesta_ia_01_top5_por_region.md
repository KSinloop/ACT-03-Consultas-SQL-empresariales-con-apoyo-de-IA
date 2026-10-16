# Respuesta de la IA – Prompt 01

**IA:** Claude (Anthropic) · **Fecha:** octubre de 2026 · Respuesta guardada sin editar.

## Supuestos

1. Rentabilidad = `SUM(margen)`; el descuento ya está dentro de `margen`, así que no se resta otra vez.
2. La región se toma de `dim_sucursal.region` mediante `fact_venta.sucursal_key`.
3. Q1 y Q2 se filtran con `dim_fecha.anio = 2026` y `trimestre` en 1 o 2.
4. No se consideran devoluciones ni cancelaciones, porque el modelo no las tiene.
5. El ranking es solo sobre Q2, y el desempate es por `producto_key`.
6. `sin_datos_q1` es TRUE cuando el producto no tiene ninguna fila de ventas en Q1 en esa región.
7. La variación porcentual usa Q1 como base. Si la base es nula o cero, queda en `NULL`.
8. Se agrupa por `producto_key` (la llave del modelo), y se muestra `producto_id_origen` en la salida.

## SQL

```sql
WITH agregado AS (
    SELECT
        s.region,
        p.producto_key,
        p.producto_id_origen,
        p.nombre,
        d.trimestre,
        SUM(f.margen) AS rentabilidad
    FROM saludplus_dm.fact_venta   AS f
    JOIN saludplus_dm.dim_sucursal AS s ON s.sucursal_key   = f.sucursal_key
    JOIN saludplus_dm.dim_producto AS p ON p.producto_key   = f.producto_key
    JOIN saludplus_dm.dim_fecha    AS d ON d.fecha_hora_key = f.fecha_hora_key
    WHERE d.anio = 2026
      AND d.trimestre IN (1, 2)
    GROUP BY s.region, p.producto_key, p.producto_id_origen,
             p.nombre, d.trimestre
),
q2 AS (
    SELECT
        region, producto_key, producto_id_origen, nombre, rentabilidad,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY rentabilidad DESC, producto_key
        ) AS posicion
    FROM agregado
    WHERE trimestre = 2
),
q1 AS (
    SELECT region, producto_key, rentabilidad
    FROM agregado
    WHERE trimestre = 1
)
SELECT
    q2.region,
    q2.posicion,
    q2.producto_id_origen,
    q2.nombre,
    ROUND(q2.rentabilidad, 2)                    AS rentabilidad_q2,
    ROUND(q1.rentabilidad, 2)                    AS rentabilidad_q1,
    ROUND(q2.rentabilidad - q1.rentabilidad, 2)  AS variacion_absoluta,
    ROUND(100 * (q2.rentabilidad - q1.rentabilidad)
          / NULLIF(q1.rentabilidad, 0), 2)       AS variacion_porcentual,
    (q1.rentabilidad IS NULL)                    AS sin_datos_q1
FROM q2
LEFT JOIN q1
       ON q1.region       = q2.region
      AND q1.producto_key = q2.producto_key
WHERE q2.posicion <= 5
ORDER BY q2.region, q2.posicion;
```

## Explicación

**CTE `agregado`:** une la fact con sucursal, producto y fecha, y suma el margen por región, producto y trimestre. Hace toda la agregación en un solo paso, antes de cualquier otra unión.

**CTE `q2`:** toma solo las filas de Q2 y aplica `ROW_NUMBER()` con `PARTITION BY region`, por lo que el ranking se reinicia en cada región. Ordena por rentabilidad descendente y desempata por `producto_key`.

**CTE `q1`:** solo separa las filas de Q1 ya agregadas.

**JOINs:**
- Los tres `JOIN` dentro de `agregado` son inner joins por llave sustituta (cada venta tiene una sucursal, un producto y una fecha).
- El `LEFT JOIN` final une `q2` con `q1` por región y producto. Es `LEFT` para que un producto del top 5 sin ventas en Q1 siga apareciendo.

**Función de ventana:** `ROW_NUMBER()` da una posición única por región. Se filtra `<= 5` en el `SELECT` final, porque no se puede filtrar una ventana dentro del mismo `WHERE` donde se calcula.

**Duplicados:** como cada trimestre ya viene agregado a una fila por región y producto, el `LEFT JOIN` es uno a uno y no multiplica importes. Las dimensiones se unen por su llave primaria.

**División entre cero:** `NULLIF(q1.rentabilidad, 0)` convierte un Q1 de cero en `NULL`, así que la división no truena. Si no hay Q1, `rentabilidad_q1`, las variaciones y `NULL` salen vacíos y `sin_datos_q1` queda en `TRUE`.

## Resultado en la base de prueba

Se corrió sobre el DDL del equipo con el script de datos corregido. Devuelve 20 filas (4 regiones por 5), sin errores. En Norte y Occidente el Glucómetro Digital (216) sale en posición 1 con `sin_datos_q1 = TRUE` y variaciones vacías.
