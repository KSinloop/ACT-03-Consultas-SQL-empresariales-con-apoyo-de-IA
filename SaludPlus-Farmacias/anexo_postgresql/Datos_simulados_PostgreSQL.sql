/*
  SaludPlus Farmacias - Datos simulados (versión corregida)
  Motor: PostgreSQL 15 o superior
  Ejecutar DESPUÉS del DDL (Equipo5_SaludPlus_DDL_PostgreSQL.sql).

  Cambios respecto a la versión anterior:
  - Todas las subconsultas con OFFSET llevan ORDER BY (resultado reproducible).
  - Correcciones de captura: Torreón, "Jarabe Tos", categoría "Vitaminas".
  - dia_semana en español sin depender del idioma del servidor.
  - 3 empleados por sucursal y cada venta la atiende un empleado de SU sucursal.
  - Precios con margen distinto por producto y por región (las sucursales
    manejan precios distintos), y demanda regional/estacional por producto.
  - Clientes anónimos (~20 %) repartidos sin patrón por producto.
  - Producto nuevo (216) con ventas SOLO en Q2, para probar "sin datos en Q1".
*/

SET search_path TO saludplus_dm;

/* dim_sucursal */
INSERT INTO dim_sucursal (sucursal_id_origen, nombre, ciudad, region) VALUES
(101, 'Sucursal Cumbres', 'Monterrey', 'Norte'),
(102, 'Sucursal Contry', 'Monterrey', 'Norte'),
(103, 'Sucursal San Pedro', 'San Pedro Garza García', 'Norte'),
(104, 'Sucursal Anáhuac', 'San Nicolás', 'Norte'),
(105, 'Sucursal Saltillo Centro', 'Saltillo', 'Norte'),
(106, 'Sucursal Torreón Oriente', 'Torreón', 'Norte'),
(107, 'Sucursal Chihuahua Centro', 'Chihuahua', 'Norte'),
(108, 'Sucursal Hermosillo Norte', 'Hermosillo', 'Norte'),
(109, 'Sucursal Polanco', 'Ciudad de México', 'Centro'),
(110, 'Sucursal Del Valle', 'Ciudad de México', 'Centro'),
(111, 'Sucursal Roma', 'Ciudad de México', 'Centro'),
(112, 'Sucursal Santa Fe', 'Ciudad de México', 'Centro'),
(113, 'Sucursal Coyoacán', 'Ciudad de México', 'Centro'),
(114, 'Sucursal Puebla Angelópolis', 'Puebla', 'Centro'),
(115, 'Sucursal Toluca Centro', 'Toluca', 'Centro'),
(116, 'Sucursal Juriquilla', 'Querétaro', 'Centro'),
(117, 'Sucursal Minerva', 'Guadalajara', 'Occidente'),
(118, 'Sucursal Zapopan Centro', 'Zapopan', 'Occidente'),
(119, 'Sucursal Providencia', 'Guadalajara', 'Occidente'),
(120, 'Sucursal Tlaquepaque', 'Tlaquepaque', 'Occidente'),
(121, 'Sucursal León Campestre', 'León', 'Occidente'),
(122, 'Sucursal Morelia Centro', 'Morelia', 'Occidente'),
(123, 'Sucursal Aguascalientes Norte', 'Aguascalientes', 'Occidente'),
(124, 'Sucursal Colima Centro', 'Colima', 'Occidente'),
(125, 'Sucursal Mérida Montejo', 'Mérida', 'Sur'),
(126, 'Sucursal Cancún Zona Hotelera', 'Cancún', 'Sur'),
(127, 'Sucursal Tuxtla Centro', 'Tuxtla Gutiérrez', 'Sur'),
(128, 'Sucursal Villahermosa Tabasco', 'Villahermosa', 'Sur'),
(129, 'Sucursal Veracruz Puerto', 'Veracruz', 'Sur'),
(130, 'Sucursal Oaxaca Centro', 'Oaxaca', 'Sur'),
(131, 'Sucursal Campeche Centro', 'Campeche', 'Sur'),
(132, 'Sucursal Chetumal Centro', 'Chetumal', 'Sur')
ON CONFLICT (sucursal_id_origen) DO NOTHING;

