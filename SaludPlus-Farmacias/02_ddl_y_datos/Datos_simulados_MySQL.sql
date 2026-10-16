/*
  SaludPlus Farmacias - Datos simulados
  Motor: MySQL 8.0 o superior
  Ejecutar DESPUÉS del DDL (Equipo5_SaludPlus_DDL_MySQL.sql).

  - Todas las asignaciones usan ROW_NUMBER() con ORDER BY, así que la carga es
    reproducible (mismo resultado en cualquier máquina).
  - 3 empleados por sucursal y cada venta la atiende un empleado de SU sucursal.
  - Precios con margen distinto por producto y por región (las sucursales
    manejan precios distintos), y demanda regional/estacional por producto.
  - Clientes anónimos (~20 %) repartidos sin patrón por producto.
  - Producto nuevo (216) con ventas SOLO en Q2, para probar "sin datos en Q1".
  - MySQL no tiene generate_series: se usan CTE recursivas.
*/

USE saludplus_dm;
SET NAMES utf8mb4;
SET SESSION cte_max_recursion_depth = 10000;

/* dim_sucursal */
INSERT IGNORE INTO dim_sucursal (sucursal_id_origen, nombre, ciudad, region) VALUES
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
(132, 'Sucursal Chetumal Centro', 'Chetumal', 'Sur');

/* dim_producto (catálogo base de 15 productos) */
INSERT IGNORE INTO dim_producto (producto_id_origen, nombre, marca, categoria, subcategoria, unidad) VALUES
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
(215, 'Crema Humectante 400ml', 'Cerave', 'Cuidado Personal', 'Dermatología', 'Frasco');

/* dim_lote */
INSERT IGNORE INTO dim_lote (lote_id_origen, producto_id_origen, fecha_caducidad, costo_lote) VALUES
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
(315, 215, '2027-08-14', 160.00);

/* dim_cliente */
INSERT IGNORE INTO dim_cliente (cliente_id_origen, nivel_beneficios, ciudad, fecha_alta) VALUES
(401, 'Oro', 'Monterrey', '2024-01-15'),
(402, 'Plata', 'Ciudad de México', '2024-03-22'),
(403, 'Bronce', 'Guadalajara', '2024-05-10'),
(404, 'Platino', 'Monterrey', '2023-11-01'),
(405, 'Oro', 'Puebla', '2025-02-14'),
(406, 'Plata', 'Mérida', '2024-08-19'),
(407, 'Bronce', 'Querétaro', '2025-01-05'),
(408, 'Platino', 'Ciudad de México', '2023-09-12'),
(409, 'Oro', 'Cancún', '2024-10-30'),
(410, 'Sin Programa', 'Saltillo', '2025-03-01');

/* dim_empleado: 3 por sucursal (Cajero, Farmacéutico, Encargado de Tienda) */
INSERT IGNORE INTO dim_empleado (empleado_id_origen, sucursal_id_origen, nombre, puesto)
WITH RECURSIVE n (i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 132
)
SELECT
    500 + (s.i - 101) * 3 + k.i,
    s.i,
    CONCAT(
        ELT(1 + ((s.i * 3 + k.i) % 12), 'Carlos','Ana','Luis','Sofía','Jorge','Elena',
            'Fernando','Patricia','Diego','Valeria','Ricardo','Mariana'),
        ' ',
        ELT(1 + ((s.i + k.i * 3) % 8), 'Gómez','Martínez','Hernández','López','Ramírez',
            'Torres','Castillo','Morales')),
    ELT(k.i, 'Cajero', 'Farmacéutico', 'Encargado de Tienda')
FROM n s
JOIN n k ON k.i <= 3
WHERE s.i BETWEEN 101 AND 132
ORDER BY s.i, k.i;

