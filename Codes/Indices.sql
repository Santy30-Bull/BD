Use Diplomados;
GO
--------------------------------------------------------------------------------------------------------
-- Creacion de indices
/* Indice filtrado */

--1) Indice filtrado en la tabla Horarios con condición específica
CREATE NONCLUSTERED INDEX IX_Horarios_Dia_Hora
ON Horarios(Dia, Hora)
WHERE Dia = 'Lunes' AND Hora = '08:00';

--2) Índice filtrado en la tabla Curso con condición específica
CREATE NONCLUSTERED INDEX IX_Curso_RangoFechas_Activo
ON Curso(Nombre, FechaInicio, FechaFinal, Estado)
WHERE FechaInicio >= '2024-03-01' AND FechaFinal <= '2024-05-28' AND Estado = 'Activo';

-- Eliminar index
DROP INDEX IF EXISTS IX_Curso_RangoFechas_Activo ON Curso

-- Consulta de los cursos que esten inactivos durante el rango de fechas; usando el indice filtrado
SET STATISTICS TIME ON;
SELECT Nombre, FechaInicio, FechaFinal, Estado
FROM Curso
WHERE FechaInicio >= '2024-03-01' AND FechaFinal <= '2025-05-28' AND Estado = 'Activo';
SET STATISTICS TIME OFF;

SELECT * FROM Curso
-- Borrar caché
CHECKPOINT
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

/* Indices cluster */

--3) Indice cluster en la tabla Curso

-- Clonación de la tabla Curso
SELECT *
INTO Curso_Clone
FROM Curso;
-- Índice clusterizado en la tabla clonada Curso_Clone en el nombre del curso
CREATE CLUSTERED INDEX IX_Cluster_Curso_Clone_Nombre
ON Curso_Clone(Nombre);


SELECT * FROM Curso_Clone
/* Indice no cluster */

--4) Indice no cluster en la tabla Biblioteca
CREATE NONCLUSTERED INDEX IX_Libro_Autor
ON Libro(Autor);

--5) Indice no cluster en la tabla RevistaCientifica
CREATE NONCLUSTERED INDEX IX_RevistaCientifica_Titulo
ON RevistaCientifica(Titulo);
