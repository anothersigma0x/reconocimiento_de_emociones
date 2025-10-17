#######################################################################
#Creación de la base de datos
#######################################################################

# Empezamos eliminando la database en caso de que exista:
DROP DATABASE IF EXISTS pontia_world;

# Crear una base de datos llamada pontia_world y meternos en ella:
CREATE DATABASE IF NOT EXISTS pontia_world;

USE pontia_world;

#######################################################################
#Creación de las tablas
#######################################################################
#Creamos las tablas sin Foreign Key porque sino no deja la importación de los csv:

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
    valoracion TINYINT NOT NULL
);

-- Crear la tabla Procedencia
DROP TABLE IF EXISTS procedencia;
CREATE TABLE IF NOT EXISTS procedencia (
    t_id VARCHAR(100) PRIMARY KEY,
    procedencia VARCHAR(100) NOT NULL,
    id_visitante SMALLINT NOT NULL
);

-- Crear la tabla Duración
DROP TABLE IF EXISTS duracion;
CREATE TABLE IF NOT EXISTS duracion (
    t_id VARCHAR(100) PRIMARY KEY,
    id_visitante SMALLINT NOT NULL,
    duracion SMALLINT
);

#######################################################################
#Importación de tablas y comprobación
#######################################################################

#COMENTARIO SOLO INÉS: Tuve que pasar a la codificación latin1 / ISO-8859-1 los csv de "procedencia" y "ticket_atracciones"

#Tras importar las tablas a través de "Table data import wizard", comprobamos que podemos verlas correctamente:
SELECT * FROM duracion;
SELECT * FROM valoraciones_emociones;
SELECT * FROM procedencia;
SELECT * FROM ticket_atracciones;

#######################################################################
#Alteramos las tablas con la Foreign Keys
#######################################################################

ALTER TABLE valoraciones_emociones
ADD CONSTRAINT fk_t_id_valoraciones_emociones
FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id);

ALTER TABLE procedencia
ADD CONSTRAINT fk_t_id_procedencia
FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id);

ALTER TABLE duracion
ADD CONSTRAINT fk_t_id_duracion
FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id);

#######################################################################
#Consultas KPIs
#######################################################################

#1) Calcular la media diaria de visitantes
SELECT ROUND(AVG(visitantes_por_dia),0) AS media_visitantes_por_día
FROM (SELECT 
	DATE(comienzo_atraccion_fecha_hora) AS fecha,
	COUNT(DISTINCT id_visitante) as visitantes_por_dia
	FROM ticket_atracciones
	GROUP BY fecha
) AS visitantes_diario;
#Respuesta: 1037

#2) Calcular la cuantía total de visitantes
SELECT COUNT(DISTINCT id_visitante) AS total_visitantes
FROM ticket_atracciones;
#Respuesta: 32137

#3) ¿Qué días del mes ha habido más visitas y cuántas?
SELECT DATE(comienzo_atraccion_fecha_hora) AS fecha,
		COUNT(t_id) AS total_visitas
FROM ticket_atracciones
GROUP BY fecha
ORDER BY total_visitas DESC
LIMIT 5; #Lo hemos limitado a 5 para ver solo las 5 primeras.

#4) ¿A qué horas del día sube más gente en la atracción más visitada?
SELECT 
    HOUR(comienzo_atraccion_fecha_hora) AS hora,
    atraccion,
    COUNT(t_id) AS total_visitas
FROM ticket_atracciones
WHERE 
    atraccion IN (
        SELECT atraccion
        FROM (
            SELECT atraccion, COUNT(t_id) AS total_visitas
            FROM ticket_atracciones
            GROUP BY atraccion
            ORDER BY total_visitas DESC
        ) AS atracciones_mas_visitadas
        WHERE total_visitas = (
            SELECT MAX(total_visitas)
            FROM (
                SELECT COUNT(t_id) AS total_visitas
                FROM ticket_atracciones
                GROUP BY atraccion
            ) AS totales
        )
    )
GROUP BY hora, atraccion
ORDER BY total_visitas DESC;

#Como vemos que la atracción más visitada es "desconocido" que corresponde a los nulos, vamos a ir con la segunda opción más visitada que tendrá una atracción real:
WITH ranking_atracciones AS(
	SELECT
		atraccion,
		COUNT(t_id) AS total_visitas,
        RANK() OVER(ORDER BY COUNT(t_id) DESC) AS ranking
	FROM ticket_atracciones
    GROUP BY atraccion
)
SELECT 
	HOUR(comienzo_atraccion_fecha_hora) AS hora,
    atraccion,
    COUNT(t_id) AS total_visitas
