USE Diplomados

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

