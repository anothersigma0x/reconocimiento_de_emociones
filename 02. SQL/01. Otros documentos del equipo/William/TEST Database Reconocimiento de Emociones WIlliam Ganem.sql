-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS reconocimiento_emociones;

-- Seleccionar la base de datos
USE reconocimiento_emociones;

-- Tabla Fotografias (tabla central con t_id como PK)
CREATE TABLE Fotografias (
    t_id VARCHAR(50) PRIMARY KEY,
    emocion VARCHAR(20) NOT NULL,
    tiempo_recogida INT NOT NULL,
    fecha_hora DATETIME,
    id_visitante VARCHAR(10)
);

-- Tabla Procedencia_Visitantes (relacionada con Fotografias por t_id)
CREATE TABLE Procedencia_Visitantes (
    t_id VARCHAR(50),
    id_visitante VARCHAR(10),
    procedencia VARCHAR(50) NOT NULL,
    FOREIGN KEY (t_id) REFERENCES Fotografias(t_id)
);

-- Tabla Atracciones (relacionada con Fotografias por t_id)
CREATE TABLE Atracciones (
    t_id VARCHAR(50),
    atraccion VARCHAR(50) NOT NULL,
    comienzo_atraccion DATETIME,
    tiempo_de_espera INT,
    id_visitante VARCHAR(10),
    FOREIGN KEY (t_id) REFERENCES Fotografias(t_id)
);

-- Tabla Ticket (relacionada con Fotografias por t_id)
CREATE TABLE Ticket (
    t_id VARCHAR(50),
    tipo_entrada VARCHAR(50) NOT NULL,
    coste DECIMAL(10, 2) NOT NULL,
    antelacion_de_compra INT,
    id_visitante VARCHAR(10),
    FOREIGN KEY (t_id) REFERENCES Fotografias(t_id)
);

-- Tabla Valoraciones (relacionada con Fotografias por t_id)
CREATE TABLE Valoraciones (
    t_id VARCHAR(50),
    valoracion TEXT,
    FOREIGN KEY (t_id) REFERENCES Fotografias(t_id)
);

-- Tabla Duracion (relacionada con Fotografias por t_id)
CREATE TABLE Duracion (
    t_id VARCHAR(50),
    duracion INT,
    id_visitante VARCHAR(10),
    FOREIGN KEY (t_id) REFERENCES Fotografias(t_id)
);

-- Verificar tablas creadas
SHOW TABLES;

SELECT *
FROM fotografias;

SELECT *
FROM valoraciones;