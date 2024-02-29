--Modificar tablas

USE Diplomados;

CREATE TABLE CursoProfesorEstudiante(
	ID_Curso Varchar(10) PRIMARY KEY,
    TypeID_Profesor Varchar(10),
    ID_Profesor Varchar(15),
	TypeID_EStudiante Varchar(10),
    ID_Estudiante Varchar(15),
	CONSTRAINT FK__CursoProfesorEstudiante__Curso FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso),
	CONSTRAINT FK__CursoProfesorEstudiante__Profesor FOREIGN KEY (TypeID_Profesor, ID_Profesor) REFERENCES Profesor (TypeID_Profesor, ID_Profesor),
	CONSTRAINT FK__CursoProfesorEstudiante__Estudiante FOREIGN KEY (TypeID_Estudiante, ID_Estudiante) REFERENCES Estudiante (TypeID_Estudiante, ID_Estudiante),
)	
--Tabla redundante, no necesaria, ya que calificacion tiene a estudiante y a curso
/*CREATE TABLE EstudianteCalificacion(
	ID_Calificacion  INT IDENTITY(1, 1),
    TypeID_Estudiante VARCHAR(10),
    ID_Estudiante VARCHAR(15),
	ID_Curso VARCHAR(10), 
    PRIMARY KEY (TypeID_Estudiante, ID_Estudiante, ID_Calificacion),
    CONSTRAINT FK__EstudianteCalificacion__Calificacion 
        FOREIGN KEY (ID_Calificacion, TypeID_Estudiante, ID_Estudiante,	ID_Curso) 
        REFERENCES Calificacion (ID_Calificacion, TypeID_Estudiante, ID_Estudiante, ID_Curso)
);*/

CREATE TABLE SedeBiblioteca(
	ID_Sede UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	ID_Biblioteca UNIQUEIDENTIFIER DEFAULT NEWID(),
	CONSTRAINT FK_SedeCursoBiblioteca_Sede FOREIGN KEY (ID_Sede) REFERENCES Sede (ID_Sede),
	CONSTRAINT FK_SedeCursoBiblioteca_Biblioteca FOREIGN KEY (ID_Biblioteca) REFERENCES Biblioteca (ID_Biblioteca)
);

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