FROM ticket_atracciones
WHERE atraccion IN (
	SELECT atraccion
    FROM ranking_atracciones
    WHERE ranking = 2
    )
GROUP BY atraccion, hora
ORDER BY total_visitas DESC;

#5) ¿Cuáles son los 5 visitantes que se han subido en más atracciones y en cuántas?
WITH ranking_visitas AS (
	SELECT
		id_visitante, 
		COUNT(atraccion) AS recuento_atracciones,
		RANK() OVER (ORDER BY COUNT(atraccion) DESC) AS ranking
	FROM ticket_atracciones
	GROUP BY id_visitante
)
SELECT 
	id_visitante,
    recuento_atracciones
FROM ranking_visitas
WHERE ranking <= 5;

#Como vemos que hay muchos empates a partir del 5º puesto, nos quedamos con los 4 primeros:
WITH ranking_visitas AS (
	SELECT
		id_visitante, 
		COUNT(atraccion) AS recuento_atracciones,
		RANK() OVER (ORDER BY COUNT(atraccion) DESC) AS ranking
	FROM ticket_atracciones
	GROUP BY id_visitante
)
SELECT 
	id_visitante,
    recuento_atracciones
FROM ranking_visitas
WHERE ranking <= 4;

#6) ¿Cuáles son los 5 visitantes que se han subido en menos atracciones y en cuántas?
WITH ranking_visitas AS(
	SELECT
		id_visitante,
        COUNT(atraccion) AS recuento_atracciones,
        RANK() OVER(ORDER BY COUNT(atraccion) ASC) AS ranking
	FROM ticket_atracciones
    GROUP BY id_visitante
)
SELECT 
	id_visitante,
    recuento_atracciones
FROM ranking_visitas
WHERE ranking <=5;

#Aquí vemos que hay un gran empate con respecto a los visitantes que se han montado en más atracciones, para tener una visión más global, vamos a ver las visitas por el número de atracciones en las que se han montado:
WITH recuento_atraccion_visitante AS(
	SELECT
		id_visitante,
		COUNT(atraccion) AS recuento_atracciones
	FROM ticket_atracciones
	GROUP BY id_visitante
)
SELECT
	recuento_atracciones,
	COUNT(DISTINCT id_visitante) AS total_visitantes,
    ROUND(COUNT(DISTINCT id_visitante)*100.0 / (SELECT COUNT(DISTINCT id_visitante) FROM recuento_atraccion_visitante),2) AS porcentaje_visitantes
FROM recuento_atraccion_visitante
GROUP BY recuento_atracciones;

#7) ¿Cuál ha sido la recaudación total del parque?
SELECT ROUND(SUM(coste),2) As recaudacion_total
FROM ticket_atracciones;

# 8) Por cada atracción, ¿cuál ha sido la emoción más fuerte?
SELECT atraccion, emocion, recuento_emocion
FROM(
	SELECT
		t.atraccion,
		v.emocion,
		COUNT(emocion) AS recuento_emocion,
		RANK() OVER (PARTITION BY t.atraccion ORDER BY COUNT(t.t_id) DESC) AS rank_emocion
	FROM ticket_atracciones t
	INNER JOIN valoraciones_emociones v
	ON t.t_id = v.t_id
	GROUP BY t.atraccion, v.emocion
) AS emocion_mas_fuerte
WHERE rank_emocion = 1;

#9) ¿Cuál es la media de valoración de cada atracción?
SELECT
	t.atraccion,
    ROUND(AVG(v.valoracion),2) AS media_valoraciones
FROM ticket_atracciones t
INNER JOIN valoraciones_emociones v
ON t.t_id = v.t_id
GROUP BY t.atraccion
ORDER BY media_valoraciones DESC;

#10) ¿De dónde son los 3 visitantes que peores valoraciones de media han puesto?
WITH medias AS (
    SELECT
        t.id_visitante AS id_visitante,
        p.procedencia AS procedencia,
        AVG(v.valoracion) AS media_valoraciones
    FROM ticket_atracciones t
    INNER JOIN valoraciones_emociones v ON t.t_id = v.t_id
    INNER JOIN procedencia p ON t.t_id = p.t_id
    GROUP BY t.id_visitante, p.procedencia
),
ranking AS (
    SELECT
        id_visitante,
        procedencia,
        media_valoraciones,
        DENSE_RANK() OVER (ORDER BY media_valoraciones ASC) AS ranking_valoraciones
    FROM medias
)
SELECT id_visitante, procedencia, media_valoraciones
FROM ranking
WHERE ranking_valoraciones <= 3
ORDER BY media_valoraciones ASC;

