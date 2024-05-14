USE Diplomados;

--Triggers DDL
--1. Guardar en una tabla las modificaciones realizadas a una tabla, quien las realizo, y fecha en la que se realizaron 

CREATE TABLE HistoricoModifaciones(
	HisMod INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ModTime DATETIME NOT NULL,
	DatabaseUser SYSNAME NOT NULL, 
	Event_log SYSNAME NOT NULL,
	Schema_log SYSNAME NOT NULL,
	Object_log SYSNAME NOT NULL,
	TSQL_log NVARCHAR(MAX) NOT NULL,
	XmlEvent XML NOT NULL);

CREATE OR ALTER TRIGGER ddl_trig_histoModif
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
	DECLARE @data XML;
	DECLARE @schema SYSNAME;
	DECLARE @object SYSNAME;
	DECLARE @eventType SYSNAME;
	DECLARE @user SYSNAME;
	SET @data = EVENTDATA();
	PRINT CONVERT(NVARCHAR(MAX),@data);
	SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'SYSNAME')
	SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'SYSNAME')
	SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME')
	SET @user = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'SYSNAME')
	INSERT INTO HistoricoModifaciones
	VALUES(
		GETDATE(),
		CONVERT(sysname, @user),
		@eventType,
		CONVERT(sysname, @schema),
		CONVERT(sysname, @object),
		@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
		@data);
END

SELECT * FROM HistoricoModifaciones

--2 No permitir que se borre la base de datos (Toro va a traficar con nuestros datos)

CREATE OR ALTER TRIGGER ddl_trig_Toro
ON ALL SERVER
FOR DROP_DATABASE
AS
BEGIN
	PRINT 'Toro por favor deja de borrar la base de datos'
	RAISERROR ('Mejor estudia administrativa',16,1)
	ROLLBACK TRANSACTION
END;

--3 Limitar la creaci�n de las bases de datos sin la palabra �

CREATE OR ALTER TRIGGER ddl_trig_CaracterValido
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
    DECLARE @data XML;
    DECLARE @object SYSNAME;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME')

    IF @object LIKE '%�%'
    BEGIN
        RAISERROR ('No se permite crear tablas que contengan la letra "�".',16,1)
        ROLLBACK TRANSACTION
    END
END;

--4 Historico de funciones

CREATE TABLE HistoricoFunciones(
    HisMod INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ModTime DATETIME NOT NULL,
    DatabaseUser SYSNAME NOT NULL, 
    Event_log SYSNAME NOT NULL,
    Schema_log SYSNAME NOT NULL,
    Object_log SYSNAME NOT NULL,
    TSQL_log NVARCHAR(MAX) NOT NULL,
    XmlEvent XML NOT NULL
)

CREATE OR ALTER TRIGGER ddl_trig_histoFunciones
ON DATABASE
FOR CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION
AS
BEGIN
    DECLARE @data XML;
    DECLARE @schema SYSNAME;
    DECLARE @object SYSNAME;
    DECLARE @eventType SYSNAME;
    DECLARE @user SYSNAME;
	DECLARE @functionType NVARCHAR(50);

    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'SYSNAME');
    SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'SYSNAME');
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME');
    SET @user = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'SYSNAME');

    INSERT INTO HistoricoFunciones
    VALUES(
        GETDATE(),
        CONVERT(sysname, @user),
        @eventType,
        CONVERT(sysname, @schema),
        CONVERT(sysname, @object),
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @data
    );
END;

--5 Historico de procedimientos

CREATE TABLE HistoricoProcedures(
	HisMod INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ModTime DATETIME NOT NULL,
	DatabaseUser SYSNAME NOT NULL, 
	Event_log SYSNAME NOT NULL,
	Schema_log SYSNAME NOT NULL,
	Object_log SYSNAME NOT NULL,
	TSQL_log NVARCHAR(MAX) NOT NULL,
	XmlEvent XML NOT NULL);

