CREATE DATABASE Diplomados;

USE Diplomados;

CREATE TABLE Profesor (
  TypeID_Profesor VARCHAR(10),
  ID_Profesor VARCHAR(15),
  Nombre VARCHAR(20) NOT NULL,
  Apellido VARCHAR(20) NOT NULL,
  Email VARCHAR(40),
  PRIMARY KEY (TypeID_Profesor, ID_Profesor)
);

CREATE TABLE Curso (
  ID_Curso VARCHAR(10) PRIMARY KEY,
  Nombre VARCHAR(20) NOT NULL,
  FechaInicio DATE NOT NULL,
  FechaFinal DATE,
  Estado VARCHAR(10) NOT NULL
);

CREATE TABLE Estudiante (
  TypeID_Estudiante VARCHAR(10),
  ID_Estudiante VARCHAR(15),
  Nombre VARCHAR(20) NOT NULL,
  Apellido VARCHAR(20) NOT NULL,
  Email VARCHAR(40),
  PRIMARY KEY (TypeID_Estudiante, ID_Estudiante)
);

CREATE TABLE Biblioteca (
  ID_Biblioteca INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(20) NOT NULL
);

CREATE TABLE Libro (
  ID_Libro INT AUTO_INCREMENT PRIMARY KEY,
  Tipo VARCHAR(7) NOT NULL,
  Titulo VARCHAR(40) NOT NULL,
  Autor VARCHAR(20) NOT NULL,
  NoEjemplares INT,
  FechaPublicacion DATE,
  Genero VARCHAR(20) NOT NULL,
  NoPaginas INT
);

CREATE TABLE RevistaCientifica (
  ID_Revista INT AUTO_INCREMENT PRIMARY KEY,
  Tipo VARCHAR(7) NOT NULL,
  Titulo VARCHAR(40) NOT NULL,
  Autor VARCHAR(20) NOT NULL,
  NoEjemplares INT,
  FechaPublicacion DATE,
  Genero VARCHAR(20) NOT NULL,
  Tematica LONGTEXT NOT NULL,
  Periocidad VARCHAR(15)
);

CREATE TABLE InformeInvestigacion (
  ID_Informe INT AUTO_INCREMENT PRIMARY KEY,
  Tipo VARCHAR(7) NOT NULL,
  Titulo VARCHAR(40) NOT NULL,
  Autor VARCHAR(20) NOT NULL,
  NoEjemplares INT,
  FechaPublicacion DATE,
  Tematica VARCHAR(20) NOT NULL
);

CREATE TABLE Sede (
  ID_Sede CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  Localidad VARCHAR(50) NOT NULL,
  ID_Biblioteca INT,
  FOREIGN KEY (ID_Biblioteca) REFERENCES Biblioteca (ID_Biblioteca) ON DELETE CASCADE
);

CREATE TABLE Calificacion (
   ID_Calificacion INT AUTO_INCREMENT,
   ID_Estudiante VARCHAR(15),
   TypeID_Estudiante VARCHAR(10),
   ID_Curso VARCHAR(10),
   Porcentaje INT NOT NULL CHECK(Porcentaje > 0 AND Porcentaje <= 100),
	Fecha DATE,
	Nota FLOAT NOT NULL,
	Trabajo VARCHAR(15) NOT NULL,
   PRIMARY KEY(ID_Calificacion,ID_Estudiante,ID_Curso,TypeID_Estudiante),
   FOREIGN KEY (TypeID_Estudiante, ID_Estudiante) REFERENCES Estudiante (TypeID_Estudiante, ID_Estudiante) ON DELETE CASCADE,
	FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso) ON DELETE CASCADE
);

CREATE TABLE Certificado (
	TypeID_Estudiante VARCHAR(10),
	ID_Estudiante VARCHAR(15),
	ID_Curso VARCHAR(10),
	Fecha DATE NOT NULL, 
	PRIMARY KEY (TypeID_Estudiante,ID_Estudiante,ID_Curso),
	FOREIGN KEY (TypeID_Estudiante,ID_Estudiante) REFERENCES Estudiante (TypeID_Estudiante,ID_Estudiante),
	FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso)
);

