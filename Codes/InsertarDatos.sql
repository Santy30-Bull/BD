-- Insertar datos

USE Diplomados

INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000000', 'Elva', 'Nanin', 'elvaprofe@gmail.com')
INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000001', 'Elsa', 'Banero', 'elsaprofe@gmail.com')
INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000002', 'Alan', 'Brito', 'Alanprofe@gmail.com')
INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000003', 'Abigail', 'Mendoza', 'abigailprofe@gmail.com')
INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000004', 'Santiago', 'Torito', 'santiagoprofe@gmail.com')

SELECT * FROM Profesor

INSERT INTO Curso(ID_Curso, Nombre, FechaInicio, FechaFinal, Estado) values ('001', 'Estructuras de Datos', '2024-03-01', '2024-05-1', 'Activo')
INSERT INTO Curso(ID_Curso, Nombre, FechaInicio, FechaFinal, Estado) values ('002', 'Integral', '2024-03-01', '2024-05-1', 'Activo')
INSERT INTO Curso(ID_Curso, Nombre, FechaInicio, FechaFinal, Estado) values ('003', 'Diferencial', '2024-03-01', '2024-05-1', 'Activo')
INSERT INTO Curso(ID_Curso, Nombre, FechaInicio, FechaFinal, Estado) values ('004', 'Bases de Datos', '2025-03-01', '2025-05-1', 'Inactivo')
INSERT INTO Curso(ID_Curso, Nombre, FechaInicio, FechaFinal, Estado) values ('005', 'Karate', '2024-03-01', '2024-05-1', 'Activo')

SELECT * FROM Curso

INSERT INTO Estudiante(TypeID_Estudiante, ID_Estudiante, Nombre, Apellido, Email) VALUES ('CC', '0000000010', 'Luis', 'González', 'luisestudiante@gmail.com')
INSERT INTO Estudiante(TypeID_Estudiante, ID_Estudiante, Nombre, Apellido, Email) VALUES ('CC', '0000000011', 'Ana', 'Ramírez', 'anaestudiante@gmail.com')
INSERT INTO Estudiante(TypeID_Estudiante, ID_Estudiante, Nombre, Apellido, Email) VALUES ('CC', '0000000012', 'Carlos', 'Martínez', 'carlosestudiante@gmail.com')
INSERT INTO Estudiante(TypeID_Estudiante, ID_Estudiante, Nombre, Apellido, Email) VALUES ('CC', '0000000013', 'Julia', 'Vargas', 'juliaestudiante@gmail.com')
INSERT INTO Estudiante(TypeID_Estudiante, ID_Estudiante, Nombre, Apellido, Email) VALUES ('CC', '0000000014', 'Javier', 'Hernández', 'javierestudiante@gmail.com')

SELECT * FROM Estudiante

INSERT INTO Biblioteca(Nombre) values ('El Buho')

SELECT * FROM Biblioteca

INSERT INTO Libro(Tipo, Titulo, Autor, NoEjemplares, FechaPublicación, Genero, NoPaginas) values 
('Ficcion', 'El señor de los anillos', 'J.R.R. Tolkien', 100, '1954-07-29', 'Fantasía', 1170),
('Drama', 'Los miserables', 'Victor Hugo', 80, '1862-03-15', 'Clásico', 1488),
('Ciencia Ficción', 'Dune', 'Frank Herbert', 120, '1965-08-01', 'Ciencia Ficción', 896),
('Misterio', 'El código Da Vinci', 'Dan Brown', 90, '2003-03-18', 'Misterio', 593),
('Aventura', 'Las aventuras de Tom Sawyer', 'Mark Twain', 110, '1876-12-10', 'Aventura', 224);

SELECT * FROM Libro

INSERT INTO RevistaCientifica(Tipo, Titulo, Autor, NoEjemplares, FechaPublicación, Tematica, Periocidad) values 
('Científica', 'Avances en Física Cuántica', 'Dr. Juan Pérez', 50, '2024-01-15', 'Física Cuántica', 'Mensual'),
('Académica', 'Investigaciones Biológicas', 'Dra. María Rodríguez', 40, '2024-02-20', 'Biología', 'Bimensual'),
('Técnica', 'Innovaciones en Ingeniería Civil', 'Ing. Luis Gómez', 60, '2024-03-10', 'Ingeniería Civil', 'Trimestral'),
('Divulgativa', 'Ciencia para Todos', 'Dr. Ana Martínez', 70, '2024-04-05', 'Ciencia General', 'Mensual'),
('Especializada', 'Psicología Clínica Avanzada', 'Lic. Javier Sánchez', 30, '2024-05-12', 'Psicología Clínica', 'Semestral');

