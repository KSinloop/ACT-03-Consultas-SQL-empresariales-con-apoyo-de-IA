/*
  SaludPlus Farmacias
  Data Mart de Ventas - Etapa 4
  Motor: MySQL 8.0 o superior

  Grano de fact_venta:
  Una fila por combinación de venta, producto y lote después de consolidar
  líneas duplicadas de la misma transacción.
*/

CREATE DATABASE IF NOT EXISTS saludplus_dm
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE saludplus_dm;

/* Dimensión de producto */
CREATE TABLE dim_producto (
    producto_key        BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    producto_id_origen  BIGINT NOT NULL UNIQUE,
    nombre              VARCHAR(150) NOT NULL,
    marca               VARCHAR(100) NOT NULL,
    categoria           VARCHAR(100) NOT NULL,
    subcategoria        VARCHAR(100),
    unidad              VARCHAR(40) NOT NULL
);

/* Dimensión de lote. producto_id_origen conserva trazabilidad con la fuente. */
CREATE TABLE dim_lote (
    lote_key            BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    lote_id_origen      BIGINT NOT NULL UNIQUE,
    producto_id_origen  BIGINT NOT NULL,
    fecha_caducidad     DATE NOT NULL,
    costo_lote          DECIMAL(12,2) NOT NULL,
    CONSTRAINT ck_lote_costo CHECK (costo_lote >= 0)
);

/* El cliente puede ser nulo en la tabla de hechos cuando la venta es anónima. */
CREATE TABLE dim_cliente (
    cliente_key         BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cliente_id_origen   BIGINT NOT NULL UNIQUE,
    nivel_beneficios    VARCHAR(50),
    ciudad              VARCHAR(100),
    fecha_alta          DATE
);

CREATE TABLE dim_sucursal (
    sucursal_key        BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    sucursal_id_origen  BIGINT NOT NULL UNIQUE,
    nombre              VARCHAR(120) NOT NULL,
    ciudad              VARCHAR(100) NOT NULL,
    region              VARCHAR(100) NOT NULL
);

/* sucursal_id_origen permite auditar la adscripción operativa del empleado. */
CREATE TABLE dim_empleado (
    empleado_key        BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    empleado_id_origen  BIGINT NOT NULL UNIQUE,
    sucursal_id_origen  BIGINT NOT NULL,
    nombre              VARCHAR(150) NOT NULL,
    puesto              VARCHAR(80) NOT NULL
);

CREATE TABLE dim_canal (
    canal_key           SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_canal        VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT ck_canal_nombre CHECK (nombre_canal IN ('Mostrador', 'App', 'Domicilio'))
);

/* Una fila representa un instante de venta con atributos para agrupación. */
CREATE TABLE dim_fecha (
    fecha_hora_key      BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fecha_hora          DATETIME NOT NULL UNIQUE,
    fecha               DATE NOT NULL,
    hora                SMALLINT NOT NULL,
    rango_horario       VARCHAR(30) NOT NULL,
    dia_semana          VARCHAR(15) NOT NULL,
    mes                 SMALLINT NOT NULL,
    trimestre           SMALLINT NOT NULL,
    anio                SMALLINT NOT NULL,
    CONSTRAINT ck_fecha_hora   CHECK (hora BETWEEN 0 AND 23),
    CONSTRAINT ck_fecha_mes    CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT ck_fecha_trim   CHECK (trimestre BETWEEN 1 AND 4),
    CONSTRAINT ck_fecha_anio   CHECK (anio BETWEEN 2000 AND 2100),
    CONSTRAINT ck_fecha_fecha  CHECK (fecha = DATE(fecha_hora)),
    CONSTRAINT ck_fecha_hora2  CHECK (hora = HOUR(fecha_hora))
);

