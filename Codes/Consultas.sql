USE Diplomados;

--Promedio del curso para cada estudiante, si aplica para dicho curso y tiene notas en dicho curso de lo contrario rellenar con 0.

DECLARE @courseList NVARCHAR(MAX);
DECLARE @dynamicSql NVARCHAR(MAX);
DECLARE @pivotSql NVARCHAR(MAX) = '';
DECLARE @columnName NVARCHAR(MAX);

-- Crear lista de nombres de columnas de cursos
SET @courseList = STUFF((
        SELECT ',' + QUOTENAME(Curso.Nombre)
        FROM Curso
        FOR XML PATH('')), 1, 1, '');
		
-- Crear consulta din�mica para el pivote
SET @dynamicSql = N'
SELECT *
FROM (
    SELECT es.TypeID_Estudiante,
		   es.ID_Estudiante, 
           COALESCE(SUM(ca.Nota * ca.Porcentaje / 100), 0) AS WeightedGrade,
		   cu.Nombre as courseName
    FROM Estudiante es
    INNER JOIN Calificacion ca ON es.TypeID_Estudiante = ca.TypeID_Estudiante AND es.ID_Estudiante = ca.ID_Estudiante
    INNER JOIN Curso cu ON cu.ID_Curso = ca.ID_Curso
    GROUP BY es.TypeID_Estudiante, es.ID_Estudiante, cu.Nombre
) AS SourceTable
PIVOT (
    SUM(WeightedGrade)
    FOR courseName IN ( ' + @courseList + ')
) AS PivotTable';

-- Construir la parte de manejo de nulos despu�s del pivote
DECLARE courseListCursor CURSOR FOR
    SELECT REPLACE(REPLACE(value, '[', ''), ']', '') FROM STRING_SPLIT(@courseList, ',');

OPEN courseListCursor;

FETCH NEXT FROM courseListCursor INTO @columnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @pivotSql = @pivotSql + ', ISNULL(' + QUOTENAME(@columnName) + ', 0) AS ' + QUOTENAME(REPLACE(@columnName, ' ', '_'));
    FETCH NEXT FROM courseListCursor INTO @columnName;
END

CLOSE courseListCursor;
DEALLOCATE courseListCursor;

-- Construir consulta final con manejo de nulos
SET @dynamicSql = N'
SELECT TypeID_Estudiante, ID_Estudiante' + @pivotSql + '
FROM (
    ' + @dynamicSql + '
) AS PivotData';

-- Ejecutar consulta din�mica
EXEC sp_executesql @dynamicSql;

--Cantidad de Libros de cada g�nero
SELECT *
FROM (
    SELECT COALESCE(COUNT(li.Genero), 0) AS Cant,
		   li.Genero AS Genero
    FROM Libro li
    GROUP BY li.Genero
) AS SourceTable

--Cantidad de Revistas cientificas por tematica
SELECT *
FROM (
    SELECT COALESCE(COUNT(re.Tematica), 0) AS Cant,
		   re.Tematica AS Tematica
    FROM RevistaCientifica re
    GROUP BY re.Tematica
) AS SourceTable

SELECT * FROM Estudiante

--Revista científica, que hayan mas de 70 ejemplares y sean de tipo Tecnica, ademas se acomodan los nombres de los autores y esta organizada por titulo descendente
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING(Autor, CHARINDEX(' ', Autor) + 1, LEN(Autor) - CHARINDEX(' ', Autor)), ', ',
        SUBSTRING(Autor, 1, CHARINDEX(' ', Autor) - 1)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática
FROM RevistaCientifica
WHERE Tipo = 'Técnica' AND NoEjemplares > 70
ORDER BY Titulo DESC

--Informe de Investigacion, que hayan mas de 15 ejemplares y sean de tipo Estudio de Caso o Investigacion, ademas se acomodan los nombres de los autores
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING(Autor, CHARINDEX(' ', Autor) + 1, LEN(Autor) - CHARINDEX(' ', Autor)), ', ',
        SUBSTRING(Autor, 1, CHARINDEX(' ', Autor) - 1)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática 
FROM InformeInvestigacion
WHERE NoEjemplares > 15 AND Tipo = 'Estudio de Caso' OR Tipo = 'Investigación'

--Libro, que sea de tipo ficcion y tengan mas de 600 paginas, ademas se acomodan los nombres de los autores y esta organizado por tipo ascendente

SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING(Autor, CHARINDEX(' ', Autor) + 1, LEN(Autor) - CHARINDEX(' ', Autor)), ', ',
        SUBSTRING(Autor, 1, CHARINDEX(' ', Autor) - 1)
    ) AS Autor, 
    NoEjemplares, 
    Genero, 
    NoPaginas
FROM Libro
WHERE Tipo = 'Ficcion' OR NoPaginas > 600
ORDER BY Tipo ASC;


-- Obtener la nota real (la nota mínima que puede sacar si en el porcentaje faltante saca 0)
-- Opción 1
CREATE OR ALTER FUNCTION dbo.CalcularPromedioPorcentaje (
    @courseID INT,
    @studentTypeID VARCHAR(10),
    @studentID VARCHAR(15)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.ID_Curso,
        c.TypeID_Estudiante,
        c.ID_Estudiante,
        SUM(c.Nota * c.Porcentaje) / 100 AS NotaFinal,
        SUM(c.Porcentaje) AS PorcentajeCalificado
    FROM 
        (SELECT DISTINCT ID_Curso, TypeID_Estudiante, ID_Estudiante, Nota, Porcentaje FROM Calificacion) c
    WHERE 
        c.ID_Curso = @courseID
        AND c.TypeID_Estudiante = @studentTypeID
        AND c.ID_Estudiante = @studentID
    GROUP BY
        c.ID_Curso, c.TypeID_Estudiante, c.ID_Estudiante
);

GO

SELECT 
    CONCAT(e.Nombre, ' ', e.Apellido) AS 'Nombre Estudiante',
    c.ID_Curso AS 'ID Curso',
	c.Nombre AS 'Curso',
    pp.NotaFinal AS 'Nota final',
    pp.PorcentajeCalificado AS 'Porcentaje calificado'
FROM 
    Estudiante e
INNER JOIN 
    Calificacion cal ON e.TypeID_Estudiante = cal.TypeID_Estudiante AND e.ID_Estudiante = cal.ID_Estudiante
INNER JOIN 
    Curso c ON cal.ID_Curso = c.ID_Curso
OUTER APPLY 
    dbo.CalcularPromedioPorcentaje(c.ID_Curso, e.TypeID_Estudiante, e.ID_Estudiante) pp
GROUP BY CONCAT(e.Nombre, ' ', e.Apellido), c.ID_Curso, c.Nombre, pp.NotaFinal, pp.PorcentajeCalificado;


-- Opción 2
SELECT 
    CONCAT(e.Nombre, ' ', e.Apellido) AS 'Nombre Estudiante',
    c.ID_Curso AS 'ID Curso',
	c.Nombre AS 'Curso',
    SUM(cal.Nota * cal.Porcentaje)/100  AS 'Nota final',
    SUM(cal.Porcentaje) AS 'Porcentaje calificado'
FROM 
    Estudiante e
INNER JOIN 
    Calificacion cal ON e.TypeID_Estudiante = cal.TypeID_Estudiante AND e.ID_Estudiante = cal.ID_Estudiante
INNER JOIN 
    Curso c ON cal.ID_Curso = c.ID_Curso
GROUP BY 
    CONCAT(e.Nombre, ' ', e.Apellido), c.ID_Curso, c.Nombre;