![Banner](https://github.com/anothersigma0x/reconocimiento_de_emociones/blob/main/BANNER.jpg)
# Proyecto Júpiter - Reconocimiento de Emociones - PontIA - Pontia World

## Descripción
El proyecto **Júpiter**, desarrollado como parte de un Máster en Data Science, tiene como objetivo aplicar técnicas de análisis de datos y ciencia de datos para mejorar la experiencia de los visitantes en los parques temáticos de la empresa ficticia **Pontia World**. El proyecto se centra en automatizar el reconocimiento de emociones en imágenes faciales (48x48 píxeles en blanco y negro) capturadas en las atracciones, junto con una transformación digital de la gestión de datos. Las etapas principales incluyen:

- **ETL con Python**: Procesamiento de datos JSON para limpieza y preparación.
- **Base de Datos en MySQL**: Diseño de un modelo relacional para almacenar datos de visitas.
- **Modelo CNN**: Desarrollo de una red neuronal convolucional para detectar emociones.
- **Visualización en Power BI**: Creación de un dashboard interactivo con KPIs clave.
- **Propuesta de IA Generativa**: Identificación de casos de uso para optimizar procesos.

El proyecto combina herramientas como Python, MySQL, y Power BI para abordar preguntas de negocio, detectar errores en los datos, y automatizar la identificación de emociones (angry, disgust, fear, happy, neutral, sad, surprise), con aplicaciones en la mejora de la experiencia del usuario.

## Objetivos y Alcance
### Objetivos
- Diseñar e implementar un modelo de datos relacional en MySQL para análisis eficiente y extracción de KPIs.
- Identificar y corregir errores en los datos (e.g., tiempos de espera inconsistentes, valores nulos) usando reglas de negocio.
- Automatizar el reconocimiento de emociones con una CNN, incluyendo análisis exploratorio, limpieza, data augmentation, entrenamiento, y evaluación.
- Calcular KPIs (e.g., media diaria de visitantes, recaudación total, emociones por atracción) y responder preguntas de negocio.
- Crear un dashboard en Power BI para visualizar métricas y proponer mejoras.
- Proponer soluciones con IA generativa para optimizar procesos internos.
- Entregar documentación completa: esquema relacional, scripts SQL, código Python, predicciones, y un informe ejecutivo.

### Alcance
- **Datos**: Subconjunto de datos de septiembre de 2022, extraídos de sistemas de Pontia World (JSON e imágenes).
- **Emociones**: 7 clases (angry, disgust, fear, happy, neutral, sad, surprise).
- **Limitaciones**: Estancia máxima de 9 horas, fast-pass con 3 días de antelación, valoraciones entre 0-10, máximo 500 visitantes por hora en una atracción.
- **Restricciones**: Datos no públicos, disponibles solo localmente.

## Dataset
- **Fuente**: Datos simulados proporcionados por Pontia World (no en repositorio público, almacenados localmente).
- **Datos para CNN**:
  - 35,887 imágenes (48x48, blanco y negro).
  - Clases: 7 emociones (angry, disgust, fear, happy, neutral, sad, surprise).
  - Distribución: 30,273 imágenes de entrenamiento, 7,178 de prueba.
  - Preprocesamiento: Imágenes normalizadas (valores entre 0 y 1).
- **Datos para ETL y análisis**:
  - Formato: 6 archivos JSON (`id_visitante-atracciones.json`, `id_visitante-duracion.json`, `id_visitante-procedencia.json`, `id_visitante-ticket.json`, `emocion.json`).
  - Contenido: Información de visitas (t_id, atraccion, tiempo_de_espera, id_visitante, etc.).
- **Nota**: Los datos deben estar disponibles localmente para reproducir el proyecto.

## Metodología
### ETL con Python
- **Librerías**: `pandas`, `numpy`, `json`, `plotly.express`, `seaborn`, `matplotlib`.
- **Pasos**:
  - Carga de 6 archivos JSON a DataFrames.
  - Limpieza: Eliminación/tratamiento de valores nulos y duplicados.
    - Imputación de nulos: Atracciones (~3%) como "desconocida", emociones como "emoción desconocida".
    - Corrección de valores negativos en tiempo de espera y precios.
  - Visualizaciones previas para análisis interno (gráficos de distribución, correlaciones).

### Base de Datos en MySQL
- **Esquema relacional**:
  - **Tablas**:
    - `ticket_atracciones`: Clave primaria `t_id`, columnas `atraccion`, `tiempo_de_espera`, `id_visitante`, etc.
    - `valoraciones_emociones`: `t_id` (FK), `emocion`, `fecha_hora`, `valoracion`.
    - `procedencia`: `t_id` (FK), `procedencia`, `id_visitante`.
    - `duracion`: `t_id` (FK), `id_visitante`, `duracion`.
  - **Relaciones**: Todas las tablas secundarias vinculadas a `ticket_atracciones` vía `t_id`.
  - **Configuración**: Base de datos `pontia_world` con codificación UTF-8.
- **Conexión**: Usando `mysql-connector-python` para cargar datos desde Python.

### Visualización en Power BI
- **Dashboard**:
  - **KPIs** (tarjetas): Media diaria de visitantes (~1,045), total de visitantes (32,137), recaudación total (609,456 €), media de valoración (4.98), atracción más visitada ("desconocida").
  - **Visuales**:
    - Gráfico de barras: Emociones por atracción (proporcional a conteos).
    - Gráfico de barras: Media de valoración por atracción (tamaño por número de valoraciones).
    - Mapa: Procedencia de visitantes (concentración en Europa y América del Sur).
    - Slicer: Filtro por día del mes (1-30).
  - **Insights**:
    - "Desconocida" representa ~60% de visitas, indicando fallos en captura de datos.
    - Emociones dominantes: "happy" (60%), "neutral" (20%), "fear" (10% en atracciones de adrenalina).
    - Valoraciones: 3.80-4.98, correlación entre popularidad y satisfacción.
    - Procedencia: 40% desde España.
  - **Conexión**: Directa a MySQL mediante conector nativo.

### Modelo CNN
- **Framework**: TensorFlow/Keras.
- **Arquitectura**:
  - 6 capas Conv2D (32/64/128 filtros), BatchNormalization, ReLU.
  - 3 MaxPooling2D, 4 Dropout, 1 SeparableConv2D, 1 GlobalAveragePooling2D.
  - Capa Dense final (7 neuronas, softmax).
  - Parámetros: 306,727 (305,575 entrenables).
- **Entrenamiento**:
  - Dataset: 22,968 train, 5,741 validación, 7,178 test.
  - Batch size: 32, Epochs: 60 (con EarlyStopping, ReduceLROnPlateau).
  - Optimizador: Adam (lr inicial 0.001), Loss: categorical_crossentropy.
  - Data Augmentation: Aplicado vía `ImageDataGenerator`.
  - Class Weights: Para balancear clases (e.g., disgust: 9.40, happy: 0.57).
- **Rendimiento**:
  - Validación: Accuracy 62.41%, Macro F1: 0.5841.
  - Test: Accuracy 63.11%, Macro F1: 0.5873.
  - Mejor en `happy` (F1: 0.8474), `surprise` (F1: 0.7630); peor en `fear` (F1: 0.3563).
- **Comparaciones**:
  - Logistic Regression (todas las clases): Test Accuracy 64.34%, Macro F1: 0.6233.
  - Logistic Regression (subset angry/fear/sad): Test Accuracy 63.36%, Macro F1: 0.6305.
  - Router (General + Subset): Test Accuracy 63.11%, Macro F1: 0.5874.
  - Ensamble (α=0.25): Test Accuracy 64.54%, Macro F1: 0.6237 (mejor modelo).
- **Predicciones**: Generadas para datos no etiquetados (formato CSV con `t_id` y emoción).

## Requisitos e Instalación
### Requisitos
- **Python**: 3.10.13.
- **Librerías principales**:
  - `tensorflow==2.10.0`, `keras==2.10.0`.
  - `pandas==2.2.1`, `numpy==1.26.4`.
  - `matplotlib==3.8.4`, `seaborn==0.13.2`, `scikit-learn==1.4.2`.
  - `mysql-connector-python` (para conectar con MySQL).
  - Ver archivo `environment.yml` para la lista completa.
- **MySQL**: Servidor local (versión recomendada: 8.0 o superior).
- **Power BI**: Power BI Desktop (con conector MySQL nativo).
- **Datos**: Imágenes y JSON proporcionados por Pontia World (almacenados localmente).

### Instalación
1. Clona el repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd pontia-ml

Crea y activa el entorno Conda:
bashconda env create -f environment.yml
conda activate pontia-ml

Configura el servidor MySQL:

Instala MySQL (e.g., MySQL Community Server 8.0).
Importa el esquema: mysql -u <user> -p pontia_world < schema.sql.


Configura Power BI:

Instala Power BI Desktop.
Conecta a la base de datos pontia_world usando el conector MySQL.


Asegúrate de tener los datos (imágenes y JSON) en el directorio local especificado en los scripts.

### Nota: Los datos no están en un repositorio público. Contacta al equipo del proyecto para obtener acceso.

### Resultados y Evaluación

Métricas Principales:

Modelo CNN (reconocimiento de emociones):

Test: Accuracy 63.11%, Macro F1-score 0.5873.
Mejor desempeño en happy (F1: 0.8474, recall: 82.19%) y surprise (F1: 0.7630, recall: 80.99%).
Peor desempeño en fear (F1: 0.3563, recall: 25.98%) y disgust (F1: 0.4821).
Comparación: Ensamble (α=0.25) logró mejor accuracy (64.54%) y Macro F1 (0.6237) que la CNN sola.


### KPIs de Negocio (Power BI):

Media diaria de visitantes: ~1,045.
Total de visitantes: 32,137.
Recaudación total: 609,456 €.
Media de valoración: 4.98.
Emoción más frecuente por atracción: "happy" (60%), "neutral" (20%), "fear" (10% en atracciones de adrenalina).
Procedencia: 40% de visitantes de España.


Consultas SQL: 
Respondidas preguntas de negocio, como atracciones más/menos visitadas, tiempos de espera máximos, y valoraciones promedio por atracción.


### Desafíos Enfrentados:

Desbalanceo de clases: Clases como disgust (pocos datos) y fear fueron difíciles de predecir, requiriendo pesos de clase y data augmentation.
Valores nulos: ~3% de atracciones imputadas como "desconocida", afectando análisis inicial; emociones nulas imputadas como "emoción desconocida".
Datos erróneos: Valores negativos en tiempos de espera y precios corregidos durante el ETL.
Rendimiento del modelo: Dificultad para mejorar la precisión en emociones ambiguas (fear, sad) debido a confusiones en la matriz de confusión.



Screenshots

<img src="screenshots/dashboard.png" alt="Dashboard de Power BI">: Muestra los KPIs y visuales del dashboard.
<img src="screenshots/confusion_matrix.png" alt="Matriz de Confusión">: Representa la matriz de confusión del modelo CNN en el conjunto de test.

Contribuyentes

### [Anamaria Turdas]: [Rol: ETL, SQL, CNN, ML, PowerBi, Leadership].

### [William Ganem]: [Rol: ETL, SQL, CNN, ML, PowerBi].

### [Ines Benito]: [Rol: ETL, SQL, ML, PowerBi].

### [Iñigo Ugidos]: [Rol: ETL, SQL, ML].
