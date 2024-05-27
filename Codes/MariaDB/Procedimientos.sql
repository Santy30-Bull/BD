USE DIplomados;


-- 1)
-- Procedimiento que permite quitar todas las relaciones a un profesor porque sale de dar clases

DELIMITER //

CREATE OR REPLACE PROCEDURE InactivarProfesor (
    IN TypeID VARCHAR(10), IN ID VARCHAR(15)
)
BEGIN
	-- Declaración variable mensaje de error
   DECLARE ErrorMessage VARCHAR(255);
    
   -- Manejo de cualquier excepción SQL
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      -- Deshacer la transacción si surge algún error
      ROLLBACK;
      -- Obtener el mensaje de error
      GET DIAGNOSTICS CONDITION 1 ErrorMessage = MESSAGE_TEXT;
      -- Devolver el mensaje de error
      SELECT CONCAT('ERROR: ', ErrorMessage) AS Error;
   END;
    
   -- Iniciar la transacción
   START TRANSACTION;
    
   -- Verificar existencia del profesor
   IF NOT EXISTS (SELECT 1 FROM Profesor WHERE TypeID_Profesor = TypeID AND ID_Profesor = ID) THEN
      -- Lanzar el error
      SET ErrorMessage = CONCAT('El profesor con tipo de documento ', TypeID, ' y ID ', ID, ' no existe');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage;
   ELSE
      -- Eliminar relaciones y el profesor de la base de datos
      DELETE FROM Sede_Profesor WHERE TypeID_Profesor = TypeID AND ID_Profesor = ID;
      DELETE FROM Profesor_Curso WHERE TypeID_Profesor = TypeID AND ID_Profesor = ID;
      DELETE FROM Profesor WHERE TypeID_Profesor = TypeID AND ID_Profesor = ID;
        
      -- Confirmar la transacción
      COMMIT;
        
      -- Mensaje de éxito
      SELECT CONCAT('Se han quitado los cursos y la sede al profesor con tipo de documento ', TypeID, ' y ID ', ID) AS Mensaje;
   END IF;
END //

DELIMITER ;

-- Prueba
/*SELECT * FROM profesor;
SELECT * FROM sede_profesor;
SELECT * FROM profesor_curso;
CALL InactivarProfesor('IN', '0000000045');*/



-- 2)
-- Procedimiento para agregar a un estudiante a un curso en específico

DELIMITER //

CREATE OR REPLACE PROCEDURE AgregarEstudianteACurso(
	IN TypeID VARCHAR(10),
	IN ID VARCHAR(15),
	IN IDCurso VARCHAR(10)
)
BEGIN 
	DECLARE ErrorMessage VARCHAR(255);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      -- Deshacer la transacción si surge algún error
      ROLLBACK;
      -- Obtener el mensaje de error
      GET DIAGNOSTICS CONDITION 1 ErrorMessage = MESSAGE_TEXT;
      -- Devolver el mensaje de error
      SELECT CONCAT('ERROR: ', ErrorMessage) AS Error;
   END;
    
   START TRANSACTION;
    
   -- Verificar que existe el estudiante 
   IF NOT EXISTS (SELECT 1 FROM Estudiante AS e WHERE e.TypeID_Estudiante = TypeID AND e.ID_Estudiante = ID) THEN
		SET ErrorMessage = CONCAT('El estudiante con tipo de documento ', TypeID, ' y ID ', ID, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage;
		
	-- Verificar que existe el curso	
	ELSEIF NOT EXISTS (SELECT 1 FROM Curso AS c WHERE c.ID_Curso = IDCurso) THEN
		SET ErrorMessage = CONCAT('El curso con id ', IDCurso,' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage; 
		
	-- Verificar que no esté ya matriculado el estudiante
	ELSEIF EXISTS (SELECT 1 FROM Curso_Estudiante AS ce WHERE ce.TypeID_Estudiante = TypeID AND ce.ID_Estudiante = ID AND ce.ID_Curso = IDCurso) THEN
		SET ErrorMessage = CONCAT('El estudiante ya esta matriculado en el curso');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage; 
	
	ELSE 
		INSERT INTO curso_estudiante (TypeID_Estudiante, ID_Estudiante, ID_Curso) VALUES (TypeID, ID, IDCurso);
	
	COMMIT;
	SELECT CONCAT('El estudiante ha sido inscrito en el curso exitosamente') AS Mensaje;
	END IF;
END //
		
DELIMITER ;


-- Prueba
/*SELECT * FROM curso_estudiante;
CALL AgregarEstudianteACurso ('CC', '0001', '001');
CALL AgregarEstudianteACurso ('CC', '0001', '100000');*/



-- 3) 
-- Procedimiento para agregar un nuevo libro a la base de datos

DELIMITER //

CREATE OR REPLACE PROCEDURE AgregarLibro(
    IN Tipo VARCHAR(7),
    IN Titulo VARCHAR(40),
    IN Autor LONGTEXT,
    IN NoEjemplares INT,
    IN FechaPublicacion DATE,
    IN Genero VARCHAR(20),
    IN NoPaginas INT
)
BEGIN
   DECLARE ErrorMessage VARCHAR(255);
    
   -- Manejo de cualquier excepción SQL
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      -- Deshacer la transacción si surge algún error
      ROLLBACK;
      -- Obtener el mensaje de error
      GET DIAGNOSTICS CONDITION 1 ErrorMessage = MESSAGE_TEXT;
      -- Devolver el mensaje de error
      SELECT CONCAT('ERROR: ', ErrorMessage) AS Error;
   END;
    
   START TRANSACTION;
    
   IF EXISTS (SELECT 1 FROM libro AS l WHERE l.Titulo = Titulo AND l.Autor = Autor) THEN
      SET ErrorMessage = CONCAT('Ya existe un libro con el mismo título y autor');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage;
   ELSE
      INSERT INTO libro (Tipo, Titulo, Autor, NoEjemplares, FechaPublicacion, Genero, NoPaginas)
      VALUES (Tipo, Titulo, Autor, NoEjemplares, FechaPublicacion, Genero, NoPaginas);
        
      COMMIT;
      
      SELECT CONCAT('Libro agregado exitosamente.') AS Mensaje;
   END IF;
END //

DELIMITER ;

-- Prueba
/*SELECT * FROM Libro WHERE Titulo = 'El principito';
CALL AgregarLibro ('Fisico', 'El principito', 'Antoine de Saint-Exupéry', 10, '1943-04-06', 'Fábula', 96);*/


-- 4)
-- Procedimiento para actualizar la información de un estudiante