/* dim_producto (los 15 productos del catálogo base) */
INSERT INTO dim_producto (producto_id_origen, nombre, marca, categoria, subcategoria, unidad) VALUES
(201, 'Paracetamol 500mg 20 Tab', 'Genfar', 'Medicamentos', 'Analgésicos', 'Caja'),
(202, 'Ibuprofeno 400mg 10 Tab', 'Advill', 'Medicamentos', 'Analgésicos', 'Caja'),
(203, 'Amoxicilina 500mg 12 Cap', 'Flexipen', 'Medicamentos', 'Antibióticos', 'Caja'),
(204, 'Omeprazol 20mg 14 Cap', 'Genoprazol', 'Medicamentos', 'Gastroenterología', 'Caja'),
(205, 'Loratadina 10mg 10 Tab', 'Clarityne', 'Medicamentos', 'Antihistamínicos', 'Caja'),
(206, 'Vitamina C 1000mg Eff', 'Redoxon', 'Vitaminas', 'Suplementos', 'Tubo'),
(207, 'Electrolit Suero 625ml', 'Electrolit', 'Cuidado Personal', 'Hidratación', 'Pieza'),
(208, 'Bloqueador Solar SPF50', 'Nivea', 'Cuidado Personal', 'Dermatología', 'Frasco'),
(209, 'Gel Antibacterial 500ml', 'Lysol', 'Higiene', 'Desinfectantes', 'Botella'),
(210, 'Toallitas Húmedas 80 pza', 'Huggies', 'Bebés', 'Higiene Infantil', 'Paquete'),
(211, 'Multivitamínico Diario', 'Centrum', 'Vitaminas', 'Suplementos', 'Frasco'),
(212, 'Jarabe Tos 120ml', 'Tukol', 'Medicamentos', 'Respiratorio', 'Frasco'),
(213, 'Termómetro Digital', 'Omron', 'Dispositivos Médicos', 'Diagnóstico', 'Pieza'),
(214, 'Baumanómetro Digital', 'Omron', 'Dispositivos Médicos', 'Diagnóstico', 'Pieza'),
(215, 'Crema Humectante 400ml', 'Cerave', 'Cuidado Personal', 'Dermatología', 'Frasco')
ON CONFLICT (producto_id_origen) DO NOTHING;

/* dim_lote */
INSERT INTO dim_lote (lote_id_origen, producto_id_origen, fecha_caducidad, costo_lote) VALUES
(301, 201, '2026-11-15', 18.50),
(302, 202, '2027-03-20', 25.00),
(303, 203, '2026-08-10', 45.00),
(304, 204, '2027-01-05', 30.00),
(305, 205, '2026-12-01', 15.00),
(306, 206, '2027-05-18', 50.00),
(307, 207, '2026-10-30', 12.00),
(308, 208, '2027-06-15', 120.00),
(309, 209, '2028-01-01', 22.00),
(310, 210, '2027-09-12', 28.00),
(311, 211, '2027-04-10', 180.00),
(312, 212, '2026-09-25', 55.00),
(313, 213, '2029-12-31', 110.00),
(314, 214, '2029-12-31', 450.00),
(315, 215, '2027-08-14', 160.00)
ON CONFLICT (lote_id_origen) DO NOTHING;

/* dim_cliente */
INSERT INTO dim_cliente (cliente_id_origen, nivel_beneficios, ciudad, fecha_alta) VALUES
(401, 'Oro', 'Monterrey', '2024-01-15'),
(402, 'Plata', 'Ciudad de México', '2024-03-22'),
(403, 'Bronce', 'Guadalajara', '2024-05-10'),
(404, 'Platino', 'Monterrey', '2023-11-01'),
(405, 'Oro', 'Puebla', '2025-02-14'),
(406, 'Plata', 'Mérida', '2024-08-19'),
(407, 'Bronce', 'Querétaro', '2025-01-05'),
(408, 'Platino', 'Ciudad de México', '2023-09-12'),
(409, 'Oro', 'Cancún', '2024-10-30'),
(410, 'Sin Programa', 'Saltillo', '2025-03-01')
ON CONFLICT (cliente_id_origen) DO NOTHING;

/* dim_empleado: 3 por sucursal (Cajero, Farmacéutico, Encargado de Tienda) */
INSERT INTO dim_empleado (empleado_id_origen, sucursal_id_origen, nombre, puesto)
SELECT
    500 + (sid - 101) * 3 + k,
    sid,
    (ARRAY['Carlos','Ana','Luis','Sofía','Jorge','Elena','Fernando','Patricia',
           'Diego','Valeria','Ricardo','Mariana'])[1 + ((sid * 3 + k) % 12)]
    || ' ' ||
    (ARRAY['Gómez','Martínez','Hernández','López','Ramírez','Torres','Castillo',
           'Morales'])[1 + ((sid + k * 3) % 8)],
    (ARRAY['Cajero','Farmacéutico','Encargado de Tienda'])[k]
