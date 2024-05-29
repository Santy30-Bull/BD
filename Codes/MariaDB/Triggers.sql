USE DIPLOMADOS 

-- Para habilitar el programador de eventos en MySQL o MariaDB
SET GLOBAL event_scheduler = ON;

-- Permisos
GRANT ALL PRIVILEGES ON DIPLOMADOS.* TO 'root'@'localhost';
FLUSH PRIVILEGES;

/*
SHOW BINARY LOGS

SET GLOBAL binlog_format = 'ROW';

SHOW BINLOG EVENTS IN 'mysql-bin.000001'*/

-- Triggers DDL
-- 1. Guardar en una tabla las modificaciones realizadas a una tabla, quien las realizo, y fecha en la que se realizaron

CREATE TABLE HistoricoModificaciones(
	HisMod INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	ModTime DATETIME NOT NULL,
	DatabaseUser NVARCHAR(128) NOT NULL,
	Event_log NVARCHAR(128) NOT NULL,
	Schema_log NVARCHAR(128) NOT NULL,
	Object_log NVARCHAR(128) NOT NULL
);

-- Procedimiento almacenado para verificar nuevas tablas y registrarlas en el historial
DELIMITER $$
CREATE OR REPLACE PROCEDURE CheckNewTables()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName NVARCHAR(128);
    DECLARE columnsInfo TEXT;
    DECLARE cur CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = 'DIPLOMADOS';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM HistoricoModificaciones WHERE Object_log = tableName AND Event_log = 'Tabla creada') THEN
            -- Insertar en la tabla de historial
            INSERT INTO HistoricoModificaciones(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
            VALUES (NOW(), CURRENT_USER(), 'Tabla creada', 'DIPLOMADOS', tableName);

            -- Obtener información de las columnas de la tabla creada
				SELECT GROUP_CONCAT(CONCAT(COLUMN_NAME, ' con el tipo de dato ', DATA_TYPE) SEPARATOR '; \n') INTO columnsInfo
				FROM information_schema.columns
				WHERE table_name = tableName AND table_schema = 'DIPLOMADOS';


            -- Imprimir información de la tabla creada
            SELECT CONCAT(
				    '----------------------------------\n',
				    'Se ha creado la tabla ', tableName, ' con las siguientes columnas:\n',
				    columnsInfo, '\n',
				    '----------------------------------'
				) AS message;
        END IF;
    END LOOP;

    CLOSE cur;
END$$
DELIMITER ;

DELIMITER $$

CREATE OR REPLACE PROCEDURE CheckTableDrop()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName NVARCHAR(128);
    DECLARE cur CURSOR FOR SELECT Object_log FROM HistoricoModificaciones WHERE Event_log = 'Tabla creada';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'DIPLOMADOS' AND table_name = tableName) THEN
            -- Insertar en la tabla de historial
            INSERT INTO HistoricoModificaciones(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
            VALUES (NOW(), CURRENT_USER(), 'Tabla eliminada', 'DIPLOMADOS', tableName);

            -- Imprimir información de la eliminación
            SELECT CONCAT('----------------------------------\nSe ha eliminado la tabla ', tableName, '\n----------------------------------') AS message;
        END IF;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- Crear un evento programado para llamar al procedimiento cada hora
DELIMITER $$
CREATE EVENT CheckTablesEvent
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    CALL CheckNewTables();
    CALL CheckTableDrop();
END$$
DELIMITER ;

-- 2 Mensaje a Toro cuando se borre la base de datos
DELIMITER //

CREATE EVENT ddl_event_Toro
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DECLARE db_name VARCHAR(255);
    SET db_name = (SELECT DATABASE());

    IF db_name = 'database_a_borrar' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Toro por favor deja de borrar la base de datos';
    END IF;
END//

DELIMITER ;

-- 3 Limitar la creación de las tablas a palabras sin ñ

DELIMITER //

CREATE OR REPLACE PROCEDURE EliminarTablasConEnie()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName NVARCHAR(128);
    DECLARE cur CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = 'DIPLOMADOS';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF LOCATE('ñ', tableName) > 0 THEN
            -- Eliminar registros asociados en HistoricoModificaciones
            DELETE FROM HistoricoModificaciones WHERE Object_log = tableName;

            -- Eliminar la tabla
            SET @dropStatement = CONCAT('DROP TABLE IF EXISTS DIPLOMADOS.', tableName);
            PREPARE stmt FROM @dropStatement;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            -- Imprimir mensaje
            SELECT 'No se pueden usar tablas con la letra "ñ" porque los recuentos no tienen sentido.' AS message;
        END IF;
    END LOOP;

    CLOSE cur;
END;
//

DELIMITER ;

-- Crear el evento
DELIMITER //

CREATE EVENT EliminarTablasConEnie_Event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL EliminarTablasConEnie();
END//

DELIMITER ;

-- Crear una tabla de ejemplo con la letra "ñ"
CREATE TABLE IF NOT EXISTS `DIPLOMADOS`.`tabla_con_ñ` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(50)
);