SELECT * FROM RevistaCientifica

INSERT INTO InformeInvestigacion(Tipo, Titulo, Autor, NoEjemplares, FechaPublicación, Tematica) values 
('Estudio', 'Impacto Ambiental en Zonas Urbanas', 'Dr. Carlos García', 25, '2024-01-05', 'Medio Ambiente'),
('Análisis', 'Tendencias Económicas Globales', 'Economista Laura Mendoza', 20, '2024-02-12', 'Economía'),
('Investigación', 'Avances en Inteligencia Artificial', 'Dr. Martín López', 30, '2024-03-20', 'Inteligencia Artificial'),
('Informe Técnico', 'Desarrollo de Nuevos Materiales', 'Ing. Patricia Torres', 15, '2024-04-08', 'Ciencia de Materiales'),
('Estudio de Caso', 'Impacto Social de las Redes Sociales', 'Lic. María González', 18, '2024-05-15', 'Sociología');

SELECT * FROM InformeInvestigacion

INSERT INTO Sede(Localidad,Nombre_Sede,ID_Biblioteca) values ('Envigado','Uni1',(SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'))

SELECT * FROM Sede

INSERT INTO Calificacion(TypeID_Estudiante,ID_Estudiante,ID_Curso,Porcentaje,Fecha,Nota,Trabajo) VALUES ('CC','0000000010','001',50,'2024-03-28',4.5,'Proyecto')
INSERT INTO Calificacion(TypeID_Estudiante,ID_Estudiante,ID_Curso,Porcentaje,Fecha,Nota,Trabajo) VALUES ('CC','0000000010','002',10,'2024-03-15',3.0,'Quiz')
INSERT INTO Calificacion(TypeID_Estudiante,ID_Estudiante,ID_Curso,Porcentaje,Fecha,Nota,Trabajo) VALUES ('CC','0000000010','003',10,'2024-04-02',4.0,'Quiz')
INSERT INTO Calificacion(TypeID_Estudiante,ID_Estudiante,ID_Curso,Porcentaje,Fecha,Nota,Trabajo) VALUES ('CC','0000000010','004',75,'2024-04-10',3.7,'Proyecto')
INSERT INTO Calificacion(TypeID_Estudiante,ID_Estudiante,ID_Curso,Porcentaje,Fecha,Nota,Trabajo) VALUES ('CC','0000000010','005',15,'2024-04-01',4.5,'Quiz')

SELECT * FROM Calificacion

INSERT INTO Certificado(TypeID_Estudiante, ID_Estudiante, ID_Curso, Fecha) values ('CC', '0000000012', '001', '2024-03-01')

SELECT * FROM Certificado

INSERT INTO Horarios(ID_Curso, Dia, Hora) values ('001', 'Jueves', '8:00')
INSERT INTO Horarios(ID_Curso, Dia, Hora) values ('002', 'Jueves', '10:00')
INSERT INTO Horarios(ID_Curso, Dia, Hora) values ('003', 'Jueves', '14:00')
INSERT INTO Horarios(ID_Curso, Dia, Hora) values ('004', 'Viernes', '15:00')

SELECT * FROM Horarios

INSERT INTO Anuncios(ID_Curso, Fecha, Mensaje) values ('001', '2024-02-28', 'Hola muchachos, mañana empezamos :)')
INSERT INTO Anuncios(ID_Curso, Fecha, Mensaje) values ('001', '2024-02-28', 'Hola muchachos, me caen mal')

SELECT * FROM Anuncios

INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'001')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'002')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'003')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'004')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'005')

SELECT * FROM Sede_Curso

INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'CC','0000000000')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'CC','0000000001')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'CC','0000000002')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'CC','0000000003')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'),'CC','0000000004')

SELECT * FROM Sede_Profesor

