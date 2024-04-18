USE Diplomados;


-- 1)
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


-- 2)
--Cantidad de Libros de cada g�nero
SELECT *
FROM (
    SELECT COALESCE(COUNT(li.Genero), 0) AS Cant,
		   li.Genero AS Genero
    FROM Libro li
    GROUP BY li.Genero
) AS SourceTable


-- 3)
--Cantidad de Revistas cientificas por tematica
SELECT *
FROM (
    SELECT COALESCE(COUNT(re.Tematica), 0) AS Cant,
		   re.Tematica AS Tematica
    FROM RevistaCientifica re
    GROUP BY re.Tematica
) AS SourceTable

-- 4)
--Revista científica, que hayan mas de 70 ejemplares y sean de tipo Tecnica, ademas se acomodan los nombres de los autores y esta organizada por titulo descendente
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING(Autor, CHARINDEX(' ', Autor) + 1, LEN(Autor) - CHARINDEX(' ', Autor)), ', ',--El nombre
        SUBSTRING(Autor, 1, CHARINDEX(' ', Autor) - 1) --El titulo (ps Ingeniero, Doctor, etc)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática
FROM RevistaCientifica
WHERE Tipo = 'Técnica' AND NoEjemplares > 70
ORDER BY Titulo DESC


-- 5)
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


-- 6)
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


-- 7)
/*Longitud de los mensajes de los anuncios, que se encuentren entre las fechas 28 de febrero de 2024 y 29 de Mayo de 2024; 
    ademas de mostrar el nombre del curso, nombre del profesor y la fecha del anuncio */

CREATE or ALTER FUNCTION ContarCaracteresMensaje (@Mensaje NVARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @Contador INT
    SET @Contador = LEN(@Mensaje)
    RETURN @Contador
END;

SELECT A.Fecha, 
       C.Nombre AS Nombre_Curso, 
       CONCAT(P.Nombre, ' ', P.Apellido) AS Nombre_Profesor, 
       A.Mensaje,
       dbo.ContarCaracteresMensaje(A.Mensaje) AS Longitud_Mensaje
FROM Anuncios A
JOIN Curso C ON A.ID_Curso = C.ID_Curso
JOIN Profesor_Curso PC ON C.ID_Curso = PC.ID_Curso
JOIN Profesor P ON PC.TypeID_Profesor = P.TypeID_Profesor AND PC.ID_Profesor = P.ID_Profesor
WHERE A.Fecha BETWEEN '2024-02-28' AND '2024-05-29'
ORDER BY A.ID_Curso, A.Fecha, A.Mensaje;


-- 8)
/*Promedio de calificaciones (de estudiantes que tengan TI), que se encuentren entre las fechas 28 de febrero de 2024 y 30 de Abril de 2024. 
 Usando una funcion de tabla para calcular el promedio de calificaciones*/ --Se puede hacer para muchas combianciones de fechas;TypeID;o el nombre del curso, nombre del estudiante, etc.

