CREATE DATABASE Diplomados;

USE Diplomados;

-- 1 Promedio del curso para cada estudiante, si aplica para dicho curso y tiene notas en dicho curso de lo contrario rellenar con 0.
SET SESSION group_concat_max_len = 1000000;

-- Generar una lista de cursos concatenados para usar en la consulta
SET @courseList = (
    SELECT GROUP_CONCAT(CONCAT('SUM(CASE WHEN cu.Nombre = ''', Nombre, ''' THEN ca.Nota * ca.Porcentaje / 100 ELSE 0 END) AS ', REPLACE(Nombre, ' ', '_')))
    FROM Curso
);

-- Crear la consulta dinámica
SET @dynamicSql = CONCAT('
SELECT es.TypeID_Estudiante, es.ID_Estudiante, ', @courseList, '
FROM Estudiante es
LEFT JOIN Calificacion ca ON es.TypeID_Estudiante = ca.TypeID_Estudiante AND es.ID_Estudiante = ca.ID_Estudiante
LEFT JOIN Curso cu ON cu.ID_Curso = ca.ID_Curso
GROUP BY es.TypeID_Estudiante, es.ID_Estudiante');

-- Preparar y ejecutar la consulta
PREPARE stmt FROM @dynamicSql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2 Cantidad de libros por genero
SELECT COALESCE(COUNT(li.Genero), 0) AS Cant,
       li.Genero AS Genero
FROM Libro li
GROUP BY li.Genero;


-- 3 Cantidad de revistas por tematica
SELECT COALESCE(COUNT(re.Tematica), 0) AS Cant,
       re.Tematica AS Tematica
FROM RevistaCientifica re
GROUP BY re.Tematica;


-- 4 Revistas cientificas con mas ded 70 ejemplares y de tipo 'Tecnica'
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING_INDEX(Autor, ' ', -1), ', ',
        SUBSTRING_INDEX(Autor, ' ', 1)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática
FROM RevistaCientifica
WHERE Tipo = 'Técnica' AND NoEjemplares > 70
ORDER BY Titulo DESC;
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING_INDEX(Autor, ' ', -1), ', ',
        SUBSTRING_INDEX(Autor, ' ', 1)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática
FROM RevistaCientifica
WHERE Tipo = 'Técnica' AND NoEjemplares > 70
ORDER BY Titulo DESC;


-- 5 Informes de Investigacion con mas de 15 ejemplares
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING_INDEX(Autor, ' ', -1), ', ',
        SUBSTRING_INDEX(Autor, ' ', 1)
    ) AS Autor, 
    NoEjemplares, 
    Tematica AS Temática 
FROM InformeInvestigacion
WHERE NoEjemplares > 15 AND (Tipo = 'Estudio de Caso' OR Tipo = 'Investigación');


-- 6 Libros de ficcion o libros mas de 600 paginas
SELECT 
    Titulo, 
    Tipo, 
    CONCAT(
        SUBSTRING_INDEX(Autor, ' ', -1), ', ',
        SUBSTRING_INDEX(Autor, ' ', 1)
    ) AS Autor, 
    NoEjemplares, 
    Genero, 
    NoPaginas
FROM Libro
WHERE Tipo = 'Ficcion' OR NoPaginas > 600
ORDER BY Tipo ASC;


-- 7 Longitud de los mensajes de anuncios
DELIMITER //

CREATE FUNCTION ContarCaracteresMensaje (Mensaje TEXT)
RETURNS INT
BEGIN
    DECLARE Contador INT;
    SET Contador = CHAR_LENGTH(Mensaje);
    RETURN Contador;
END//

DELIMITER ;

SELECT A.Fecha, 
       C.Nombre AS Nombre_Curso, 
       CONCAT(P.Nombre, ' ', P.Apellido) AS Nombre_Profesor, 
       A.Mensaje,
       ContarCaracteresMensaje(A.Mensaje) AS Longitud_Mensaje
FROM Anuncios A
JOIN Curso C ON A.ID_Curso = C.ID_Curso
JOIN Profesor_Curso PC ON PC.ID_Curso = C.ID_Curso
JOIN Profesor P ON P.TypeID_Profesor = PC.TypeID_Profesor AND P.ID_Profesor = PC.ID_Profesor;

-- 8 Prommedio de calificaciones por TI
-- Se crea la vista
CREATE OR REPLACE VIEW CalcularPromedioCalificacionesTI AS
SELECT 
    C.ID_Curso,
    E.TypeID_Estudiante,
    E.ID_Estudiante,
    C.Fecha,
    AVG(C.Nota) AS PromedioCalificaciones
FROM Calificacion C
JOIN Estudiante E ON C.TypeID_Estudiante = E.TypeID_Estudiante AND C.ID_Estudiante = E.ID_Estudiante
WHERE E.TypeID_Estudiante = 'TI'
AND C.Fecha BETWEEN '2024-02-28' AND '2024-04-30'
GROUP BY C.ID_Curso, E.TypeID_Estudiante, E.ID_Estudiante, C.Fecha;

-- Se hace consulta sobre la vista
SELECT 
    C.Fecha,  
    E.Nombre AS Nombre_Estudiante, 
    E.Apellido AS Apellido_Estudiante, 
    CO.Nombre AS Nombre_Curso,
    Promedio.PromedioCalificaciones
FROM Calificacion C
JOIN Estudiante E ON C.TypeID_Estudiante = E.TypeID_Estudiante AND C.ID_Estudiante = E.ID_Estudiante
JOIN Curso CO ON C.ID_Curso = CO.ID_Curso
JOIN CalcularPromedioCalificacionesTI Promedio 
    ON C.ID_Curso = Promedio.ID_Curso 
    AND E.TypeID_Estudiante = Promedio.TypeID_Estudiante 
    AND E.ID_Estudiante = Promedio.ID_Estudiante 
    AND C.Fecha = Promedio.Fecha
WHERE C.Fecha BETWEEN '2024-02-28' AND '2024-04-30'
GROUP BY C.Fecha, E.Nombre, E.Apellido, CO.Nombre, Promedio.PromedioCalificaciones
ORDER BY E.Nombre, C.Fecha;


-- 9 Cantidad de cursos que tiene cada profesor
-- Primero se crea una funcion para contar los cursos por profesor
DELIMITER //
CREATE FUNCTION ContarCursosPorProfesor (
    p_TypeID_Profesor VARCHAR(255),
    p_ID_Profesor VARCHAR(255)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE Contador INT;
    SELECT COUNT(*) INTO Contador 
    FROM Profesor_Curso 
    WHERE TypeID_Profesor = p_TypeID_Profesor AND ID_Profesor = p_ID_Profesor;
    RETURN Contador;
END //

DELIMITER ;

-- Consulta para obtener la cantidad de cursos por cada profesor
SELECT 
    CONCAT(P.Nombre, ' ', P.Apellido) AS Nombre_Completo,
    P.Email, P.ID_Profesor,
    ContarCursosPorProfesor(P.TypeID_Profesor, P.ID_Profesor) AS Cantidad_Cursos
FROM Profesor P;


-- 10 La nota real, nota que debe tener si en el porcentaje que falta saca 0
SELECT 
    e.TypeID_Estudiante, 
    e.ID_Estudiante,
    CONCAT(e.Nombre, ' ', e.Apellido) AS Nombre_Estudiante, 
    c.ID_Curso AS ID_Curso, 
    c.Nombre AS Curso, 
    SUM(cal.Nota * cal.Porcentaje / 100) AS Nota_final,
    SUM(cal.Porcentaje) AS Porcentaje_calificado
FROM 
    Estudiante e 
    INNER JOIN Calificacion cal 
        ON e.TypeID_Estudiante = cal.TypeID_Estudiante 
        AND e.ID_Estudiante = cal.ID_Estudiante
    INNER JOIN Curso c 
        ON cal.ID_Curso = c.ID_Curso
GROUP BY 
    e.TypeID_Estudiante, 
    e.ID_Estudiante, 
    Nombre_Estudiante, 
    c.ID_Curso, 
    c.Nombre
ORDER BY Porcentaje_calificado DESC;


-- 11 Obtener la cantidad de estudiantes por cada curso Por función escalar
DELIMITER //

CREATE OR REPLACE FUNCTION ObtenerCantidadEstudiantesPorCurso(id_curso INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE cantidad_estudiantes INT;
    SELECT COUNT(*)
    INTO cantidad_estudiantes
    FROM Curso_Estudiante ce
    WHERE ce.ID_Curso = id_curso;
    RETURN cantidad_estudiantes;
END //

DELIMITER ;

-- Crear la consulta utilizando una subconsulta
SELECT 
    c.Nombre, 
    c.Estado, 
    (SELECT COUNT(*)
     FROM Curso_Estudiante ce
     WHERE ce.ID_Curso = c.ID_Curso) AS Cantidad_estudiantes
FROM Curso c;


-- 12 
-- Crear primero una funcion para contar los cursos por sede
DELIMITER //

CREATE OR REPLACE FUNCTION CantidadDeCursosXSede(ID_Sede VARCHAR(255))
RETURNS INT
BEGIN
    DECLARE cantidad_cursos INT;
    SELECT COUNT(*)
    INTO cantidad_cursos
    FROM Sede_Curso
    WHERE ID_Sede = ID_Sede;
    RETURN cantidad_cursos;
END //

DELIMITER ;

-- Consulta utilizando la funcion almacenada
SELECT 
    s.Nombre_Sede, 
    CantidadDeCursosXSede(s.ID_Sede) AS `Cantidad de cursos` 
FROM Sede s;


-- 13 Top 3 cursos con mayor cantidad de estudiantes
DELIMITER //

CREATE PROCEDURE CalcularCantEstxCurso (IN sede_id VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE curso_id INT;
    DECLARE curso_nombre VARCHAR(255);
    DECLARE no_estudiantes INT;
    
    -- Cursor para obtener los datos
    DECLARE curso_cursor CURSOR FOR
        SELECT 
            c.ID_Curso,
            c.Nombre,
            COUNT(*) AS No_Estudiantes
        FROM 
            Curso c 
            INNER JOIN Curso_Estudiante ce ON ce.ID_Curso = c.ID_Curso
            INNER JOIN Estudiante e ON e.ID_Estudiante = ce.ID_Estudiante
            INNER JOIN Sede_Curso sc ON sc.ID_Sede = sede_id AND sc.ID_Curso = c.ID_Curso
        GROUP BY
            c.ID_Curso, c.Nombre;
            
    -- Declaraciones necesarias para manejar el cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Abrir el cursor y comenzar a leer datos
    OPEN curso_cursor;
    curso_loop: LOOP
        FETCH curso_cursor INTO curso_id, curso_nombre, no_estudiantes;
        
        -- Si no hay más datos, salir del bucle
        IF done THEN
            LEAVE curso_loop;
        END IF;
        
        -- Imprimir los datos o hacer lo que necesites con ellos
        SELECT curso_id, curso_nombre, no_estudiantes;
        
    END LOOP;
    
    -- Cerrar el cursor después de terminar de usarlo
    CLOSE curso_cursor;
    
END //

DELIMITER ;

CALL CalcularCantEstxCurso((SELECT ID_Sede FROM Sede WHERE Nombre_Sede = 'Uni2'));


-- 14 Dado el estudiante, el curso y una nota a cumplir, mostrar al usuario la nota que debe sacar en el 
-- porcentaje restante para dejar la materia en la nota a cumplir
DELIMITER //

CREATE FUNCTION CalcularNotaRestanteParaCumplir (
    TypeID_Estudiante VARCHAR(10),
    ID_Estudiante INT,
    ID_Curso INT,
    NotaCumplir DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE NotaRestante DECIMAL(10, 2);

    SELECT 
        ((NotaCumplir * 100) - SUM(ca.Nota * ca.Porcentaje)) / (100 - SUM(ca.Porcentaje)) 
    INTO NotaRestante
    FROM Calificacion ca
    INNER JOIN Curso_Estudiante ce ON ca.ID_Estudiante = ce.ID_Estudiante AND ca.ID_Curso = ce.ID_Curso
    WHERE ca.ID_Curso = ID_Curso AND ca.ID_Estudiante = ID_Estudiante AND ce.TypeID_Estudiante = TypeID_Estudiante;

    RETURN NotaRestante;
END //

DELIMITER ;

SET @TypeID_Estudiante = 'TI';
SET @ID_Estudiante = 34;
SET @ID_Curso = 1;
SET @NotaCumplir = 3;

SELECT CalcularNotaRestanteParaCumplir(@TypeID_Estudiante, @ID_Estudiante, @ID_Curso, @NotaCumplir) AS Nota_Restante_Para_Cumplir;


-- 15 Función para obtener todas las calificaciones del estudiante de un curso en específico (si se pasa el parámetro de ID_Curso por medio de 
-- una consulta se pueden obtener todas las notas de todos los cursos
DELIMITER //

CREATE PROCEDURE ObtenerCalificacionesDeEstudiante (
    IN TypeID_Estudiante VARCHAR(10),
    IN ID_Estudiante VARCHAR(20),
    IN ID_Curso INT
)
BEGIN
    SELECT 
        e.TypeID_Estudiante,
        e.ID_Estudiante,
        CONCAT(e.Apellido, ' ', e.Nombre) AS Nombre,
        c.ID_Curso,
        c.Nombre AS Nombre_Curso,
        ca.Nota,
        ca.Fecha
    FROM 
        Calificacion ca 
        JOIN Curso c ON c.ID_Curso = ca.ID_Curso 
        JOIN Estudiante e ON e.TypeID_Estudiante = ca.TypeID_Estudiante AND e.ID_Estudiante = ca.ID_Estudiante
    WHERE 
        ca.TypeID_Estudiante = TypeID_Estudiante AND 
        ca.ID_Estudiante = ID_Estudiante AND 
        ca.ID_Curso = ID_Curso;
END//

DELIMITER ;

CALL ObtenerCalificacionesDeEstudiante('CC', '0001', 41);
