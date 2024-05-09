USE Diplomados;

-- 1)
-- Procedimiento para inactivar a un profesor, es decir que deja de dar clases 
-- y no tiene cursos ni sede (Puede ser que sal�o de la instituci�n y se mantiene como profesor pero no tiene ni cursos ni est� asignado)
CREATE OR ALTER PROCEDURE InactivarProfesor
	@TypeIDProfesor VARCHAR(10),
	@ID_Profesor VARCHAR(15)
AS 
BEGIN
	-- Se trata que el tipo de ID y el ID correspondan con el de un profesor inscrito en la base de datos
	BEGIN TRY 
		IF NOT EXISTS (SELECT 1 FROM Profesor p WHERE p.TypeID_Profesor = @TypeIDProfesor AND p.ID_Profesor = @ID_Profesor)
			BEGIN
				RAISERROR ('El profesor con tipo de documento %d y ID %d no existe', 16, 1, @TypeIDProfesor, @ID_Profesor);
				RETURN;
			END
			
			-- Se quita la sede en las que est�
			DELETE FROM Sede_Profesor WHERE TypeID_Profesor = @TypeIDProfesor AND ID_Profesor = @ID_Profesor;
			-- Se quita los cursos que tiene asignados
			DELETE FROM Profesor_Curso WHERE TypeID_Profesor = @TypeIDProfesor AND ID_Profesor = @ID_Profesor;
			-- Se elimina al profesor de la base de datos
			DELETE FROM Profesor WHERE TypeID_Profesor = @TypeIDProfesor AND ID_Profesor = @ID_Profesor;

			PRINT 'Se han quitado los cursos y la sede al profesor con tipo de documento ' + @TypeIDProfesor + ' y ID ' + @ID_Profesor;
	END TRY
	BEGIN CATCH
		PRINT 'ERROR: ' + ERROR_MESSAGE();
	END CATCH
END

SELECT * FROM Profesor_Curso;
EXECUTE InactivarProfesor 'IN', '0000000044';

-- 2)
/* Procedimiento que permita agregar un nuevo estudiante a un curso específico*/
CREATE or ALTER PROCEDURE AgregarEstudianteACurso
    @TypeID_Estudiante VARCHAR(10),
    @ID_Estudiante VARCHAR(15),
    @ID_Curso VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si el estudiante ya está inscrito en el curso
        IF EXISTS (SELECT 1 FROM Curso_Estudiante WHERE TypeID_Estudiante = @TypeID_Estudiante AND ID_Estudiante = @ID_Estudiante AND ID_Curso = @ID_Curso)
        BEGIN
            RAISERROR('El estudiante ya está inscrito en este curso.', 16, 1);
        END
        ELSE
        BEGIN
            -- Insertar el estudiante en el curso
            INSERT INTO Curso_Estudiante (TypeID_Estudiante, ID_Estudiante, ID_Curso)
            VALUES (@TypeID_Estudiante, @ID_Estudiante, @ID_Curso);
            PRINT 'El estudiante ha sido inscrito en el curso ' + @ID_Curso +  ' exitosamente.';
        END
    END TRY
    BEGIN CATCH
        -- Manejar el error
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT 
            @ErrorMessage = ERROR_MESSAGE();
        -- Mensaje de error
        PRINT 'Error: ' + @ErrorMessage;
    END CATCH;
END
SELECT * FROM Curso_Estudiante;
EXECUTE AgregarEstudianteACurso 'CC', '0001', '001'; --Probar el mensaje de error
EXECUTE AgregarEstudianteACurso 'CC', '0001', '002'; --Probar la inserción exitosa

-- 3)
/* Procedimiento que permita agregar un nuevo libro a la base de datos*/
CREATE or ALTER PROCEDURE agregarLibro(
    @Tipo VARCHAR(7),
    @Titulo VARCHAR(40),
    @Autor VARCHAR(20),
    @NoEjemplares INT,
    @FechaPublicacion DATE,
    @Genero VARCHAR(20),
    @NoPaginas INT
)
AS
BEGIN
    -- Verificar si ya existe un libro con el mismo título y autor
    IF EXISTS (
        SELECT 1
        FROM Libro
        WHERE Titulo = @Titulo AND Autor = @Autor
    )
    BEGIN
        -- Si ya existe un libro con el mismo título y autor, imprimir mensaje y retornar
        PRINT 'El libro con el mismo título y autor ya se encuentra en la base de datos.';
        RETURN;
    END

    -- Insertar un nuevo libro si no hay conflicto de título y autor
    INSERT INTO Libro (Tipo, Titulo, Autor, NoEjemplares, FechaPublicacion, Genero, NoPaginas)
    VALUES (@Tipo, @Titulo, @Autor, @NoEjemplares, @FechaPublicacion, @Genero, @NoPaginas);

    -- Indicar que el libro se agregó exitosamente
    PRINT 'Libro agregado exitosamente.';
END

SELECT * FROM Libro
WHERE Titulo = 'El principito'
Execute agregarLibro 'Fisico', 'El principito', 'Antoine de Saint-Exupéry', 10, '1943-04-06', 'Fábula', 96;

CREATE OR ALTER PROCEDURE Isis AS
BEGIN
	DECLARE @FirstName NVARCHAR(50);
	DECLARE @LastName NVARCHAR(50);
	DECLARE @CourseName NVARCHAR(50);

	DECLARE course_Teacher CURSOR FOR
	SELECT p.Nombre, p.Apellido, c.Nombre
	FROM Profesor_Curso pc
	INNER JOIN Curso c ON c.ID_Curso = pc.ID_Curso
	INNER JOIN Profesor p ON p.ID_Profesor = pc.ID_Profesor AND p.TypeID_Profesor = pc.TypeID_Profesor
	GROUP BY p.Nombre, p.Apellido, c.Nombre;

	OPEN course_Teacher;
	FETCH NEXT FROM course_Teacher INTO @FirstName, @LastName, @CourseName;

	WHILE @@FETCH_STATUS = 0
	BEGIN	
		PRINT 'El profesor es: ' + @FirstName + ' ' + @LastName + ' da el curso: ' + @CourseName;
		FETCH NEXT FROM course_Teacher INTO @FirstName, @LastName, @CourseName;
	END;
	CLOSE course_Teacher;
	DEALLOCATE course_Teacher;
END;
GO
EXEC Isis
SELECT * FROM Profesor_Curso