CREATE OR ALTER TRIGGER ddl_trig_histoProced
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
BEGIN
	DECLARE @data XML;
	DECLARE @schema SYSNAME;
	DECLARE @object SYSNAME;
	DECLARE @eventType SYSNAME;
	DECLARE @user SYSNAME;
	SET @data = EVENTDATA();
	PRINT CONVERT(NVARCHAR(MAX),@data);
	SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'SYSNAME')
	SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'SYSNAME')
	SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME')
	SET @user = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'SYSNAME')
	INSERT INTO HistoricoProcedures
	VALUES(
		GETDATE(),
		CONVERT(sysname, @user),
		@eventType,
		CONVERT(sysname, @schema),
		CONVERT(sysname, @object),
		@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
		@data);
END

--6 Trigger complejo
-- Trigger que captura los eventos DDL y realiza acciones adicionales
CREATE OR ALTER TRIGGER ddl_complex_trigger
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    -- Variables para almacenar informaci�n del evento
   -- Variables para almacenar informaci�n del evento
    DECLARE @data XML;
    DECLARE @eventType NVARCHAR(100);
    DECLARE @objectName NVARCHAR(100);

    -- Obtener los datos del evento
    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)');
    SET @objectName = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)');

    -- L�gica adicional basada en el tipo de evento
    IF @eventType = 'CREATE_TABLE'
    BEGIN
		DECLARE @columnsInfo NVARCHAR(MAX);
		SET @columnsInfo = (
			SELECT 
				 COLUMN_NAME + ' con el tipo de dato ' + DATA_TYPE + CHAR(13) + CHAR(10) AS ColumnInfo
			FROM 
				INFORMATION_SCHEMA.COLUMNS
			WHERE 
				TABLE_NAME = @objectName
			FOR XML PATH('')
		);

		SET @columnsInfo = REPLACE(@columnsInfo, '<ColumnInfo>', '');
		SET @columnsInfo = REPLACE(@columnsInfo, '</ColumnInfo>', '');
		SET @columnsInfo = REPLACE(@columnsInfo, '&#x0D', '');

		-- Imprimir el mensaje con el formato deseado
		PRINT '----------------------------------';
		PRINT 'Se ha creado la tabla ' + @objectName + ' con las siguientes columnas:';
		PRINT @columnsInfo;
		PRINT '----------------------------------';
	END

	IF @eventType = 'ALTER_TABLE'
	BEGIN
		DECLARE @action NVARCHAR(50);
        DECLARE @columnName NVARCHAR(100);

		-- Obtener el nombre de la columna modificada
		SET @columnName = (
			SELECT TOP 1
				COALESCE(
					@data.value('(/EVENT_INSTANCE/AlterTableActionList/Create/Columns/Name)[1]', 'NVARCHAR(100)'),
					@data.value('(/EVENT_INSTANCE/AlterTableActionList/Alter/Columns/Name)[1]', 'NVARCHAR(100)'),
					@data.value('(/EVENT_INSTANCE/AlterTableActionList/Drop/Columns/Name)[1]', 'NVARCHAR(100)')
				)
		);

        -- Obtener el tipo de acci�n
        SET @action = @data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');

		-- Mostrar el mensaje de modificaci�n
        PRINT '----------------------------------';
        PRINT 'Se ha modificado la tabla ' + @objectName + '. Cambios realizados:';

        IF @action LIKE '%ADD%'
        BEGIN
            PRINT 'Se ha a�adido la columna ' + @columnName;
        END
        ELSE IF @action LIKE '%ALTER COLUMN%'
        BEGIN
			DECLARE @lastSpacePosition INT = CHARINDEX(' ', REVERSE(@action));
			DECLARE @lastWord NVARCHAR(100) = RIGHT(@action, @lastSpacePosition - 1);
			PRINT 'Se ha modificado la columna ' + @columnName + ' a ' + @lastWord;
        END
        ELSE IF @action LIKE '%DROP COLUMN%'
        BEGIN
            PRINT 'Se ha eliminado la columna ' + @columnName;
        END

        PRINT '----------------------------------';
	END

    -- L�gica adicional para DROP_TABLE 
    IF @eventType = 'DROP_TABLE'
    BEGIN
        PRINT 'Se ha eliminado la tabla ' + @objectName + '.';
    END
END