/* dim_fecha: una fila cada 2 horas, 1-ene-2026 a 30-jun-2026 */
INSERT IGNORE INTO dim_fecha (fecha_hora, fecha, hora, rango_horario, dia_semana, mes, trimestre, anio)
WITH RECURSIVE t (dt) AS (
    SELECT CAST('2026-01-01 08:00:00' AS DATETIME)
    UNION ALL
    SELECT dt + INTERVAL 2 HOUR FROM t WHERE dt + INTERVAL 2 HOUR <= '2026-06-30 21:00:00'
)
SELECT
    dt,
    DATE(dt),
    HOUR(dt),
    CASE
        WHEN HOUR(dt) BETWEEN 7 AND 11  THEN 'Mañana'
        WHEN HOUR(dt) BETWEEN 12 AND 17 THEN 'Tarde'
        WHEN HOUR(dt) BETWEEN 18 AND 22 THEN 'Noche'
        ELSE 'Madrugada'
    END,
    ELT(WEEKDAY(dt) + 1, 'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'),
    MONTH(dt),
    QUARTER(dt),
    YEAR(dt)
FROM t
ORDER BY dt;

/*
  fact_venta - 2,000 filas del catálogo base.
  Parámetros de la simulación:
  - markup: margen de cada producto sobre su costo.
  - reg: factor de precio por región.
  - boost: demanda regional (cantidad x2 en ciertos productos por región).
  - season: demanda estacional por trimestre.
*/
INSERT INTO fact_venta (
    venta_id_origen, producto_key, lote_key, cliente_key, empleado_key,
    sucursal_key, canal_key, fecha_hora_key,
    cantidad, precio_unitario, descuento, costo_unitario
)
WITH RECURSIVE g (gs) AS (
    SELECT 1 UNION ALL SELECT gs + 1 FROM g WHERE gs < 2000
),
markup (pid, m) AS (VALUES
    ROW(201, 2.20), ROW(202, 1.90), ROW(203, 1.80), ROW(204, 2.00), ROW(205, 2.10),
    ROW(206, 1.60), ROW(207, 1.80), ROW(208, 1.50), ROW(209, 1.70), ROW(210, 1.40),
    ROW(211, 1.45), ROW(212, 1.80), ROW(213, 1.35), ROW(214, 1.25), ROW(215, 1.45)
),
reg (region, rf) AS (VALUES
    ROW('Norte', 1.00), ROW('Centro', 1.10), ROW('Occidente', 0.95), ROW('Sur', 1.05)
),
boost (region, pid, mult) AS (VALUES
    ROW('Norte', 203, 2), ROW('Norte', 204, 2),
    ROW('Sur', 207, 2), ROW('Sur', 208, 2), ROW('Sur', 209, 2),
    ROW('Centro', 213, 2), ROW('Centro', 214, 2),
    ROW('Occidente', 206, 2), ROW('Occidente', 211, 2)
),
season (trim, pid, mult) AS (VALUES
    ROW(2, 205, 2), ROW(2, 207, 2), ROW(2, 208, 2),
    ROW(1, 202, 2), ROW(1, 212, 2)
),
prod_n AS (SELECT producto_key, producto_id_origen,
                  ROW_NUMBER() OVER (ORDER BY producto_key) AS rn FROM dim_producto),
suc_n  AS (SELECT sucursal_key, sucursal_id_origen, region,
                  ROW_NUMBER() OVER (ORDER BY sucursal_key) AS rn FROM dim_sucursal),
cli_n  AS (SELECT cliente_key,
                  ROW_NUMBER() OVER (ORDER BY cliente_key) AS rn FROM dim_cliente),
emp_n  AS (SELECT empleado_key, sucursal_id_origen,
                  ROW_NUMBER() OVER (PARTITION BY sucursal_id_origen
                                     ORDER BY empleado_key) AS rn FROM dim_empleado),
can_n  AS (SELECT canal_key,
                  ROW_NUMBER() OVER (ORDER BY canal_key) AS rn FROM dim_canal),
fec_n  AS (SELECT fecha_hora_key, trimestre,
                  ROW_NUMBER() OVER (ORDER BY fecha_hora_key) AS rn,
                  COUNT(*) OVER () AS total FROM dim_fecha)
SELECT
    g.gs,
    p.producto_key,
    l.lote_key,
    CASE WHEN (g.gs * 13) % 10 < 2 THEN NULL ELSE c.cliente_key END,
    e.empleado_key,
    s.sucursal_key,
    cn.canal_key,
    f.fecha_hora_key,
    (1 + ((g.gs * 7 + g.gs DIV 15) % 4)) * COALESCE(b.mult, 1) * COALESCE(se.mult, 1),
    ROUND(l.costo_lote * (1 + (mk.m - 1) * rg.rf), 2),
    CASE
        WHEN g.gs % 7 = 0  THEN ROUND(l.costo_lote * 0.10, 2)
        WHEN g.gs % 13 = 0 THEN ROUND(l.costo_lote * 0.15, 2)
        ELSE 0.00
    END,
    l.costo_lote
