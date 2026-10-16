-- Equivalencia entre consulta_v1_ia.sql y consulta_final.sql.
-- EXCEPT ALL requiere MySQL 8.0.31 o superior.
-- Pegar cada consulta (sin el punto y coma final) en lugar de <V1> y <FINAL>.
-- Ambos conteos deben ser 0.
SELECT 'v1_menos_final' AS direccion, COUNT(*) AS filas FROM ((<V1>) EXCEPT ALL (<FINAL>)) x
UNION ALL
SELECT 'final_menos_v1', COUNT(*) FROM ((<FINAL>) EXCEPT ALL (<V1>)) y;
