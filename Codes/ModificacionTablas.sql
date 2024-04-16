--Modificar tablas

USE Diplomados;

ALTER TABLE Libro
ALTER COLUMN Tipo VARCHAR(15) NOT NULL;

ALTER TABLE RevistaCientifica
ALTER COLUMN Tipo VARCHAR(15) NOT NULL;

ALTER TABLE RevistaCientifica
ALTER COLUMN Periocidad VARCHAR(15);

ALTER TABLE InformeInvestigacion
ALTER COLUMN Tipo VARCHAR(15) NOT NULL;

ALTER TABLE InformeInvestigacion
ALTER COLUMN Autor VARCHAR(40) NOT NULL;

ALTER TABLE InformeInvestigacion
ALTER COLUMN Tematica VARCHAR(40);

--Condicion Extra para los NEWIDS();
ALTER TABLE Sede
ADD Nombre_Sede VARCHAR(12);

ALTER TABLE Libro
ALTER COLUMN Autor VARCHAR(MAX) NOT NULL;

--Arreglar errores en isertarDatos
ALTER TABLE Libro
ALTER COLUMN Genero VARCHAR(MAX) NOT NULL;

ALTER TABLE RevistaCientifica
ALTER COLUMN Tematica VARCHAR(MAX) NOT NULL;

ALTER TABLE RevistaCientifica
ALTER COLUMN Titulo VARCHAR(MAX) NOT NULL;

ALTER TABLE InformeInvestigacion
ALTER COLUMN Titulo VARCHAR(MAX) NOT NULL;

go

CREATE OR ALTER TRIGGER TR_Calificacion_SumaPorcentajes
ON Calificacion
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @EstudianteTypeId VARCHAR(10);
    DECLARE @EstudianteId VARCHAR(15);
    DECLARE @CursoId VARCHAR(10);

    -- Iterar sobre cada calificación afectada por la operación de inserción o actualización
    DECLARE calificaciones_cursor CURSOR FOR
    SELECT DISTINCT C.TypeID_Estudiante, C.ID_Estudiante, C.ID_Curso
    FROM inserted AS C;

    OPEN calificaciones_cursor;
    FETCH NEXT FROM calificaciones_cursor INTO @EstudianteTypeId, @EstudianteId, @CursoId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar la suma de porcentajes para el estudiante actual en el curso actual
        IF EXISTS (
            SELECT 1
            FROM (
                SELECT SUM(Porcentaje) AS TotalPorcentaje
                FROM Calificacion AS C
                WHERE C.TypeID_Estudiante = @EstudianteTypeId AND C.ID_Estudiante = @EstudianteId AND C.ID_Curso = @CursoId
            ) AS Subquery
            WHERE TotalPorcentaje > 100
        )
        BEGIN
            RAISERROR ('La suma de porcentajes para el estudiante %s (TypeID: %s) en el curso %s no puede ser mayor que 100.', 16, 1, @EstudianteId, @EstudianteTypeId, @CursoId);
            ROLLBACK TRANSACTION;
        END

        -- Verificar si alguna nota está fuera del rango permitido para el estudiante actual
        IF EXISTS (
            SELECT 1
            FROM inserted AS C
            WHERE C.TypeID_Estudiante = @EstudianteTypeId AND C.ID_Estudiante = @EstudianteId AND C.ID_Curso = @CursoId AND (C.Nota < 0 OR C.Nota > 5.0)
        )
        BEGIN
            RAISERROR ('La nota para el estudiante %s (TypeID: %s) en el curso %s debe estar entre 0 y 5.0.', 16, 1, @EstudianteId, @EstudianteTypeId, @CursoId);
            ROLLBACK TRANSACTION;
        END

        FETCH NEXT FROM calificaciones_cursor INTO @EstudianteTypeId, @EstudianteId, @CursoId;
    END

    CLOSE calificaciones_cursor;
    DEALLOCATE calificaciones_cursor;
END;

go