CREATE OR ALTER FUNCTION dbo.CalcularPromedioCalificacionesTI (
    @FechaInicio DATE,
    @FechaFin DATE,
    @TipoEstudiante VARCHAR(2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        C.ID_Curso,
        E.TypeID_Estudiante,
        E.ID_Estudiante,
        C.Fecha,
        AVG(C.Nota) AS PromedioCalificaciones
    FROM Calificacion C
    JOIN Estudiante E ON C.TypeID_Estudiante = E.TypeID_Estudiante AND C.ID_Estudiante = E.ID_Estudiante
    WHERE E.TypeID_Estudiante = @TipoEstudiante
    AND C.Fecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY C.ID_Curso, E.TypeID_Estudiante, E.ID_Estudiante, C.Fecha
);

SELECT 
    C.Fecha,  
    E.Nombre AS Nombre_Estudiante, 
    E.Apellido AS Apellido_Estudiante, 
    CO.Nombre AS Nombre_Curso,
    Promedio.PromedioCalificaciones
FROM Calificacion C
JOIN Estudiante E ON C.TypeID_Estudiante = E.TypeID_Estudiante AND C.ID_Estudiante = E.ID_Estudiante
JOIN Curso CO ON C.ID_Curso = CO.ID_Curso
JOIN dbo.CalcularPromedioCalificacionesTI('2024-02-28', '2024-04-30', 'TI') Promedio ON C.ID_Curso = Promedio.ID_Curso AND E.TypeID_Estudiante = Promedio.TypeID_Estudiante AND E.ID_Estudiante = Promedio.ID_Estudiante AND C.Fecha = Promedio.Fecha
WHERE C.Fecha BETWEEN '2024-02-28' AND '2024-04-30'
Group by C.Fecha, E.Nombre, E.Apellido, CO.Nombre, Promedio.PromedioCalificaciones
ORDER BY E.Nombre, C.Fecha;


-- 9)
--Cantidad de cursos que tiene cada profesor. Usando una funcion escalar para contar la cantidad de cursos por profesor
CREATE or ALTER FUNCTION dbo.ContarCursosPorProfesor (
    @TypeID_Profesor VARCHAR(MAX),
    @ID_Profesor VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
    DECLARE @Contador INT;
    SELECT @Contador = COUNT(*) 
    FROM Profesor_Curso 
    WHERE TypeID_Profesor = @TypeID_Profesor AND ID_Profesor = @ID_Profesor;
    RETURN @Contador;
END;

SELECT 
    CONCAT(P.Nombre, ' ', P.Apellido) AS Nombre_Completo,
    P.Email, P.ID_Profesor,
    dbo.ContarCursosPorProfesor(P.TypeID_Profesor, P.ID_Profesor) AS Cantidad_Cursos
FROM Profesor P;


-- 10)
-- Obtener la nota real (la nota mínima que puede sacar si en el porcentaje faltante saca 0)
-- Opción 1
CREATE OR ALTER FUNCTION dbo.CalcularPromedioPorcentaje (@courseID INT, @studentTypeID VARCHAR(10), @studentID VARCHAR(15))
RETURNS TABLE
AS
RETURN
(
    SELECT c.ID_Curso, c.TypeID_Estudiante, c.ID_Estudiante, SUM(c.Nota * c.Porcentaje) / 100 AS NotaFinal, 
	SUM(c.Porcentaje) AS PorcentajeCalificado
    FROM 
        (SELECT DISTINCT ID_Curso, TypeID_Estudiante, ID_Estudiante, Nota, Porcentaje FROM Calificacion) c
    WHERE 
        c.ID_Curso = @courseID AND c.TypeID_Estudiante = @studentTypeID AND c.ID_Estudiante = @studentID
    GROUP BY
        c.ID_Curso, c.TypeID_Estudiante, c.ID_Estudiante
);

SELECT 
    CONCAT(e.Nombre, ' ', e.Apellido) AS 'Nombre Estudiante', c.ID_Curso AS 'ID Curso', c.Nombre AS 'Curso', pp.NotaFinal AS 'Nota final',
    pp.PorcentajeCalificado AS 'Porcentaje calificado'
FROM 
    Estudiante e INNER JOIN Calificacion cal ON e.TypeID_Estudiante = cal.TypeID_Estudiante AND e.ID_Estudiante = cal.ID_Estudiante
	INNER JOIN Curso c ON cal.ID_Curso = c.ID_Curso 
	OUTER APPLY dbo.CalcularPromedioPorcentaje(c.ID_Curso, e.TypeID_Estudiante, e.ID_Estudiante) pp
GROUP BY CONCAT(e.Nombre, ' ', e.Apellido), c.ID_Curso, c.Nombre, pp.NotaFinal, pp.PorcentajeCalificado;


-- Opción 2
SELECT 
    e.TypeID_Estudiante, e.ID_Estudiante,CONCAT(e.Nombre, ' ', e.Apellido) AS 'Nombre Estudiante', c.ID_Curso AS 'ID Curso', c.Nombre AS 'Curso', SUM(cal.Nota * cal.Porcentaje)/100  AS 'Nota final',
    SUM(cal.Porcentaje) AS 'Porcentaje calificado'
FROM 
    Estudiante e INNER JOIN Calificacion cal ON e.TypeID_Estudiante = cal.TypeID_Estudiante AND e.ID_Estudiante = cal.ID_Estudiante
	INNER JOIN Curso c ON cal.ID_Curso = c.ID_Curso
GROUP BY 
    e.TypeID_Estudiante, e.ID_Estudiante, CONCAT(e.Nombre, ' ', e.Apellido), c.ID_Curso, c.Nombre
ORDER BY 'Porcentaje calificado' DESC;