/*
  Tabla de hechos de ventas.
  Los importes calculados se generan a partir de las medidas atómicas para
  evitar diferencias entre el detalle y los totales almacenados.
*/
CREATE TABLE fact_venta (
    fact_venta_key      BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    venta_id_origen     BIGINT NOT NULL,
    producto_key        BIGINT NOT NULL,
    lote_key            BIGINT NOT NULL,
    cliente_key         BIGINT NULL COMMENT 'Nulo cuando la fuente registra una venta sin cliente identificado.',
    empleado_key        BIGINT NOT NULL,
    sucursal_key        BIGINT NOT NULL,
    canal_key           SMALLINT NOT NULL,
    fecha_hora_key      BIGINT NOT NULL,
    cantidad            INT NOT NULL,
    precio_unitario     DECIMAL(12,2) NOT NULL,
    descuento           DECIMAL(12,2) NOT NULL DEFAULT 0,
    costo_unitario      DECIMAL(12,2) NOT NULL,
    monto_total         DECIMAL(14,2) GENERATED ALWAYS AS
                        ((cantidad * precio_unitario) - descuento) STORED
                        COMMENT 'cantidad * precio_unitario - descuento',
    costo_total         DECIMAL(14,2) GENERATED ALWAYS AS
                        (cantidad * costo_unitario) STORED
                        COMMENT 'cantidad * costo_unitario',
    margen              DECIMAL(14,2) GENERATED ALWAYS AS
                        (((cantidad * precio_unitario) - descuento)
                         - (cantidad * costo_unitario)) STORED
                        COMMENT 'monto_total - costo_total',

    CONSTRAINT fk_fact_producto
        FOREIGN KEY (producto_key) REFERENCES dim_producto (producto_key),
    CONSTRAINT fk_fact_lote
        FOREIGN KEY (lote_key) REFERENCES dim_lote (lote_key),
    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (cliente_key) REFERENCES dim_cliente (cliente_key),
    CONSTRAINT fk_fact_empleado
        FOREIGN KEY (empleado_key) REFERENCES dim_empleado (empleado_key),
    CONSTRAINT fk_fact_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dim_sucursal (sucursal_key),
    CONSTRAINT fk_fact_canal
        FOREIGN KEY (canal_key) REFERENCES dim_canal (canal_key),
    CONSTRAINT fk_fact_fecha
        FOREIGN KEY (fecha_hora_key) REFERENCES dim_fecha (fecha_hora_key),
    CONSTRAINT uq_fact_grano
        UNIQUE (venta_id_origen, producto_key, lote_key),
    CONSTRAINT ck_fact_cantidad  CHECK (cantidad > 0),
    CONSTRAINT ck_fact_precio    CHECK (precio_unitario >= 0),
    CONSTRAINT ck_fact_descuento CHECK (descuento >= 0),
    CONSTRAINT ck_fact_costo     CHECK (costo_unitario >= 0),
    CONSTRAINT ck_fact_descuento_valido
        CHECK (descuento <= cantidad * precio_unitario)
) COMMENT = 'Una fila por venta, producto y lote consolidado; contiene medidas de ingreso, costo y margen.';

/* Índices para filtros y agrupaciones frecuentes del Data Mart. */
CREATE INDEX idx_fact_venta_fecha      ON fact_venta (fecha_hora_key);
CREATE INDEX idx_fact_venta_producto   ON fact_venta (producto_key);
CREATE INDEX idx_fact_venta_sucursal   ON fact_venta (sucursal_key);
CREATE INDEX idx_fact_venta_canal      ON fact_venta (canal_key);
CREATE INDEX idx_fact_venta_cliente    ON fact_venta (cliente_key);
CREATE INDEX idx_dim_producto_categoria ON dim_producto (categoria, marca);
CREATE INDEX idx_dim_lote_caducidad    ON dim_lote (fecha_caducidad);

/* Catálogo inicial de canales previstos por el caso. */
INSERT IGNORE INTO dim_canal (nombre_canal)
VALUES ('Mostrador'), ('App'), ('Domicilio');