-- 4 Historico de funciones
CREATE TABLE HistoricoFunciones(
	HisMod INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	ModTime DATETIME NOT NULL,
	DatabaseUser NVARCHAR(128) NOT NULL,
	Event_log NVARCHAR(128) NOT NULL,
	Schema_log NVARCHAR(128) NOT NULL,
	Object_log NVARCHAR(128) NOT NULL
);

-- Procedimiento almacenado para verificar nuevas funciones y registrarlas en el historial
	DELIMITER //
	
	CREATE OR REPLACE PROCEDURE CheckNewFunctions()
	BEGIN
	    DECLARE done INT DEFAULT 0;
	    DECLARE functionName NVARCHAR(128);
	    DECLARE columnsInfo TEXT;
	    DECLARE cur CURSOR FOR SELECT routine_name FROM information_schema.routines WHERE routine_type = 'FUNCTION' AND routine_schema = 'DIPLOMADOS';
	    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	    OPEN cur;
	
	    read_loop: LOOP
	        FETCH cur INTO functionName;
	        IF done THEN
	            LEAVE read_loop;
	        END IF;
	
	        IF NOT EXISTS (SELECT 1 FROM HistoricoFunciones WHERE Object_log = functionName AND Event_log = 'Función creada') THEN
	            -- Insertar en la tabla de historial
	            INSERT INTO HistoricoFunciones(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
	            VALUES (NOW(), CURRENT_USER(), 'Función creada', 'DIPLOMADOS', functionName);
	
	            -- Imprimir mensaje de información
	            SELECT CONCAT(
	                '----------------------------------\n',
	                'Se ha creado la función ', functionName, '\n',
	                '----------------------------------'
	            ) AS message;
	        END IF;
	    END LOOP;
	
	    CLOSE cur;
	END//
	
	DELIMITER ;

DELIMITER $$

CREATE OR REPLACE PROCEDURE CheckDeletedFunctions()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE functionName NVARCHAR(128);
    DECLARE cur CURSOR FOR SELECT Object_log FROM HistoricoFunciones WHERE Event_log = 'Función creada';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO functionName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'DIPLOMADOS' AND routine_name = functionName AND routine_type = 'FUNCTION') THEN
            -- Insertar en la tabla de historial
            INSERT INTO HistoricoFunciones(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
            VALUES (NOW(), CURRENT_USER(), 'Función eliminada', 'DIPLOMADOS', functionName);

            -- Imprimir información de la eliminación
            SELECT CONCAT('----------------------------------\nSe ha eliminado la función ', functionName, '\n----------------------------------') AS message;
        END IF;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

DELIMITER $$

CREATE EVENT CheckFunctionsHourly
ON SCHEDULE
    EVERY 1 HOUR
    STARTS CURRENT_TIMESTAMP
DO
    BEGIN
        CALL CheckNewFunctions();
        CALL CheckDeletedFunctions();
    END$$

DELIMITER ;

-- Crear una función de prueba
DELIMITER //

CREATE OR REPLACE FUNCTION DIPLOMADOS.TestFunction() RETURNS INT
DETERMINISTIC
BEGIN
    RETURN 1;
END//

DELIMITER ;

-- Eliminar dicha función de prueba
DROP FUNCTION TestFunction

-- 5 Histórico de procedimientos
CREATE TABLE HistoricoProcedures(
	HisMod INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	ModTime DATETIME NOT NULL,
	DatabaseUser NVARCHAR(128) NOT NULL,
	Event_log NVARCHAR(128) NOT NULL,
	Schema_log NVARCHAR(128) NOT NULL,
	Object_log NVARCHAR(128) NOT NULL
);

-- Procedimiento almacenado para verificar nuevos procedimientos y registrarlos en el historial
	DELIMITER //
	
	CREATE OR REPLACE PROCEDURE CheckNewProcedures()
	BEGIN
	    DECLARE done INT DEFAULT 0;
	    DECLARE procedureName NVARCHAR(128);
	    DECLARE columnsInfo TEXT;
	    DECLARE cur CURSOR FOR SELECT routine_name FROM information_schema.routines WHERE routine_type = 'PROCEDURE' AND routine_schema = 'DIPLOMADOS';
	    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	    OPEN cur;
	
	    read_loop: LOOP
	        FETCH cur INTO procedureName;
	        IF done THEN
	            LEAVE read_loop;
	        END IF;
	
	        IF NOT EXISTS (SELECT 1 FROM HistoricoProcedures WHERE Object_log = procedureName AND Event_log = 'Procedimiento creado') THEN
	            -- Insertar en la tabla de historial
	            INSERT INTO HistoricoProcedures(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
	            VALUES (NOW(), CURRENT_USER(), 'Procedimiento creado', 'DIPLOMADOS', procedureName);
	
	            -- Imprimir mensaje de información
	            SELECT CONCAT(
	                '----------------------------------\n',
	                'Se ha creado el procedimiento ', procedureName, '\n',
	                '----------------------------------'
	            ) AS message;
	        END IF;
	    END LOOP;
	
	    CLOSE cur;
	END//
	
	DELIMITER ;
	
DELIMITER $$

CREATE OR REPLACE PROCEDURE CheckDeletedProcedures()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE procedureName NVARCHAR(128);
    DECLARE cur CURSOR FOR SELECT Object_log FROM HistoricoProcedures WHERE Event_log = 'Procedimiento creado';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO procedureName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_schema = 'DIPLOMADOS' AND routine_name = procedureName AND routine_type = 'PROCEDURE') THEN
            -- Insertar en la tabla de historial
            INSERT INTO HistoricoProcedures(ModTime, DatabaseUser, Event_log, Schema_log, Object_log)
            VALUES (NOW(), CURRENT_USER(), 'Procedimiento eliminado', 'DIPLOMADOS', procedureName);

            -- Imprimir información de la eliminación
            SELECT CONCAT('----------------------------------\nSe ha eliminado el procedimiento ', procedureName, '\n----------------------------------') AS message;
        END IF;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

DELIMITER $$

CREATE EVENT CheckProceduresHourly
ON SCHEDULE
    EVERY 1 HOUR
    STARTS CURRENT_TIMESTAMP
DO
    BEGIN
        CALL CheckNewProcedures();
        CALL CheckDeletedProcedures();
    END$$

DELIMITER ;

-- Triggers DML

-- Trigger para eliminar profesor y almacenarlo en una tabla de histórico de profesores
CREATE TABLE Profesor_Hist(
	TypeID VARCHAR(10) NOT NULL,
	ID VARCHAR(15) NOT NULL,
	DeleteDate DATETIME NOT NULL
)

DELIMITER //

CREATE OR REPLACE TRIGGER dml_Del_Teacher
AFTER DELETE ON Profesor
FOR EACH ROW
BEGIN
    DECLARE TypeID VARCHAR(10);
    DECLARE ID VARCHAR(15);

    -- Asignar valores de la fila eliminada a las variables
    SET TypeID = OLD.TypeID_Profesor;
    SET ID = OLD.ID_Profesor;

    -- Insertar los datos en la tabla de historial
    INSERT INTO Profesor_Hist (TypeID, ID, DeleteDate) VALUES (TypeID, ID, NOW());
END//

DELIMITER ;

-- Trigger para no dejar borrar los cursos
DELIMITER //

CREATE OR REPLACE TRIGGER dml_NoDel_Curso
BEFORE DELETE ON Curso
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No es posible eliminar el curso';
END//

DELIMITER ;

SELECT * FROM Curso;

DELETE FROM Curso WHERE ID_Curso = 001;

-- Trigger para generar un certificado una vez las notas sean equivalentes al 100% y superior a 3
DELIMITER //

CREATE OR REPLACE PROCEDURE calcularCertificado(
    IN TypeID VARCHAR(10),
    IN IDEstudiante VARCHAR(15),
    IN IDCurso VARCHAR(10)
)
BEGIN
    DECLARE PorcentajeCalificado INT DEFAULT 0;
    DECLARE NotaFinal FLOAT DEFAULT 0;
    DECLARE message VARCHAR(255);

    -- Calcular el porcentaje y la nota
    SELECT SUM(Porcentaje) INTO PorcentajeCalificado
    FROM Calificacion
    WHERE TypeID_Estudiante = TypeID AND ID_Estudiante = IDEstudiante AND ID_Curso = IDCurso;

    -- Corregir el cálculo de la nota
    SELECT SUM(Nota * Porcentaje) / 100 INTO NotaFinal
    FROM Calificacion
    WHERE TypeID_Estudiante = TypeID AND ID_Estudiante = IDEstudiante AND ID_Curso = IDCurso;

    IF (PorcentajeCalificado = 100 AND NotaFinal >= 3) THEN
        -- Verificar si ya existe un certificado
        IF NOT EXISTS (SELECT 1 FROM Certificado WHERE TypeID_Estudiante = TypeID AND ID_Estudiante = IDEstudiante AND ID_Curso = IDCurso) THEN
            -- Insertar el nuevo certificado
            INSERT INTO Certificado (TypeID_Estudiante, ID_Estudiante, ID_Curso, Fecha) 
            VALUES (TypeID, IDEstudiante, IDCurso, NOW());
        END IF;
    END IF;
END//

DELIMITER ;


DELIMITER //

CREATE OR REPLACE TRIGGER dml_CrearCertificadoUpdate
AFTER UPDATE ON Calificacion
FOR EACH ROW
BEGIN
    CALL calcularCertificado(NEW.TypeID_Estudiante, NEW.ID_Estudiante, NEW.ID_Curso);
END//

DELIMITER ;

DELIMITER //

CREATE OR REPLACE TRIGGER dml_CrearCertificadoInsert
AFTER INSERT ON Calificacion
FOR EACH ROW
BEGIN
    CALL calcularCertificado(NEW.TypeID_Estudiante, NEW.ID_Estudiante, NEW.ID_Curso);
END//

DELIMITER ;

-- Esta calificación cumple con los requisitos para insertar un certificado a este estudiante
INSERT INTO Calificacion (TypeID_Estudiante, ID_Estudiante, ID_Curso, Porcentaje, Fecha, Nota, Trabajo) 
VALUES ('TI', '0039', '026', 20, NOW(), 4.2, 'Exposición');

-- Trigger para limitar el largo del mensaje de anuncio
DELIMITER //

CREATE OR REPLACE TRIGGER triggerAnuncioMensajeLargo
AFTER INSERT ON Anuncios
FOR EACH ROW
BEGIN
    DECLARE Limite INT DEFAULT 500;
    DECLARE Mensaje TEXT;

    -- Obtener el mensaje del nuevo registro
    SET Mensaje = NEW.Mensaje;

    -- Verificar la longitud del mensaje
    IF CHAR_LENGTH(Mensaje) > Limite THEN
        -- Lanzar un error si el mensaje supera el límite permitido
        SET Mensaje = CONCAT('El anuncio que deseas enviar sobrepasa la cantidad de caracteres permitida, la cual es: ', Limite);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Mensaje;
    END IF;
END //

DELIMITER ;

INSERT INTO Anuncios (ID_Curso, Fecha, Mensaje) VALUES ('026', '2024-05-30', 'Este es un mensaje de prueba que excede el límite de caracteres. 
Repetiré este mensaje varias veces para que supere el límite. Este es un mensaje de prueba que excede el límite de caracteres. 
Repetiré este mensaje varias veces para que supere el límite. Este es un mensaje de prueba que excede el límite de caracteres. 
Repetiré este mensaje varias veces para que supere el límite. Este es un mensaje de prueba que excede el límite de caracteres. 
Repetiré este mensaje varias veces para que supere el límite. Este es un mensaje de prueba que excede el límite de caracteres. 
Repetiré este mensaje varias veces para que supere el límite.');

-- Trigger para que las notas ingresadas sean valores de 0 a 5, y los porcentajes no sumen mas de 100 
DELIMITER //

CREATE OR REPLACE PROCEDURE CalificacionValida(
    IN TipoEstudianteId VARCHAR(10),
    IN EstudianteId VARCHAR(15),
    IN CursoId VARCHAR(10),
    IN Porcentaje INT,
    IN Fecha DATE,
    IN Nota FLOAT,
    IN Trabajo VARCHAR(255)
)
BEGIN
    DECLARE TotalPorcentaje INT;
    DECLARE Mensaje TEXT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_EstudianteTypeId VARCHAR(10);
    DECLARE v_EstudianteId VARCHAR(15);
    DECLARE v_CursoId VARCHAR(10);

    DECLARE cur CURSOR FOR
        SELECT TypeID_Estudiante, ID_Estudiante, ID_Curso
        FROM Calificacion
        WHERE TypeID_Estudiante = TipoEstudianteId AND ID_Estudiante = EstudianteId AND ID_Curso = CursoId;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_EstudianteTypeId, v_EstudianteId, v_CursoId;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calculamos la suma de los porcentajes excluyendo la fila actual
        SELECT SUM(Porcentaje) INTO TotalPorcentaje
        FROM Calificacion
        WHERE TypeID_Estudiante = v_EstudianteTypeId AND ID_Estudiante = v_EstudianteId AND ID_Curso = v_CursoId;

        -- Si la suma de porcentajes más el porcentaje actual es mayor que 100, lanzamos una excepción
        IF TotalPorcentaje + Porcentaje > 100 THEN
            SET Mensaje = CONCAT('La suma de porcentajes para el estudiante ', v_EstudianteId, ' (TypeID: ', v_EstudianteTypeId, ') en el curso ', v_CursoId, ' no puede ser mayor que 100.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Mensaje;
        END IF;

        -- Si la nota está fuera del rango especificado, lanzamos una excepción
        IF Nota < 0 OR Nota > 5.0 THEN
            SET Mensaje = CONCAT('La nota para el estudiante ', v_EstudianteId, ' (TypeID: ', v_EstudianteTypeId, ') en el curso ', v_CursoId, ' debe estar entre 0 y 5.0.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Mensaje;
        END IF;
    END LOOP;

    CLOSE cur;

    -- Verificamos si la nota es válida antes de insertar o actualizar
    IF Nota < 0 OR Nota > 5.0 THEN
        SET Mensaje = CONCAT('La nota debe estar entre 0 y 5.0.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Mensaje;
    END IF;

    -- Insertamos o actualizamos la calificación si pasa todas las validaciones
    IF Porcentaje + TotalPorcentaje <= 100 THEN
        IF EXISTS (SELECT * FROM Calificacion WHERE ID_Estudiante = EstudianteId AND TypeID_Estudiante = TipoEstudianteId AND ID_Curso = CursoId) THEN
            UPDATE Calificacion
            SET Porcentaje = Porcentaje,
                Fecha = Fecha,
                Nota = Nota,
                Trabajo = Trabajo
            WHERE ID_Estudiante = EstudianteId AND TypeID_Estudiante = TipoEstudianteId AND ID_Curso = CursoId;
        ELSE
            INSERT INTO Calificacion (TypeID_Estudiante, ID_Estudiante, ID_Curso, Porcentaje, Fecha, Nota, Trabajo)
            VALUES (TipoEstudianteId, EstudianteId, CursoId, Porcentaje, Fecha, Nota, Trabajo);
        END IF;
    ELSE
        SET Mensaje = CONCAT('La suma de porcentajes no puede ser mayor que 100.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Mensaje;
    END IF;

END //

DELIMITER ;


DELIMITER //

CREATE OR REPLACE TRIGGER Trigger_Calificacion_Valida_Insert
BEFORE INSERT ON Calificacion
FOR EACH ROW
BEGIN
    CALL CalificacionValida(
        NEW.TypeID_Estudiante,
        NEW.ID_Estudiante,
        NEW.ID_Curso,
        NEW.Porcentaje,
        NEW.Fecha,
        NEW.Nota,
        NEW.Trabajo
    );
END//

CREATE OR REPLACE TRIGGER Trigger_Calificacion_Valida_Update
BEFORE UPDATE ON Calificacion
FOR EACH ROW
BEGIN
    CALL CalificacionValida(
        NEW.TypeID_Estudiante,
        NEW.ID_Estudiante,
        NEW.ID_Curso,
        NEW.Porcentaje,
        NEW.Fecha,
        NEW.Nota,
        NEW.Trabajo
    );
END//

DELIMITER ;