/*CREATE TABLE TestTable (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100),
	Manin XML
);

DROP TABLE TestTable

ALTER TABLE TestTable ADD XMLColumn XML;

ALTER TABLE TestTable ALTER COLUMN XMLColumn NVARCHAR(255);

ALTER TABLE TestTable DROP COLUMN XMLColumn;

SELECT * FROM HistoricoModifaciones*/

-- Trigger para eliminar profesor y almacenarlo en una tabla de hist�rico de profesores
CREATE TABLE Profesor_Hist(
	TypeID VARCHAR(10) NOT NULL,
	ID VARCHAR(15) NOT NULL,
	DeleteDate DATETIME NOT NULL
)

CREATE OR ALTER TRIGGER dml_Del_Teacher
ON Profesor
AFTER DELETE AS
BEGIN
	DECLARE @TypeID VARCHAR(10);
	DECLARE @ID VARCHAR(15);
	SELECT TOP 1 @TypeID = TypeID_Profesor, @ID = ID_Profesor FROM DELETED;
	PRINT 'Se elimin� al profesor con tipo de id: ' +@TypeID + ' y ID: ' + @ID + ' de los profesores activos' ; 
	INSERT INTO Profesor_Hist VALUES (@TypeID, @ID, GETDATE());
END;


SELECT * FROM Profesor_Hist;


-- Trigger para no dejar borrar cursos
CREATE OR ALTER TRIGGER dml_NoDel_Curso
ON Curso
INSTEAD OF DELETE AS 
BEGIN
	SELECT 'No es posible eliminar el curso' AS MESSAGE
END;

SELECT * FROM Curso;

DELETE FROM Curso WHERE ID_Curso = 001;


-- Trigger para generar un certificado una vez las notas sean equivalentes al 100% y superior a 3
CREATE OR ALTER TRIGGER dml_CrearCertificado
ON Calificacion
AFTER UPDATE, INSERT AS 
BEGIN
	DECLARE @PorcentajeCalificado INT;
	DECLARE @Nota FLOAT;
	DECLARE @TypeID VARCHAR(10);
	DECLARE @IDEstudiante VARCHAR(15);
	DECLARE @IDCurso VARCHAR(10);
	SELECT TOP 1 
        @TypeID = i.TypeID_Estudiante,
        @IDEstudiante = i.ID_Estudiante,
        @IDCurso = i.ID_Curso
    FROM INSERTED i;

	SELECT 
		@PorcentajeCalificado = SUM(c.Porcentaje),
        @Nota = SUM(c.Nota * c.Porcentaje) / 100
	FROM Calificacion c WHERE @TypeID = c.TypeID_Estudiante AND @IDEstudiante = c.ID_Estudiante AND c.ID_Curso = @IDCurso

	IF (@PorcentajeCalificado = 100 AND @Nota >=3.0)
		BEGIN
			INSERT INTO Certificado VALUES (@TypeID, @IDEstudiante,  @IDCurso, GETDATE());
			PRINT 'Se gener� un certificado para el estudiante con tipo de documento: ' + @TypeID + ' y ID: ' + @IDEstudiante + ' en el curso con ID: ' + @IDCurso
		END;
END;

SELECT * FROM Certificado

/*INSERT INTO Calificacion (TypeID_Estudiante, ID_Estudiante, ID_Curso, Porcentaje, Nota, Trabajo) 
VALUES ('TI', '0039', '026', 20, 4.2, 'Exposici�n');*/


-- Trigger para limitar el largo del mensaje de anuncio
CREATE OR ALTER TRIGGER triggerAnuncioMensajeLargo
ON Anuncios
AFTER INSERT
AS
BEGIN
    DECLARE @Limite INT = 500;
    DECLARE @Mensaje VARCHAR(MAX);

    -- Obtener el mensaje del nuevo registro
    SELECT @Mensaje = Mensaje
    FROM inserted;

    -- Verificar la longitud del mensaje
    IF LEN(@Mensaje) > @Limite
    BEGIN
        -- Lanzar un error si el mensaje supera el l�mite permitido
        RAISERROR('El anuncio que deseas enviar sobrepasa la cantidad de caracteres permitida, la cual es: %d', 16, 1, @Limite);

        -- Deshacer la transacci�n actual
        ROLLBACK TRANSACTION;
    END;
END;