CREATE TABLE Horarios (
	ID_Horario INT AUTO_INCREMENT,
	ID_Curso VARCHAR(10),
	Dia VARCHAR(10) NOT NULL,
	Hora VARCHAR(6) NOT NULL,
	PRIMARY KEY (ID_Horario,ID_Curso),
	FOREIGN KEY (ID_Curso) REFERENCES curso (ID_Curso) ON DELETE CASCADE 
);

CREATE TABLE Anuncios (
	ID_Anuncios INT AUTO_INCREMENT,
	ID_Curso VARCHAR(10),
	Fecha DATE NOT NULL, 
	Mensaje LONGTEXT NOT NULL, -- Cambio de VARCHAR(MAX) a LONGTEXT
	PRIMARY KEY (ID_Anuncios,ID_Curso),
	FOREIGN KEY (ID_Curso) REFERENCES curso (ID_Curso) ON DELETE CASCADE
);

CREATE TABLE Sede_Curso(
    ID_Sede VARCHAR(36),
    ID_Curso VARCHAR(10),
    PRIMARY KEY (ID_Sede,ID_Curso),
    FOREIGN KEY (ID_Sede) REFERENCES Sede (ID_Sede) ON DELETE CASCADE,
    FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso) ON DELETE CASCADE
);

CREATE TABLE Sede_Profesor(
	ID_Sede VARCHAR(36),
	TypeID_Profesor VARCHAR(10),
	ID_Profesor VARCHAR(15),
	PRIMARY KEY (ID_Sede, TypeID_Profesor, ID_Profesor),
	FOREIGN KEY (ID_Sede) REFERENCES sede (ID_Sede),
	FOREIGN KEY (TypeID_Profesor, ID_Profesor) REFERENCES Profesor (TypeID_Profesor, ID_Profesor) ON DELETE CASCADE
);

CREATE TABLE Profesor_Curso(
	TypeID_Profesor VARCHAR(10),
	ID_Profesor VARCHAR(15),
	ID_Curso VARCHAR(10),
	PRIMARY KEY (ID_Curso, TypeID_Profesor, ID_Profesor),
	FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso) ON DELETE CASCADE,
	FOREIGN KEY (TypeID_Profesor, ID_Profesor) REFERENCES Profesor (TypeID_Profesor, ID_Profesor) ON DELETE CASCADE
);

CREATE TABLE Curso_Estudiante(
	TypeID_Estudiante VARCHAR(10),
	ID_Estudiante VARCHAR(15),
	ID_Curso VARCHAR(10),
	PRIMARY KEY (ID_Curso, TypeID_Estudiante, ID_Estudiante),
	FOREIGN KEY (ID_Curso) REFERENCES Curso (ID_Curso) ON DELETE CASCADE,
	FOREIGN KEY (TypeID_Estudiante, ID_Estudiante) REFERENCES Estudiante (TypeID_Estudiante, ID_Estudiante) ON DELETE CASCADE
);

CREATE TABLE Biblioteca_Libro(
	ID_Biblioteca INT,
	ID_Libro INT,
	PRIMARY KEY (ID_Biblioteca, ID_Libro),
	FOREIGN KEY (ID_Biblioteca) REFERENCES Biblioteca (ID_Biblioteca) ON DELETE CASCADE,
	FOREIGN KEY (ID_Libro) REFERENCES Libro (ID_Libro) ON DELETE CASCADE
);

CREATE TABLE Biblioteca_Revista(
	ID_Biblioteca INT,
	ID_Revista INT,
	PRIMARY KEY (ID_Biblioteca, ID_Revista),
	FOREIGN KEY (ID_Biblioteca) REFERENCES Biblioteca (ID_Biblioteca) ON DELETE CASCADE,
	FOREIGN KEY (ID_Revista) REFERENCES RevistaCientifica(ID_Revista) ON DELETE CASCADE
);

CREATE TABLE Biblioteca_Informe(
	ID_Biblioteca INT,
	ID_Informe INT,
	PRIMARY KEY (ID_Biblioteca, ID_Informe),
	FOREIGN KEY (ID_Biblioteca) REFERENCES Biblioteca (ID_Biblioteca) ON DELETE CASCADE,
	FOREIGN KEY (ID_Informe) REFERENCES InformeInvestigacion(ID_Informe) ON DELETE CASCADE
);