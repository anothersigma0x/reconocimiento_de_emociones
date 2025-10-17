-- Crear la tabla central: Ticket_Atracciones
CREATE TABLE ticket_atracciones (
    t_id VARCHAR(20) PRIMARY KEY,
    atraccion VARCHAR(30) NOT NULL,
    comienzo_atraccion SMALLINT NOT NULL,
    tiempo_de_espera SMALLINT,
    id_visitante VARCHAR(10) NOT NULL,
    comienzo_atraccion_fecha_hora DATETIME NOT NULL,
    antelacion_de_compra SMALLINT NOT NULL,
    coste DECIMAL(6,2) NOT NULL,
    tipo_entrada VARCHAR(20) NOT NULL
);

-- Crear la tabla Valoraciones_Emociones
CREATE TABLE valoraciones_emociones (
    t_id VARCHAR(20) PRIMARY KEY,
    emocion VARCHAR(10) NOT NULL,
    tiempo_recogida SMALLINT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    valoracion TINYINT NOT NULL, -- Ej. 0=negativa, 1=positiva o 1-5
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

-- Crear la tabla Procedencia
CREATE TABLE procedencia (
    t_id VARCHAR(20) PRIMARY KEY,
    procedencia VARCHAR(15) NOT NULL,
    id_visitante INTEGER NOT NULL,
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

-- Crear la tabla Duración
CREATE TABLE duracion (
    t_id VARCHAR(20) PRIMARY KEY,
    id_visitante VARCHAR(10) NOT NULL,
    duracion SMALLINT, -- Asumiendo tiempo_de_espera en minutos
    FOREIGN KEY (t_id) REFERENCES ticket_atracciones(t_id)
);

-- Crear la tabla estática Atracciones
CREATE TABLE atracciones (
    id_atraccion TINYINT PRIMARY KEY,
    nombre_atraccion VARCHAR(30) NOT NULL
);

-- Poblar la tabla Atracciones con las 35 atracciones
INSERT INTO atracciones (id_atraccion, nombre_atraccion) VALUES
(1, 'Montaña Rusa de la Luna'),
(2, 'Mansión Embrujada'),
(3, 'Simulador Espacial 3D'),
(4, 'Fiesta de los Dulces'),
(5, 'Gran Caída Libre'),
(6, 'Cine 4D Emocionante'),
(7, 'Tobogán del Arco Iris'),
(8, 'Vuelo Mágico'),
(9, 'Araña Saltarina'),
(10, 'Mundo de las Maravillas'),
(11, 'Cohetes Galácticos'),
(12, 'Safari Salvaje'),
(13, 'Barco Pirata Misterioso'),
(14, 'Montaña del Misterio'),
(15, 'Selva Encantada'),
(16, 'Jardín de las Hadas'),
(17, 'Espejos de la Risueña'),
(18, 'Laberinto de Sueños'),
(19, 'Dragón Volador'),
(20, 'Carros Chocones Divertidos'),
(21, 'Carrusel Encantado'),
(22, 'Viaje al Centro de la Tierra'),
(23, 'Caravana de Aventuras'),
(24, 'Cascada Encantada'),
(25, 'Carrera de Autos Locos'),
(26, 'Rápido del Trueno'),
(27, 'Vuelta al Mundo en 80 Días'),
(28, 'Cúpula Estelar'),
(29, 'Circuito Veloz'),
(30, 'Aventuras Acuáticas'),
(31, 'Tirolina Extrema'),
(32, 'Circus Fantástico'),
(33, 'Rueda de la Fortuna'),
(34, 'Torbellino Espacial'),
(35, 'Tren del Terror');

-- Crear la tabla estática Paises
CREATE TABLE paises (
    id_pais TINYINT PRIMARY KEY,
    nombre_pais VARCHAR(20) NOT NULL
);

-- Poblar la tabla Paises con los 34 países
INSERT INTO paises (id_pais, nombre_pais) VALUES
(1, 'España'),
(2, 'Bolivia'),
(3, 'Panamá'),
(4, 'Costa Rica'),
(5, 'Chile'),
(6, 'El Salvador'),
(7, 'India'),
(8, 'Paraguay'),
(9, 'Alemania'),
(10, 'Ecuador'),
(11, 'China'),
(12, 'Nicaragua'),
(13, 'Jamaica'),
(14, 'Canadá'),
(15, 'Honduras'),
(16, 'Filipinas'),
(17, 'Puerto Rico'),
(18, 'Argentina'),
(19, 'Cuba'),
(20, 'Brasil'),
(21, 'Estados Unidos'),
(22, 'Guatemala'),
(23, 'Colombia'),
(24, 'Guinea Ecuatorial'),
(25, 'Uruguay'),
(26, 'Perú'),
(27, 'México'),
(28, 'República Dominicana'),
(29, 'Francia'),
(30, 'Venezuela'),
(31, 'Haití'),
(32, 'Trinidad y Tobago'),
(33, 'Guinea-Bissau'),
(34, 'Italia');

-- Crear la tabla estática Emociones
CREATE TABLE emociones (
    id_emocion TINYINT PRIMARY KEY,
    nombre_emocion VARCHAR(10) NOT NULL
);

-- Poblar la tabla Emociones con las 7 emociones
INSERT INTO emociones (id_emocion, nombre_emocion) VALUES
(1, 'feliz'),
(2, 'neutral'),
(3, 'triste'),
(4, 'miedo'),
(5, 'enojado'),
(6, 'sorpresa'),
(7, 'asco');

-- Crear la tabla estática Tipos_Entrada
CREATE TABLE tipos_entrada (
    id_tipo_entrada TINYINT PRIMARY KEY,
    nombre_tipo_entrada VARCHAR(20) NOT NULL
);

-- Poblar la tabla Tipos_Entrada con los 6 tipos
INSERT INTO tipos_entrada (id_tipo_entrada, nombre_tipo_entrada) VALUES
(1, 'Pase Anual'),
(2, 'Entrada Familiar'),
(3, 'Entrada Infantil'),
(4, 'Paquete VIP'),
(5, 'Pase Rápido'),
(6, 'Entrada Individual');