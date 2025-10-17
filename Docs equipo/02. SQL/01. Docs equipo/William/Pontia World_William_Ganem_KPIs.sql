DROP DATABASE IF EXISTS pontia_world;
CREATE DATABASE pontia_world
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE pontia_world;

-- Crear la tabla central: Ticket_Atracciones
DROP TABLE IF EXISTS ticket_atracciones;
CREATE TABLE IF NOT EXISTS ticket_atracciones (
    t_id VARCHAR(100) PRIMARY KEY,
    atraccion VARCHAR(100) NOT NULL,
    tiempo_de_espera SMALLINT,
    id_visitante SMALLINT NOT NULL,
    comienzo_atraccion_fecha_hora DATETIME NOT NULL,
    antelacion_de_compra SMALLINT NOT NULL,
    coste DECIMAL(6,2) NOT NULL,
    tipo_entrada VARCHAR(100) NOT NULL
);

-- Crear la tabla Valoraciones_Emociones
DROP TABLE IF EXISTS valoraciones_emociones;
CREATE TABLE IF NOT EXISTS valoraciones_emociones (
    t_id VARCHAR(100) PRIMARY KEY,
    emocion VARCHAR(100) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    valoracion TINYINT NOT NULL,
    CONSTRAINT fk_t_id_valoraciones_emociones
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

-- Crear la tabla Procedencia
DROP TABLE IF EXISTS procedencia;
CREATE TABLE IF NOT EXISTS procedencia (
    t_id VARCHAR(100) PRIMARY KEY,
    procedencia VARCHAR(100) NOT NULL,
    id_visitante SMALLINT NOT NULL,
    CONSTRAINT fk_t_id_procedencia
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

-- Crear la tabla Duración
DROP TABLE IF EXISTS duracion;
CREATE TABLE IF NOT EXISTS duracion (
    t_id VARCHAR(100) PRIMARY KEY,
    id_visitante SMALLINT NOT NULL,
    duracion SMALLINT,
    CONSTRAINT fk_t_id_duracion
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

SELECT * 
FROM ticket_atracciones 
LIMIT 5;

SELECT * 
FROM valoraciones_emociones 
LIMIT 5;

SELECT * 
FROM procedencia 
LIMIT 5;

SELECT * 
FROM duracion 
LIMIT 5;

#################################################
####### KPI's preguntas de negocio ##############

# (1) Calcular la media diaria de visitantes
WITH visitantes_por_dia AS (
    SELECT DATE(comienzo_atraccion_fecha_hora) AS dia,
           COUNT(DISTINCT id_visitante) AS num_visitantes
    FROM ticket_atracciones
    GROUP BY DATE(comienzo_atraccion_fecha_hora)
)
SELECT ROUND(AVG(num_visitantes), 2) AS media_diaria_visitantes
FROM visitantes_por_dia;

# (2) Calcular la cuantía total de visitantes
SELECT COUNT(DISTINCT id_visitante) AS total_visitantes
FROM ticket_atracciones;

# (3) ¿Qué días del mes ha habido más visitas y cuántas?
SELECT DAY(comienzo_atraccion_fecha_hora) AS dia_del_mes,
       COUNT(DISTINCT id_visitante) AS num_visitantes
FROM ticket_atracciones
GROUP BY DAY(comienzo_atraccion_fecha_hora)
ORDER BY num_visitantes DESC
LIMIT 5;

# (4) ¿A qué horas del día sube más gente en la atracción más visitada?
WITH atraccion_mas_visitada AS (
    SELECT atraccion
    FROM ticket_atracciones
    GROUP BY atraccion
    ORDER BY COUNT(DISTINCT id_visitante) DESC
    LIMIT 1
)
SELECT t.atraccion,
       HOUR(t.comienzo_atraccion_fecha_hora) AS hora_del_dia,
       COUNT(DISTINCT t.id_visitante) AS num_visitantes
FROM ticket_atracciones t
JOIN atraccion_mas_visitada a ON t.atraccion = a.atraccion
GROUP BY t.atraccion, HOUR(t.comienzo_atraccion_fecha_hora)
ORDER BY num_visitantes DESC, hora_del_dia
LIMIT 5;

# (5) ¿Cuáles son los 5 visitantes que se han subido en más atracciones y en cuántas? (con procedencia)
WITH atracciones_por_visitante AS (
    SELECT t.id_visitante,
           COUNT(DISTINCT t.atraccion) AS num_atracciones,
           COUNT(*) AS total_visitas,
           p.procedencia
    FROM ticket_atracciones t
    JOIN procedencia p ON t.id_visitante = p.id_visitante
    GROUP BY t.id_visitante, p.procedencia
)
SELECT id_visitante,
       num_atracciones,
       procedencia
FROM atracciones_por_visitante
ORDER BY num_atracciones DESC, total_visitas DESC, id_visitante
LIMIT 5;

WITH atracciones_por_visitante AS (
    SELECT id_visitante,
           COUNT(DISTINCT atraccion) AS num_atracciones,
           COUNT(*) AS total_visitas
    FROM ticket_atracciones
    GROUP BY id_visitante
)
SELECT id_visitante,
       num_atracciones
FROM atracciones_por_visitante
ORDER BY num_atracciones DESC, total_visitas DESC, id_visitante
LIMIT 5;

# (6) ¿Cuáles son los 5 visitantes que se han subido en menos atracciones y en cuántas?
WITH atracciones_por_visitante AS (
    SELECT id_visitante,
           COUNT(DISTINCT atraccion) AS num_atracciones,
           COUNT(*) AS total_visitas
    FROM ticket_atracciones
    GROUP BY id_visitante
)
SELECT id_visitante,
       num_atracciones
FROM atracciones_por_visitante
ORDER BY num_atracciones ASC, total_visitas ASC, id_visitante
LIMIT 5;

# (7) ¿Cuál ha sido la recaudación total del parque de atracciones?
SELECT ROUND(SUM(coste), 2) AS recaudacion_total
FROM ticket_atracciones;

# (8) Por cada atracción, ¿cuál ha sido la emoción más frecuente?
WITH emociones_por_atraccion AS (
    SELECT t.atraccion,
           v.emocion,
           COUNT(*) AS num_veces
    FROM ticket_atracciones t
    JOIN valoraciones_emociones v ON t.t_id = v.t_id
    GROUP BY t.atraccion, v.emocion
)
SELECT e1.atraccion,
       e1.emocion,
       e1.num_veces
FROM emociones_por_atraccion e1
WHERE e1.num_veces = (
    SELECT MAX(e2.num_veces)
    FROM emociones_por_atraccion e2
    WHERE e2.atraccion = e1.atraccion
)
ORDER BY e1.atraccion, e1.emocion;

# (9) ¿Cuál es la media de valoración de cada atracción?
SELECT t.atraccion,
       ROUND(AVG(v.valoracion), 2) AS media_valoracion
FROM ticket_atracciones t
JOIN valoraciones_emociones v ON t.t_id = v.t_id
GROUP BY t.atraccion
ORDER BY media_valoracion DESC;

# (10) ¿De dónde son los 3 visitantes que peores valoraciones de media han puesto?
SELECT v.id_visitante,
       ROUND(AVG(v.valoracion), 2) AS media_valoracion,
       p.procedencia
FROM (
    SELECT t.id_visitante,
           v.valoracion
    FROM valoraciones_emociones v
    JOIN ticket_atracciones t ON v.t_id = t.t_id
) v
JOIN procedencia p ON v.id_visitante = p.id_visitante
GROUP BY v.id_visitante, p.procedencia
ORDER BY media_valoracion ASC
LIMIT 2600;

# (10) ¿De dónde son los 3 visitantes que peores valoraciones de media han puesto? (mínimo 3 valoraciones)
WITH valoraciones_por_visitante AS (
    SELECT t.id_visitante,
           ROUND(AVG(v.valoracion), 2) AS media_valoracion,
           p.procedencia,
           COUNT(v.valoracion) AS num_valoraciones
    FROM valoraciones_emociones v
    JOIN ticket_atracciones t ON v.t_id = t.t_id
    JOIN procedencia p ON t.id_visitante = p.id_visitante
    GROUP BY t.id_visitante, p.procedencia
)
SELECT id_visitante,
       media_valoracion,
       procedencia
FROM valoraciones_por_visitante
ORDER BY media_valoracion ASC
LIMIT 3;

# (11) ¿Cuál es la antelación máxima con la que se adquiere cada tipo de entrada?
SELECT tipo_entrada,
       MAX(antelacion_de_compra) AS antelacion_maxima
FROM ticket_atracciones
GROUP BY tipo_entrada
ORDER BY antelacion_maxima DESC;

# (12) ¿Qué día y hora del mes se producen los tiempos de espera máximos en cada atracción?
WITH max_espera AS (
    SELECT atraccion,
           tiempo_de_espera,
           DAY(comienzo_atraccion_fecha_hora) AS dia_del_mes,
           CONCAT(LPAD(HOUR(comienzo_atraccion_fecha_hora), 2, '0'), ':00 horas') AS hora_del_dia,
           ROW_NUMBER() OVER (PARTITION BY atraccion ORDER BY tiempo_de_espera DESC, comienzo_atraccion_fecha_hora) AS rn
    FROM ticket_atracciones
    WHERE tiempo_de_espera IS NOT NULL
)
SELECT atraccion,
       dia_del_mes,
       hora_del_dia,
       CONCAT(tiempo_de_espera, ' minutos') AS tiempo_de_espera
FROM max_espera
WHERE rn = 1
ORDER BY atraccion;
#############################################################################################################
# (13) Para cada cliente, calcular el tiempo que no ha estado esperando durante su estancia en el parque

WITH tiempo_espera_total AS (
    SELECT id_visitante,
           SUM(tiempo_de_espera) AS tiempo_espera_total_minutos
    FROM ticket_atracciones
    WHERE tiempo_de_espera IS NOT NULL
    GROUP BY id_visitante
)
SELECT d.id_visitante,
       CONCAT(d.duracion, ' minutos') AS duracion_total,
       CONCAT(t.tiempo_espera_total_minutos, ' minutos') AS tiempo_espera,
       CONCAT((d.duracion - t.tiempo_espera_total_minutos), ' minutos') AS tiempo_sin_esperar
FROM duracion d
JOIN tiempo_espera_total t ON d.id_visitante = t.id_visitante
ORDER BY d.id_visitante;
#############################################################################################################
# Ver los tiempos de espera de id_visitante = 28197
SELECT t_id,
       atraccion,
       tiempo_de_espera,
       comienzo_atraccion_fecha_hora
FROM ticket_atracciones
WHERE id_visitante = 28197;

# Ver la duración de id_visitante = 28197
SELECT duracion
FROM duracion
WHERE id_visitante = 28197;
#############################################################################################################
WITH tiempo_espera_total AS (
    SELECT id_visitante,
           SUM(tiempo_de_espera) AS tiempo_espera_total_minutos
    FROM ticket_atracciones
    WHERE tiempo_de_espera IS NOT NULL
    GROUP BY id_visitante
)
SELECT d.id_visitante,
       d.duracion,
       t.tiempo_espera_total_minutos
FROM duracion d
JOIN tiempo_espera_total t ON d.id_visitante = t.id_visitante
WHERE t.tiempo_espera_total_minutos > d.duracion;
#############################################################################################################
# (13) Para cada cliente, calcular el tiempo que no ha estado esperando durante su estancia en el parque
WITH tiempo_espera_total AS (
    SELECT id_visitante,
           SUM(tiempo_de_espera) AS tiempo_espera_total_minutos
    FROM ticket_atracciones
    WHERE tiempo_de_espera IS NOT NULL
    GROUP BY id_visitante
)
SELECT d.id_visitante,
       CONCAT(d.duracion, ' minutos') AS duracion_total,
       CONCAT(COALESCE(t.tiempo_espera_total_minutos, 0), ' minutos') AS tiempo_espera,
       CONCAT(GREATEST((d.duracion - COALESCE(t.tiempo_espera_total_minutos, 0)), 0), ' minutos') AS tiempo_sin_esperar
FROM duracion d
LEFT JOIN tiempo_espera_total t ON d.id_visitante = t.id_visitante
ORDER BY d.id_visitante;
#############################################################################################################

# (14) El tiempo total de espera de las 3 atracciones mejor valoradas y las 3 peor valoradas
WITH valoraciones_atracciones AS (
    SELECT t.atraccion,
           ROUND(AVG(v.valoracion), 2) AS media_valoracion
    FROM ticket_atracciones t
    JOIN valoraciones_emociones v ON t.t_id = v.t_id
    GROUP BY t.atraccion
),
mejor_peor_valoradas AS (
    (SELECT atraccion, media_valoracion
     FROM valoraciones_atracciones
     ORDER BY media_valoracion DESC
     LIMIT 3)
    UNION
    (SELECT atraccion, media_valoracion
     FROM valoraciones_atracciones
     ORDER BY media_valoracion ASC
     LIMIT 3)
)
SELECT m.atraccion,
       m.media_valoracion,
       CONCAT(SUM(t.tiempo_de_espera), ' minutos') AS tiempo_espera_total
FROM mejor_peor_valoradas m
JOIN ticket_atracciones t ON m.atraccion = t.atraccion
GROUP BY m.atraccion, m.media_valoracion
ORDER BY m.media_valoracion DESC;

# (15) De los visitantes que compraron la entrada en taquilla, ¿cuál fue la atracción a la que más se subieron?
WITH visitas_taquilla AS (
    SELECT atraccion,
           COUNT(*) AS num_visitas
    FROM ticket_atracciones
    WHERE antelacion_de_compra = 0
    GROUP BY atraccion
)
SELECT atraccion,
       num_visitas
FROM visitas_taquilla
ORDER BY num_visitas DESC
LIMIT 2;

# (16) ¿Cuál es la atracción que tiene más número de visitantes con entrada de tipo fast-pass?
WITH visitantes_fastpass AS (
    SELECT atraccion,
           COUNT(DISTINCT id_visitante) AS num_visitantes
    FROM ticket_atracciones
    WHERE tipo_entrada = 'pase rápido'
    GROUP BY atraccion
)
SELECT atraccion,
       num_visitantes
FROM visitantes_fastpass
ORDER BY num_visitantes DESC
LIMIT 2;


SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

SELECT COUNT(emocion)
FROM valoraciones_emociones
WHERE emocion = "emocion_desconocida";