DELIMITER //

CREATE OR REPLACE PROCEDURE ActualizarInformacionEstudiante(
	IN TypeID_Estudiante VARCHAR(10),
	IN ID_Estudiante VARCHAR(15),
	IN NuevoNombre VARCHAR(50),
	IN NuevoApellido VARCHAR(50),
	IN NuevoCorreo VARCHAR(100)
)
BEGIN
	DECLARE ErrorMessage VARCHAR(255);
    
   -- Manejo de cualquier excepción SQL
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      -- Deshacer la transacción si surge algún error
      ROLLBACK;
      -- Obtener el mensaje de error
      GET DIAGNOSTICS CONDITION 1 ErrorMessage = MESSAGE_TEXT;
      -- Devolver el mensaje de error
      SELECT CONCAT('ERROR: ', ErrorMessage) AS Error;
   END;
   
   START TRANSACTION;
   
   IF NOT EXISTS (SELECT 1 FROM estudiante AS e WHERE e.TypeID_Estudiante = TypeID_Estudiante AND e.ID_Estudiante = ID_Estudiante) THEN
   	SET ErrorMessage = CONCAT('El estudiante con tipo de documento ', TypeID_Estudiante, ' y ID ', ID_Estudiante, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage;
	ELSE
		UPDATE estudiante AS e 
		SET Nombre = NuevoNombre, Apellido = NuevoApellido, Email = NuevoCorreo
		WHERE e.TypeID_Estudiante = TypeID_Estudiante AND e.ID_Estudiante = ID_Estudiante;
	
		COMMIT;
		
		SELECT CONCAT('La información del estudiante ha sido actualizada correctamente.');
	END IF;
END //

DELIMITER ;

-- Prueba
/*SELECT * FROM estudiante;
CALL ActualizarInformacionEstudiante ('CC', '0001', 'Luis', 'Perez', 'luisestudiante@gmail.com');*/


-- 5) 
-- Procedimiento para buscar libros por autor

DELIMITER //

CREATE OR REPLACE PROCEDURE BuscarLibrosPorAutor(
	IN Autor VARCHAR(50)
)
BEGIN 
	DECLARE ErrorMessage VARCHAR(255);
    
   -- Manejo de cualquier excepción SQL
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      -- Deshacer la transacción si surge algún error
      ROLLBACK;
      -- Obtener el mensaje de error
      GET DIAGNOSTICS CONDITION 1 ErrorMessage = MESSAGE_TEXT;
      -- Devolver el mensaje de error
      SELECT CONCAT('ERROR: ', ErrorMessage) AS Error;
   END;
   
   START TRANSACTION;
   
   IF NOT EXISTS (SELECT 1 FROM libro AS l WHERE l.Autor = Autor) THEN
   	SET ErrorMessage = CONCAT('No se encontraron libros del autor ', Autor);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrorMessage;
	ELSE 
		
		SELECT l.Titulo, l.Genero, l.FechaPublicacion FROM libro AS l WHERE l.Autor = Autor;
		COMMIT;
	END IF;
END //

DELIMITER ;

-- Prueba
/*CALL BuscarLibrosPorAutor ('Gabriel García Márquez');*/


-- 6) Procedimiento con cursor
-- Procedimiento usando cursores para listar el nombre del profesor y los cursos que da

DELIMITER //

CREATE OR REPLACE PROCEDURE Cursor_Prof_Curso()
BEGIN
   DECLARE FirstName VARCHAR(50);
   DECLARE LastName VARCHAR(50);
   DECLARE CourseName VARCHAR(50);
   DECLARE done INT DEFAULT FALSE;
   DECLARE result_message TEXT DEFAULT '';

   -- Declare a cursor
    DECLARE course_Teacher CURSOR FOR
    SELECT p.Nombre, p.Apellido, c.Nombre
    FROM Profesor_Curso pc
    INNER JOIN Curso c ON c.ID_Curso = pc.ID_Curso
    INNER JOIN Profesor p ON p.ID_Profesor = pc.ID_Profesor AND p.TypeID_Profesor = pc.TypeID_Profesor
    GROUP BY p.Nombre, p.Apellido, c.Nombre;

    -- Declare a handler for when no more rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN course_Teacher;

    read_loop: LOOP
        FETCH course_Teacher INTO FirstName, LastName, CourseName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET result_message := CONCAT(result_message, '\nEl profesor es: ', FirstName, ' ', LastName, ' da el curso: ', CourseName);

    END LOOP;

    CLOSE course_Teacher;
    
    SELECT result_message AS output_message;
END //

DELIMITER ;

-- CALL Cursor_Prof_Curso();