INSERT INTO Profesor_Curso(TypeID_Profesor, ID_Profesor, ID_Curso) values ('CC','0000000000','001')
INSERT INTO Profesor_Curso(TypeID_Profesor, ID_Profesor, ID_Curso) values ('CC','0000000001','002')
INSERT INTO Profesor_Curso(TypeID_Profesor, ID_Profesor, ID_Curso) values ('CC','0000000002','003')
INSERT INTO Profesor_Curso(TypeID_Profesor, ID_Profesor, ID_Curso) values ('CC','0000000003','005')
INSERT INTO Profesor_Curso(TypeID_Profesor, ID_Profesor, ID_Curso) values ('CC','0000000004','004')

SELECT * FROM Profesor_Curso

INSERT INTO Curso_Estudiante(TypeID_Estudiante, ID_Estudiante, ID_Curso) values ('CC', '0000000010', '001')
INSERT INTO Curso_Estudiante(TypeID_Estudiante, ID_Estudiante, ID_Curso) values ('CC', '0000000011', '002')
INSERT INTO Curso_Estudiante(TypeID_Estudiante, ID_Estudiante, ID_Curso) values ('CC', '0000000012', '003')
INSERT INTO Curso_Estudiante(TypeID_Estudiante, ID_Estudiante, ID_Curso) values ('CC', '0000000013', '004')
INSERT INTO Curso_Estudiante(TypeID_Estudiante, ID_Estudiante, ID_Curso) values ('CC', '0000000014', '005')

SELECT * FROM Curso_Estudiante

INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Libro FROM Libro where Titulo ='Dune'))
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Libro FROM Libro where Titulo ='Las aventuras de Tom Sawyer'))
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Libro FROM Libro where Titulo ='El código Da Vinci'))
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Libro FROM Libro where Titulo ='Los miserables'))
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Libro FROM Libro where Titulo ='El señor de los anillos'))

SELECT * FROM Biblioteca_Libro

INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Revista FROM RevistaCientifica where Titulo ='Psicología Clínica Avanzada'))
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Revista FROM RevistaCientifica where Titulo ='Investigaciones Biológicas'))
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Revista FROM RevistaCientifica where Titulo ='Ciencia para Todos'))
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Revista FROM RevistaCientifica where Titulo ='Avances en Física Cuántica'))
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Revista FROM RevistaCientifica where Titulo ='Innovaciones en Ingeniería Civil'))

SELECT * FROM Biblioteca_Revista

INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Informe FROM InformeInvestigacion where Titulo ='Impacto Ambiental en Zonas Urbanas'))
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Informe FROM InformeInvestigacion where Titulo ='Tendencias Económicas Globales'))
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Informe FROM InformeInvestigacion where Titulo ='Avances en Inteligencia Artificial'))
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Informe FROM InformeInvestigacion where Titulo ='Desarrollo de Nuevos Materiales'))
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ((SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'),(SELECT ID_Informe FROM InformeInvestigacion where Titulo ='Impacto Social de las Redes Sociales'))

SELECT * FROM Biblioteca_Informe

INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('001', 'CC', '0000000000', 'CC', '0000000010')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('002', 'CC', '0000000001', 'CC', '0000000011')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('003', 'CC', '0000000002', 'CC', '0000000012')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('004', 'CC', '0000000004', 'CC', '0000000013')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('005', 'CC', '0000000003', 'CC', '0000000014')

SELECT * FROM CursoProfesorEstudiante

INSERT INTO SedeBiblioteca(ID_Sede, ID_Biblioteca) VALUES ((SELECT ID_Sede FROM Sede where Nombre_Sede ='Uni1'), (SELECT ID_Biblioteca FROM Biblioteca where Nombre ='El Buho'));

SELECT * FROM SedeBiblioteca


--Cositas bonitas
DELETE FROM Profesor WHERE ID_Profesor='0000000003'
INSERT INTO Profesor(TypeID_Profesor, ID_Profesor, Nombre, Apellido, Email) values ('CC', '0000000003', 'Abigail', 'Mendoza', 'abigailprofe@gmail.com')
UPDATE Profesor SET Email='toronolesabes@gmail.com' WHERE ID_Profesor='0000000004' 
INSERT INTO Calificacion(TypeID_Estudiante, ID_Estudiante, ID_Curso, Porcentaje, Nota, Trabajo) values ('CC', '0000000012', '002',15, 3.5, 'EvaluacionIsis')
UPDATE Calificacion SET Fecha='3 am' WHERE Trabajo = 'EvaluacionIsis'