--Función para calcular el porcentaje de 'TI' y de 'CC' para todos los cursos de una sede ingresada por el usuario
CREATE OR ALTER FUNCTION dbo.CalcularPorcentajeTipoCedula (
    @ID_Sede VARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.ID_Curso,
		c.Nombre,
		(CAST((SELECT COUNT(*) FROM Estudiante e 
		       INNER JOIN Curso_Estudiante ce ON e.ID_Estudiante = ce.ID_Estudiante
               WHERE ce.ID_Curso = c.ID_Curso AND e.TypeID_Estudiante='CC') AS FLOAT) /
		 CAST((SELECT COUNT(*) FROM Estudiante e 
		       INNER JOIN Curso_Estudiante ce ON e.ID_Estudiante = ce.ID_Estudiante
               WHERE ce.ID_Curso = c.ID_Curso) AS FLOAT)) * 100 AS Porcentaje_CC,
		(CAST((SELECT COUNT(*) FROM Estudiante e 
		       INNER JOIN Curso_Estudiante ce ON e.ID_Estudiante = ce.ID_Estudiante
               WHERE ce.ID_Curso = c.ID_Curso AND e.TypeID_Estudiante='TI') AS FLOAT) /
		 CAST((SELECT COUNT(*) FROM Estudiante e 
		       INNER JOIN Curso_Estudiante ce ON e.ID_Estudiante = ce.ID_Estudiante
               WHERE ce.ID_Curso = c.ID_Curso) AS FLOAT)) * 100 AS Porcentaje_TI,
		 COUNT(*) AS No_Estudiantes
    FROM 
        Curso c 
		INNER JOIN Curso_Estudiante ce ON ce.ID_Curso = c.ID_Curso
		INNER JOIN Estudiante e ON e.ID_Estudiante = ce.ID_Estudiante
		INNER JOIN Sede_Curso sc ON sc.ID_Sede = @ID_Sede AND sc.ID_Curso = c.ID_Curso
    GROUP BY
        c.ID_Curso, c.Nombre
);

SELECT * FROM dbo.CalcularPorcentajeTipoCedula((SELECT ID_Sede FROM Sede WHERE Nombre_Sede='Uni2'));

-- 11)
-- Obtener la cantidad de estudiantes por cada curso 
-- Por función escalar
CREATE or ALTER FUNCTION dbo.ObtenerCantidadEstudiantesPorCurso(@id_curso INT)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad_estudiantes INT;
    SELECT @cantidad_estudiantes = COUNT(*)
    FROM Curso_Estudiante ce
    WHERE ce.ID_Curso = @id_curso;
    RETURN @cantidad_estudiantes;
END;

SELECT 
    c.Nombre, c.Estado, dbo.ObtenerCantidadEstudiantesPorCurso(c.ID_Curso) AS 'Cantidad estudiantes' 
FROM Curso c;

-- Por subconsulta
SELECT 
    c.Nombre,
    (SELECT COUNT(*)
     FROM Curso_Estudiante ce
     WHERE ce.ID_Curso = c.ID_Curso) AS 'Cantidad estudiantes'
FROM Curso c;


-- Función para obtener la cantidad de cursos que tiene cada sede
CREATE OR ALTER FUNCTION dbo.CantidadDeCursosXSede(@ID_Sede VARCHAR(MAX))
RETURNS INT
AS 
BEGIN
	DECLARE @cantidad_cursos INT;
	SELECT @cantidad_cursos = COUNT(*)
	FROM Sede_Curso sc
	WHERE sc.ID_Sede = @ID_Sede
	RETURN @cantidad_cursos
END;

SELECT s.Nombre_Sede, dbo.CantidadDeCursosXSede(s.ID_Sede) AS 'Cantidad de cursos' FROM Sede s;

--Función para sacar el top 3 de cursos con mayor cantidad de estudiantes por sede
CREATE OR ALTER FUNCTION dbo.CalcularCantEstxCurso (
    @ID_Sede VARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.ID_Curso,
		c.Nombre,
		COUNT(*) AS No_Estudiantes
    FROM 
        Curso c 
		INNER JOIN Curso_Estudiante ce ON ce.ID_Curso = c.ID_Curso
		INNER JOIN Estudiante e ON e.ID_Estudiante = ce.ID_Estudiante
		INNER JOIN Sede_Curso sc ON sc.ID_Sede = @ID_Sede AND sc.ID_Curso = c.ID_Curso
    GROUP BY
        c.ID_Curso, c.Nombre
);

DECLARE @sede VARCHAR(MAX) = (SELECT ID_Sede FROM Sede WHERE Nombre_Sede='Uni2');

SELECT TOP 3 *
FROM dbo.CalcularCantEstxCurso(@sede)
ORDER BY No_Estudiantes DESC
