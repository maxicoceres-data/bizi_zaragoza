-- SQLite
SELECT *
FROM bizi_data
LIMIT 5;
-- cuenta de registors
SELECT COUNT(*) AS registros
FROM bizi_data;
-- CONSULTA BICICLETAS A 0
SELECT id,
    bicis_disponibles,
    estacion,
    nombre_estacion,
    last_updated
FROM bizi_data
WHERE bicis_disponibles = 0
ORDER BY last_updated;
-- CONSULTA ANCLAJES A 0
SELECT id,
    anclajes_disponibles,
    estacion,
    nombre_estacion,
    last_updated
FROM bizi_data
WHERE anclajes_disponibles = 0
ORDER BY last_updated;
-- Contar cantidades de datos por estación. 
SELECT COUNT(*) AS registros,
    estacion,
    nombre_estacion
FROM bizi_data
GROUP BY estacion
ORDER BY estacion DESC;
-- Hay ddiferencia de cantidad de datos por estacion. Necesitariamos mas datos. 
-- consultar el porcentaje de veces que la estacion esta vacia.
WITH veces_0 AS(
    SELECT estacion,
        nombre_estacion,
        AVG(latitud) AS latitud,
        AVG(longitud) AS longitud,
        COUNT(*) AS registros,
        SUM(
            CASE
                WHEN bicis_disponibles = 0 THEN 1
                ELSE 0
            END
        ) AS cantidad_veces_bici_0
    FROM bizi_data
    GROUP BY estacion
)
SELECT estacion,
    nombre_estacion,
    latitud,
    longitud,
    cantidad_veces_bici_0,
    registros,
    ROUND(
        (CAST(cantidad_veces_bici_0 AS REAL) / registros),
        3
    ) * 100 AS porcentaje_0_bicis
FROM veces_0
ORDER BY porcentaje_0_bicis DESC;
-- consultar el porcentaje de veces que la estacion esta vacia.
WITH veces_anclajes_completo AS(
    SELECT estacion,
        nombre_estacion,
        COUNT(*) AS registros,
        SUM(
            CASE
                WHEN anclajes_disponibles = 0 THEN 1
                ELSE 0
            END
        ) AS cantidad_veces_estacion_completa
    FROM bizi_data
    GROUP BY estacion
)
SELECT estacion,
    nombre_estacion,
    cantidad_veces_estacion_completa,
    registros,
    ROUND(
        (
            CAST(cantidad_veces_estacion_completa AS REAL) / registros
        ),
        3
    ) * 100 AS porcentaje_estacion_completa
FROM veces_anclajes_completo
ORDER BY porcentaje_estacion_completa DESC;
-- porcentaje de estacion a 0 por franja horaria
WITH bizi_0_horaria AS (
    SELECT hora,
        COUNT(*) AS registros,
        SUM(
            CASE
                WHEN bicis_disponibles = 0 THEN 1
                ELSE 0
            END
        ) AS bicis_0
    FROM bizi_data
    GROUP BY hora
)
SELECT hora,
    registros,
    bicis_0,
    ROUND((CAST(bicis_0 AS REAL) / registros) * 100, 2) AS porcentaje
FROM bizi_0_horaria
GROUP BY hora
ORDER BY porcentaje DESC;
-- conulta estacion horaria x franja horaria
SELECT hora,
    estacion,
    latitud,
    longitud,
    nombre_estacion,
    registros,
    bicis_0,
    ROUND((CAST(bicis_0 AS REAL) / registros) * 100, 2) AS porcentaje
FROM (
        SELECT hora,
            estacion,
            AVG(latitud) AS latitud,
            AVG(longitud) AS longitud,
            nombre_estacion,
            COUNT(*) AS registros,
            SUM(
                CASE
                    WHEN bicis_disponibles = 0 THEN 1
                    ELSE 0
                END
            ) AS bicis_0
        FROM bizi_data
        GROUP BY estacion,
            hora,
            nombre_estacion
        HAVING count(*) >= 10
    ) AS bizi_0_horaria
ORDER BY porcentaje DESC;
-- Ranking de las 15 peores estaciones
WITH bizi_0_horaria AS (
    SELECT hora,
        estacion,
        nombre_estacion,
        COUNT(*) AS registros,
        SUM(
            CASE
                WHEN bicis_disponibles = 0 THEN 1
                ELSE 0
            END
        ) AS bicis_0
    FROM bizi_data
    GROUP BY estacion
)
SELECT estacion,
    nombre_estacion,
    registros,
    bicis_0,
    ROUND((CAST(bicis_0 AS REAL) / registros) * 100, 2) AS porcentaje
FROM bizi_0_horaria
GROUP BY estacion
HAVING registros > 20
ORDER BY porcentaje DESC
LIMIT 15;
-- cantidad de lecturas y porcentaje general de bicis en 0
SELECT COUNT(*) AS total_lecturas,
    ROUND(
        (
            CAST(
                SUM(
                    CASE
                        WHEN bicis_disponibles = 0 THEN 1
                        ELSE 0
                    END
                ) AS REAL
            ) / COUNT(*)
        ) * 100,
        2
    ) AS porcentaje_general
FROM bizi_data;