FROM g
JOIN prod_n p  ON p.rn  = (g.gs % 15) + 1
JOIN dim_lote l ON l.producto_id_origen = p.producto_id_origen
JOIN suc_n s   ON s.rn  = (g.gs % 32) + 1
JOIN cli_n c   ON c.rn  = (g.gs % 10) + 1
JOIN emp_n e   ON e.sucursal_id_origen = s.sucursal_id_origen
              AND e.rn = ((g.gs DIV 32) % 3) + 1
JOIN can_n cn  ON cn.rn = (g.gs % 3) + 1
JOIN fec_n f   ON f.rn  = ((g.gs * 37) % f.total) + 1
JOIN markup mk ON mk.pid = p.producto_id_origen
JOIN reg rg    ON rg.region = s.region
LEFT JOIN boost b   ON b.region = s.region AND b.pid = p.producto_id_origen
LEFT JOIN season se ON se.trim = f.trimestre AND se.pid = p.producto_id_origen
ORDER BY g.gs;

/*
  Producto nuevo 216 (Glucómetro Digital): se lanza a mediados de abril de 2026
  en sucursales de Norte y Occidente. NO tiene ventas en Q1, por lo que sirve
  para probar el indicador "sin datos en Q1" y la división entre cero.
*/
INSERT IGNORE INTO dim_producto (producto_id_origen, nombre, marca, categoria, subcategoria, unidad)
VALUES (216, 'Glucómetro Digital', 'Accu-Chek', 'Dispositivos Médicos', 'Diagnóstico', 'Pieza');

INSERT IGNORE INTO dim_lote (lote_id_origen, producto_id_origen, fecha_caducidad, costo_lote)
VALUES (316, 216, '2029-12-31', 380.00);

INSERT INTO fact_venta (
    venta_id_origen, producto_key, lote_key, cliente_key, empleado_key,
    sucursal_key, canal_key, fecha_hora_key,
    cantidad, precio_unitario, descuento, costo_unitario
)
WITH RECURSIVE g (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM g WHERE n < 48
),
suc_n AS (SELECT sucursal_key, sucursal_id_origen,
                 ROW_NUMBER() OVER (ORDER BY sucursal_key) AS rn
          FROM dim_sucursal
          WHERE sucursal_id_origen IN (101,102,103,104,117,118,119,120)),
cli_n AS (SELECT cliente_key,
                 ROW_NUMBER() OVER (ORDER BY cliente_key) AS rn FROM dim_cliente),
emp_n AS (SELECT empleado_key, sucursal_id_origen,
                 ROW_NUMBER() OVER (PARTITION BY sucursal_id_origen
                                    ORDER BY empleado_key) AS rn FROM dim_empleado),
can_n AS (SELECT canal_key,
                 ROW_NUMBER() OVER (ORDER BY canal_key) AS rn FROM dim_canal),
fec_n AS (SELECT fecha_hora_key,
                 ROW_NUMBER() OVER (ORDER BY fecha_hora_key) AS rn,
                 COUNT(*) OVER () AS total
          FROM dim_fecha WHERE fecha >= '2026-04-15')
SELECT
    2000 + g.n,
    p.producto_key,
    l.lote_key,
    c.cliente_key,
    e.empleado_key,
    s.sucursal_key,
    cn.canal_key,
    f.fecha_hora_key,
    2 + (g.n % 3),
    ROUND(l.costo_lote * 1.35, 2),
    0.00,
    l.costo_lote
FROM g
JOIN dim_producto p ON p.producto_id_origen = 216
JOIN dim_lote l     ON l.lote_id_origen = 316
JOIN suc_n s        ON s.rn = (g.n % 8) + 1
JOIN cli_n c        ON c.rn = (g.n % 10) + 1
JOIN emp_n e        ON e.sucursal_id_origen = s.sucursal_id_origen AND e.rn = (g.n % 3) + 1
JOIN can_n cn       ON cn.rn = (g.n % 3) + 1
JOIN fec_n f        ON f.rn = ((g.n * 29) % f.total) + 1
ORDER BY g.n;