FROM generate_series(101, 132) AS sid
CROSS JOIN generate_series(1, 3) AS k
ON CONFLICT (empleado_id_origen) DO NOTHING;

/* dim_fecha: una fila cada 2 horas, 1-ene-2026 a 30-jun-2026 */
INSERT INTO dim_fecha (fecha_hora, fecha, hora, rango_horario, dia_semana, mes, trimestre, anio)
SELECT
    dt,
    dt::DATE,
    EXTRACT(HOUR FROM dt)::SMALLINT,
    CASE
        WHEN EXTRACT(HOUR FROM dt) BETWEEN 7 AND 11 THEN 'Mañana'
        WHEN EXTRACT(HOUR FROM dt) BETWEEN 12 AND 17 THEN 'Tarde'
        WHEN EXTRACT(HOUR FROM dt) BETWEEN 18 AND 22 THEN 'Noche'
        ELSE 'Madrugada'
    END,
    (ARRAY['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'])
        [EXTRACT(ISODOW FROM dt)::INT],
    EXTRACT(MONTH FROM dt)::SMALLINT,
    EXTRACT(QUARTER FROM dt)::SMALLINT,
    EXTRACT(YEAR FROM dt)::SMALLINT
FROM generate_series(
    '2026-01-01 08:00:00'::TIMESTAMP,
    '2026-06-30 21:00:00'::TIMESTAMP,
    INTERVAL '2 hours'
) AS dt
ON CONFLICT (fecha_hora) DO NOTHING;

/*
  fact_venta - 2,000 filas del catálogo base.
  Parámetros de la simulación:
  - markup: margen de cada producto sobre su costo (genéricos más alto,
    dispositivos más bajo).
  - reg: factor de precio por región (las sucursales manejan precios distintos).
  - boost: demanda regional (cantidad x2 en ciertos productos por región).
  - season: demanda estacional por trimestre.
*/
INSERT INTO fact_venta (
    venta_id_origen, producto_key, lote_key, cliente_key, empleado_key,
    sucursal_key, canal_key, fecha_hora_key,
    cantidad, precio_unitario, descuento, costo_unitario
)
WITH markup (pid, m) AS (VALUES
    (201, 2.20), (202, 1.90), (203, 1.80), (204, 2.00), (205, 2.10),
    (206, 1.60), (207, 1.80), (208, 1.50), (209, 1.70), (210, 1.40),
    (211, 1.45), (212, 1.80), (213, 1.35), (214, 1.25), (215, 1.45)
),
reg (region, rf) AS (VALUES
    ('Norte', 1.00), ('Centro', 1.10), ('Occidente', 0.95), ('Sur', 1.05)
),
boost (region, pid, mult) AS (VALUES
    ('Norte', 203, 2), ('Norte', 204, 2),
    ('Sur', 207, 2), ('Sur', 208, 2), ('Sur', 209, 2),
    ('Centro', 213, 2), ('Centro', 214, 2),
    ('Occidente', 206, 2), ('Occidente', 211, 2)
),
season (trim, pid, mult) AS (VALUES
    (2, 205, 2), (2, 207, 2), (2, 208, 2),
    (1, 202, 2), (1, 212, 2)
)
SELECT
    gs,
    p.producto_key,
    l.lote_key,
    CASE WHEN (gs * 13) % 10 < 2 THEN NULL ELSE c.cliente_key END,
    e.empleado_key,
    s.sucursal_key,
    cn.canal_key,
    f.fecha_hora_key,
    (1 + ((gs * 7 + gs / 15) % 4))
        * COALESCE(b.mult, 1) * COALESCE(se.mult, 1),
    ROUND(l.costo_lote * (1 + (mk.m - 1) * rg.rf), 2),
    CASE
        WHEN gs % 7 = 0  THEN ROUND(l.costo_lote * 0.10, 2)
        WHEN gs % 13 = 0 THEN ROUND(l.costo_lote * 0.15, 2)
        ELSE 0.00
    END,
    l.costo_lote