#Como vemos que hay muchos empates con varias procedencias, vamos a ver el procentaje de visitantes por procedencias, de este grupo con las 3 peores valoraciones:
WITH medias AS(
    SELECT
        t.id_visitante AS id_visitante,
        p.procedencia AS procedencia,
        AVG(v.valoracion) AS media_valoraciones
    FROM ticket_atracciones t
    INNER JOIN valoraciones_emociones v ON t.t_id = v.t_id
    INNER JOIN procedencia p ON t.t_id = p.t_id
    GROUP BY t.id_visitante, p.procedencia
),
ranking AS (
    SELECT
        id_visitante,
        procedencia,
        media_valoraciones,
        DENSE_RANK() OVER (ORDER BY media_valoraciones ASC) AS ranking_valoraciones
    FROM medias
)
SELECT 
	procedencia,
	COUNT(id_visitante) AS total_visitantes,
    ROUND(COUNT(id_visitante)*100.0 / (SELECT COUNT(id_visitante) FROM ranking),2) AS porcentaje_visitantes
FROM ranking
WHERE ranking_valoraciones <= 3
GROUP BY procedencia
ORDER BY total_visitantes DESC;

#Por otro lado, vamos a ver la cantidad de visitantes, y su respectivo porcentaje, por cada una de las 3 peores valoraciones:
WITH medias AS(
    SELECT
        t.id_visitante AS id_visitante,
        p.procedencia AS procedencia,
        AVG(v.valoracion) AS media_valoraciones
    FROM ticket_atracciones t
    INNER JOIN valoraciones_emociones v ON t.t_id = v.t_id
    INNER JOIN procedencia p ON t.t_id = p.t_id
    GROUP BY t.id_visitante, p.procedencia
),
ranking AS (
    SELECT
        id_visitante,
        procedencia,
        media_valoraciones,
        DENSE_RANK() OVER (ORDER BY media_valoraciones ASC) AS ranking_valoraciones
    FROM medias
)
SELECT 
	media_valoraciones,
	COUNT(DISTINCT id_visitante) AS total_visitantes,
    ROUND(COUNT(DISTINCT id_visitante)*100.0 / (SELECT COUNT(DISTINCT id_visitante) FROM ranking),2) AS porcentaje_visitantes
FROM ranking
WHERE ranking_valoraciones <= 3
GROUP BY media_valoraciones;

#11) ¿Cuál es la antelación máxima con la que se adquiere cada tipo de entrada?
SELECT 
	tipo_entrada,
	MAX(antelacion_de_compra) AS antelación_máxima
FROM ticket_atracciones
GROUP BY tipo_entrada
ORDER BY antelación_máxima DESC;

#12) ¿Qué día y hora del mes se producen los tiempos de espera máximos en cada atracción?
WITH ranking_tiempos_espera AS(
	SELECT 
		comienzo_atraccion_fecha_hora,
        atraccion,
        tiempo_de_espera,
        RANK() OVER(PARTITION BY atraccion ORDER BY tiempo_de_espera DESC) AS ranking
	FROM ticket_atracciones
)
SELECT 
	atraccion,
	comienzo_atraccion_fecha_hora,
    tiempo_de_espera
FROM ranking_tiempos_espera
WHERE ranking = 1
ORDER BY tiempo_de_espera DESC;

#13) Para cada cliente, calcular el tiempo que no ha estado esperando durante su estancia en el parque.
#Lo vemos ordenando de mayor a menor el tiempo total de espera:
SELECT 
    t.id_visitante,
    SUM(d.duracion - t.tiempo_de_espera) AS tiempo_total_sin_esperas
FROM ticket_atracciones t
INNER JOIN duracion d ON t.t_id = d.t_id
GROUP BY t.id_visitante
ORDER BY tiempo_total_sin_esperas DESC;

#Lo vemos ordenando de menor a mayor el tiempo total de espera:
SELECT 
    t.id_visitante,
    SUM(d.duracion - t.tiempo_de_espera) AS tiempo_total_sin_esperas
