use Diplomados;

/* Indice Filtrado */

-- 1)
-- Creacion de tabla Horario especial; este es el "where" de la creación del índice filtrado
ALTER TABLE Horarios
ADD COLUMN Es_Lunes_0800 TINYINT GENERATED ALWAYS AS (Dia = 'Jueves' AND Hora = '8:00') VIRTUAL;

-- Crear índice en la columna generada
CREATE INDEX IX_Horarios_Lunes_0800
ON Horarios (Es_Lunes_0800);

SHOW INDEX FROM horarios 

-- Medir tiempo de inicio
SET @start_time = CURRENT_TIMESTAMP(6);

-- Ejecutar tu consulta
Explain SELECT Dia, Hora
FROM horarios
WHERE Es_Lunes_0800 = 1;
-- WHERE Dia = 'Jueves' AND Hora = '10:00';

-- Medir tiempo de finalización
SET @end_time = CURRENT_TIMESTAMP(6);

-- Calcular el tiempo total de ejecución en microsegundos
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS 'Execution Time (microseconds)';


-- 2) 

Alter table Curso
ADD COLUMN Es_Activo TINYINT GENERATED ALWAYS AS (FechaInicio >= '2024-03-01' AND FechaFinal <= '2024-05-28' AND Estado = 'Activo') VIRTUAL;

-- Crear índice en la columna generada
CREATE INDEX IX_Curso_Activo
ON Curso (Es_Activo);

-- Medir tiempo de inicio
SET @start_time = CURRENT_TIMESTAMP(6);

-- Ejecutar tu consulta
Explain SELECT Nombre, FechaInicio, FechaFinal, Estado
FROM curso
WHERE Es_Activo = 1;
-- where FechaInicio >= '2024-03-01' AND FechaFinal <= '2025-05-28' AND Estado = 'Inactivo';

-- Medir tiempo de finalización
SET @end_time = CURRENT_TIMESTAMP(6);

-- Calcular el tiempo total de ejecución en microsegundos
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS 'Execution Time (microseconds)';


/* Indices Cluster */ 

-- 3) 
-- Clonación de la tabla Curso
CREATE TABLE Curso_Clone AS
SELECT *
FROM curso;

-- Crear índice clusterizado en la tabla clonada Curso_Clone en el nombre del curso
CREATE INDEX IX_Cluster_Curso_Clone_Nombre
ON Curso_Clone(Nombre);

-- Mirar si tiene los indices 
SHOW INDEX FROM Curso_Clone;
SHOW INDEX FROM Curso;


/* Indices No Cluster */

-- 4)
-- Crear índice no cluster en la tabla Biblioteca
CREATE INDEX IX_Libro_Autor
ON Libro(Autor);

-- Mirar si tiene los indices
SHOW INDEX FROM libro;

-- Consulta para ver si se usa el índice
EXPLAIN SELECT *
FROM Libro
WHERE Autor = 'J.K. Rowling';


-- 5)
-- Crear índice no cluster en la tabla RevistaCientifica
CREATE INDEX IX_RevistaCientifica_Titulo
ON RevistaCientifica(Titulo);

-- Mirar si tiene los indices
SHOW INDEX FROM RevistaCientifica;

-- Consulta para ver si se usa el índice
EXPLAIN SELECT *
FROM RevistaCientifica
WHERE Titulo = 'Nature';

-- Borrar caché
RESET QUERY CACHE;
FLUSH QUERY CACHE;
FLUSH TABLES;