FROM generate_series(1, 2000) AS gs
JOIN LATERAL (
    SELECT producto_key, producto_id_origen
    FROM dim_producto
    ORDER BY producto_key
    OFFSET (gs % 15) LIMIT 1
) p ON TRUE
JOIN LATERAL (
    SELECT lote_key, costo_lote
    FROM dim_lote
    WHERE producto_id_origen = p.producto_id_origen
    ORDER BY lote_key
    LIMIT 1
) l ON TRUE
JOIN LATERAL (
    SELECT sucursal_key, sucursal_id_origen, region
    FROM dim_sucursal
    ORDER BY sucursal_key
    OFFSET (gs % 32) LIMIT 1
) s ON TRUE
JOIN LATERAL (
    SELECT cliente_key
    FROM dim_cliente
    ORDER BY cliente_key
    OFFSET (gs % 10) LIMIT 1
) c ON TRUE
JOIN LATERAL (
    SELECT empleado_key
    FROM dim_empleado
    WHERE sucursal_id_origen = s.sucursal_id_origen
    ORDER BY empleado_key
    OFFSET ((gs / 32) % 3) LIMIT 1
) e ON TRUE
JOIN LATERAL (
    SELECT canal_key
    FROM dim_canal
    ORDER BY canal_key
    OFFSET (gs % 3) LIMIT 1
) cn ON TRUE
JOIN LATERAL (
    SELECT fecha_hora_key, trimestre
    FROM dim_fecha
    ORDER BY fecha_hora_key
    OFFSET ((gs * 37) % (SELECT COUNT(*) FROM dim_fecha)) LIMIT 1
) f ON TRUE
JOIN markup mk ON mk.pid = p.producto_id_origen
JOIN reg rg ON rg.region = s.region
LEFT JOIN boost b ON b.region = s.region AND b.pid = p.producto_id_origen
LEFT JOIN season se ON se.trim = f.trimestre AND se.pid = p.producto_id_origen
ON CONFLICT (venta_id_origen, producto_key, lote_key) DO NOTHING;

/*
  Producto nuevo 216 (Glucómetro Digital): se lanza a mediados de abril de 2026
  en sucursales de Norte y Occidente. NO tiene ventas en Q1, por lo que sirve
  para probar el indicador "sin datos en Q1" y la división entre cero.
*/
INSERT INTO dim_producto (producto_id_origen, nombre, marca, categoria, subcategoria, unidad)
VALUES (216, 'Glucómetro Digital', 'Accu-Chek', 'Dispositivos Médicos', 'Diagnóstico', 'Pieza')
ON CONFLICT (producto_id_origen) DO NOTHING;

INSERT INTO dim_lote (lote_id_origen, producto_id_origen, fecha_caducidad, costo_lote)
VALUES (316, 216, '2029-12-31', 380.00)
ON CONFLICT (lote_id_origen) DO NOTHING;

INSERT INTO fact_venta (
    venta_id_origen, producto_key, lote_key, cliente_key, empleado_key,
    sucursal_key, canal_key, fecha_hora_key,
    cantidad, precio_unitario, descuento, costo_unitario
)
SELECT
    2000 + n,
    p.producto_key,
    l.lote_key,
    c.cliente_key,
    e.empleado_key,
    s.sucursal_key,
    cn.canal_key,
    f.fecha_hora_key,
    2 + (n % 3),
    ROUND(l.costo_lote * 1.35, 2),
    0.00,
    l.costo_lote
FROM generate_series(1, 48) AS n
JOIN LATERAL (
    SELECT producto_key FROM dim_producto WHERE producto_id_origen = 216
) p ON TRUE
JOIN LATERAL (
    SELECT lote_key, costo_lote FROM dim_lote WHERE lote_id_origen = 316
) l ON TRUE
JOIN LATERAL (
    SELECT sucursal_key, sucursal_id_origen
    FROM dim_sucursal
    WHERE sucursal_id_origen IN (101,102,103,104,117,118,119,120)
    ORDER BY sucursal_key
    OFFSET (n % 8) LIMIT 1
) s ON TRUE
JOIN LATERAL (
    SELECT cliente_key FROM dim_cliente
    ORDER BY cliente_key OFFSET (n % 10) LIMIT 1
) c ON TRUE
JOIN LATERAL (
    SELECT empleado_key FROM dim_empleado
    WHERE sucursal_id_origen = s.sucursal_id_origen
    ORDER BY empleado_key OFFSET (n % 3) LIMIT 1
) e ON TRUE
JOIN LATERAL (
    SELECT canal_key FROM dim_canal
    ORDER BY canal_key OFFSET (n % 3) LIMIT 1
) cn ON TRUE
JOIN LATERAL (
    SELECT fecha_hora_key FROM dim_fecha
    WHERE fecha >= '2026-04-15'
    ORDER BY fecha_hora_key
    OFFSET ((n * 29) % (SELECT COUNT(*) FROM dim_fecha WHERE fecha >= '2026-04-15')) LIMIT 1
) f ON TRUE
ON CONFLICT (venta_id_origen, producto_key, lote_key) DO NOTHING;