FROM ticket_atracciones t
INNER JOIN duracion d ON t.t_id = d.t_id
GROUP BY t.id_visitante
ORDER BY tiempo_total_sin_esperas ASC;

#Como vemos que salen negativos, vamos a ver las incongruencias:
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
WHERE t.tiempo_espera_total_minutos >= d.duracion;

#14) El tiempo total de espera de las 3 atracciones mejor valoradas y las 3 peor valoradas.

#Tres atracciones mejor valoradas
SELECT
	atraccion,
    tiempo_total_espera,
    media_valoracion
FROM(
	SELECT
		t.atraccion,
		SUM(t.tiempo_de_espera) AS tiempo_total_espera,
		AVG(v.valoracion) AS media_valoracion,
		RANK() OVER(ORDER BY AVG(v.valoracion) DESC) AS ranking
	FROM ticket_atracciones t
	INNER JOIN valoraciones_emociones v
	ON t.t_id = v.t_id
	GROUP BY t.atraccion
	ORDER BY media_valoracion DESC
) AS ranking_valoracion_atracciones
WHERE ranking IN (1, 2, 3)
ORDER BY ranking ASC;

#Tres atracciones peor valoradas
SELECT
	atraccion,
    tiempo_total_espera,
    media_valoracion
FROM(
	SELECT
		t.atraccion,
		SUM(t.tiempo_de_espera) AS tiempo_total_espera,
		AVG(v.valoracion) AS media_valoracion,
		RANK() OVER(ORDER BY AVG(v.valoracion) ASC) AS ranking
	FROM ticket_atracciones t
	INNER JOIN valoraciones_emociones v
	ON t.t_id = v.t_id
	GROUP BY t.atraccion
	ORDER BY media_valoracion DESC
) AS ranking_valoracion_atracciones
WHERE ranking IN (1, 2, 3)
ORDER BY ranking ASC;

#15) De los visitantes que compraron la entrada en taquilla, ¿cuál fue la atracción a la que más se subieron?
WITH subidas_por_atraccion AS(
	SELECT
		atraccion,
		COUNT(atraccion) AS recuento_subidas_por_atraccion 
	FROM ticket_atracciones
    WHERE antelacion_de_compra = 0
    GROUP BY atraccion
)
SELECT 
	atraccion,
	recuento_subidas_por_atraccion
FROM subidas_por_atraccion
WHERE recuento_subidas_por_atraccion =(
	SELECT MAX(recuento_subidas_por_atraccion)
    FROM subidas_por_atraccion
);

#Como vemos que la primera opción salen los nulos, vamos a ver los datos de la segunda opción, que sería la primera opción con nombre real:
WITH subidas_por_atraccion AS(
	SELECT 
		atraccion,
        COUNT(atraccion) AS recuento_subidas_por_atraccion,
        RANK() OVER(ORDER BY COUNT(atraccion) DESC) AS ranking_subidas
	FROM ticket_atracciones
    WHERE antelacion_de_compra = 0
    GROUP BY atraccion
    ORDER BY recuento_subidas_por_atraccion DESC
)
SELECT
	atraccion,
    recuento_subidas_por_atraccion
FROM subidas_por_atraccion
WHERE ranking_subidas IN (2);

#16) ¿Cuál es la atracción que tiene más número de visitantes con entrada de tipo fast-pass?

#Cojo solo las entradas de pase rápido que estén correctas:
WITH visitas_atraccion_pase_rapido AS(
	SELECT 
		atraccion,
		COUNT(t_id) AS recuento_visitas
	FROM ticket_atracciones
	WHERE tipo_entrada = 'pase r?pido'
	GROUP BY atraccion
	ORDER BY recuento_visitas DESC
)
SELECT
	 atraccion,
     recuento_visitas
FROM visitas_atraccion_pase_rapido
WHERE recuento_visitas = (
	SELECT MAX(recuento_visitas)
    FROM visitas_atraccion_pase_rapido
); 

#Cojo todas las entradas de pase rápido, incluídas las erróneas:
WITH visitas_atraccion_pase_rapido AS(
	SELECT 
		atraccion,
		COUNT(t_id) AS recuento_visitas
	FROM ticket_atracciones
	WHERE tipo_entrada = 'pase r?pido' OR tipo_entrada = 'pase rapido erroneo'
	GROUP BY atraccion
	ORDER BY recuento_visitas DESC
)
SELECT
	 atraccion,
     recuento_visitas
