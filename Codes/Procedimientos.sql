USE Diplomados;

-- Procedimiento para inactivar a un profesor, es decir que deja de dar clases 
-- y no tiene cursos ni sede (Puede ser que salío de la institución y se mantiene como profesor pero no tiene ni cursos ni está asignado)
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
			
			-- Se quita la sede en las que está
			DELETE FROM Sede_Profesor WHERE TypeID_Profesor = @TypeIDProfesor AND ID_Profesor = @ID_Profesor;
			-- Se quita los cursos que tiene asignados
			DELETE FROM Profesor_Curso WHERE TypeID_Profesor = @TypeIDProfesor AND ID_Profesor = @ID_Profesor;

			PRINT 'Se han quitado los cursos y la sede al profesor con tipo de documento ' + @TypeIDProfesor + ' y ID ' + @ID_Profesor;
	END TRY
	BEGIN CATCH
		PRINT 'ERROR: ' + ERROR_MESSAGE();
	END CATCH
END
GO

SELECT * FROM Profesor_Curso;

EXECUTE InactivarProfesor 'IN', '0000000045';
