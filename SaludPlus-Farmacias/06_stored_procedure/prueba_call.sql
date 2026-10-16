USE saludplus_dm;

-- Prueba principal: Q2 2026 contra Q1 2026 (20 filas)
CALL sp_top5_rentables_region(2026, 2);

-- Caso límite: Q1 2026 (el trimestre anterior, Q4 2025, no tiene datos;
-- todas las filas salen con sin_datos_anterior = 1)
CALL sp_top5_rentables_region(2026, 1);

-- Periodo sin ventas: Q3 2026 (0 filas)
CALL sp_top5_rentables_region(2026, 3);

-- Parámetro inválido (lanza el error 1644 con SQLSTATE 45000)
CALL sp_top5_rentables_region(2026, 5);