FROM visitas_atraccion_pase_rapido
WHERE recuento_visitas = (
	SELECT MAX(recuento_visitas)
    FROM visitas_atraccion_pase_rapido
); 
#Como la atracción con más nº visitantes es "desconocido",vamos a ver la segunda opción real:
#Cojo solo las entradas de pase rápido que estén correctas:
WITH visitas_atraccion_pase_rapido AS(
	SELECT 
		atraccion,
		COUNT(t_id) AS recuento_visitas,
        RANK() OVER(ORDER BY COUNT(t_id) DESC) AS ranking_visitantes
	FROM ticket_atracciones
	WHERE tipo_entrada = 'pase r?pido'
	GROUP BY atraccion
	ORDER BY recuento_visitas DESC
)
SELECT
	 atraccion,
     recuento_visitas
FROM visitas_atraccion_pase_rapido
WHERE ranking_visitantes = 2;

#Cojo todas las entradas de pase rápido, incluídas las erróneas:
WITH visitas_atraccion_pase_rapido AS(
	SELECT 
		atraccion,
		COUNT(t_id) AS recuento_visitas,
        RANK() OVER(ORDER BY COUNT(t_id) DESC) AS ranking_visitantes
	FROM ticket_atracciones
	WHERE tipo_entrada = 'pase r?pido' OR tipo_entrada = 'pase rapido erroneo'
	GROUP BY atraccion
	ORDER BY recuento_visitas DESC
)
SELECT
	 atraccion,
     recuento_visitas
FROM visitas_atraccion_pase_rapido
WHERE ranking_visitantes = 2;

#17) Calcular la media de valoración por procedencia.
SELECT
	p.procedencia,
	ROUND(AVG(v.valoracion),2) AS media_valoraciones
FROM valoraciones_emociones v
INNER JOIN procedencia p
ON v.t_id = p.t_id
GROUP BY p.procedencia
ORDER BY media_valoraciones DESC;

#18) Calcular la media de valoraciones por día.
SELECT
	fecha_hora,
    ROUND(AVG(valoracion),2) AS media_valoraciones
FROM valoraciones_emociones
GROUP BY fecha_hora
ORDER BY fecha_hora ASC;
#Vemos que las valoraciones se mantienen constantes y que no mejoran segúna avanzan los días.

#19) Calcular la duración y valoración media por visitante. ¿Cuánto más tiempo pasan en el parque mayor es la valoración?

#Ordenamos las valoraciones de menor a mayor
SELECT
	d.duracion,
	ROUND(AVG(v.valoracion), 2) AS media_valoraciones
FROM duracion d
INNER JOIN valoraciones_emociones v ON v.t_id = d.t_id
GROUP BY d.duracion
ORDER BY media_valoraciones ASC;

#Ordenamos las valoraciones de mayor a menor
SELECT
	d.duracion,
	ROUND(AVG(v.valoracion), 2) AS media_valoraciones
FROM duracion d
INNER JOIN valoraciones_emociones v ON v.t_id = d.t_id
GROUP BY d.duracion
ORDER BY media_valoraciones DESC;

#Se puede observar en en las valoraciones más altas y la valoraciones más bajas la duración en el parque es muy varible, llegando 1h o menos. 
#Los visitantes que tienen mayores duraciones, tienen una valoracion media, entre 5-3.

#20) Relación antelación de compra con el precio: ¿es más barato cuando se compra con más antelación?

#Ordenamos los precios de menor a mayor
SELECT
	antelacion_de_compra,
    ROUND(AVG(coste),2) AS media_coste
FROM ticket_atracciones
GROUP BY antelacion_de_compra
ORDER BY media_coste ASC;

#Ordenamos los precios de mayor a menor
SELECT
	antelacion_de_compra,
    ROUND(AVG(coste),2) AS media_coste
FROM ticket_atracciones
GROUP BY antelacion_de_compra
ORDER BY media_coste DESC;

#Vemos que no hay una relación clara entre ambas, y que la antelación de compra no afecta al precio. 

#21) Relación tiempo de espera y valoración: ¿Cuánto más tiempo_de_espera, menos valoración? 
SELECT
	t.tiempo_de_espera,
    ROUND(AVG(v.valoracion),2) AS media_valoraciones
FROM ticket_atracciones t
INNER JOIN valoraciones_emociones v
ON t.t_id = v.t_id
GROUP BY tiempo_de_espera
ORDER BY media_valoraciones DESC;

#Vemos que no hay una relación clara entre ambas, y que el tiempo_de_espera no afecta a la valoración.












