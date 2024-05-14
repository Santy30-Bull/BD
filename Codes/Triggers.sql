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

--3 Limitar la creación de las bases de datos sin la palabra ñ

CREATE OR ALTER TRIGGER ddl_trig_CaracterValido
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
    DECLARE @data XML;
    DECLARE @object SYSNAME;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME')

    IF @object LIKE '%ñ%'
    BEGIN
        RAISERROR ('No se permite crear tablas que contengan la letra "ñ".',16,1)
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


-- Trigger para eliminar profesor y almacenarlo en una tabla de histórico de profesores
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
	PRINT 'Se eliminó al profesor con tipo de id: ' +@TypeID + ' y ID: ' + @ID + ' de los profesores activos' ; 
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
        -- Verificar si ya existe un certificado para el mismo estudiante en el mismo curso
        IF NOT EXISTS (SELECT 1 FROM Certificado WHERE TypeID_Estudiante = @TypeID AND ID_Estudiante = @IDEstudiante AND ID_Curso = @IDCurso)
        BEGIN
            -- Insertar el nuevo certificado
            INSERT INTO Certificado VALUES (@TypeID, @IDEstudiante, @IDCurso, GETDATE());
            PRINT 'Se generó un certificado para el estudiante con tipo de documento: ' + @TypeID + ' y ID: ' + @IDEstudiante + ' en el curso con ID: ' + @IDCurso;
        END
        ELSE
        BEGIN
            -- Mostrar mensaje si el certificado ya existe
            PRINT 'El certificado para el estudiante con tipo de documento: ' + @TypeID + ' y ID: ' + @IDEstudiante + ' en el curso con ID: ' + @IDCurso + ' ya ha sido generado previamente.';
        END;
    END;
END;

SELECT * FROM Certificado

/*INSERT INTO Calificacion (TypeID_Estudiante, ID_Estudiante, ID_Curso, Porcentaje, Nota, Trabajo) 
VALUES ('TI', '0039', '026', 20, 4.2, 'Exposición');*/


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
        -- Lanzar un error si el mensaje supera el límite permitido
        RAISERROR('El anuncio que deseas enviar sobrepasa la cantidad de caracteres permitida, la cual es: %d', 16, 1, @Limite);

        -- Deshacer la transacción actual
        ROLLBACK TRANSACTION;
    END;
END;
