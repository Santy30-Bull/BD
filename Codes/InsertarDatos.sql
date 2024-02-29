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

INSERT INTO Sede(Localidad) values ('Envigado')

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

INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','001')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','002')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','003')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','004')
INSERT INTO Sede_Curso(ID_Sede, ID_Curso) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','005')

SELECT * FROM Sede_Curso

INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','CC','0000000000')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','CC','0000000001')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','CC','0000000002')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','CC','0000000003')
INSERT INTO Sede_Profesor(ID_Sede, TypeID_Profesor, ID_Profesor) values ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8','CC','0000000004')

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

INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','E8F0DEF7-405A-40A2-9BB5-10965F612F4F')
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','C76A663A-2591-49EE-8037-5E7F3092E70F')
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','195AC9AA-2836-49E6-BA9E-6FA9C111932C')
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','F91A1620-B1C5-4B00-8AFF-EF56E5D0886F')
INSERT INTO Biblioteca_Libro(ID_Biblioteca, ID_Libro) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','8A1B93E7-69A6-440D-8316-F655583F1C9D')

SELECT * FROM Biblioteca_Libro

INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','8D1D94F9-9185-4548-BF29-837E45145D51')
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','B5DAD608-C471-4C3C-92A8-A391443FCEE5')
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','C51BCFFD-AAEC-49A6-BE26-C52243358F6B')
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','B53B6050-1BB2-4872-A8F6-E169F9ABDC90')
INSERT INTO Biblioteca_Revista(ID_Biblioteca, ID_Revista) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','83D5546A-C3CC-4583-BA09-F9767EB3D619')

SELECT * FROM Biblioteca_Revista

INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','61C109D7-6BBC-4C80-8B04-05669154C7FA')
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','EB679F05-2763-47CD-B706-5F040BB33B55')
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','A1C0BEBE-A4EB-4DBF-B46F-734A49CBC8DC')
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','4573A2AF-A5CA-48C2-8527-A9DF4EE2DBBF')
INSERT INTO Biblioteca_Informe(ID_Biblioteca, ID_Informe) values ('CC4418CC-B858-495C-8EEB-4A937FA5FD34','C694D46C-07F2-4A4A-993D-C5A87EB6CB9C')

SELECT * FROM Biblioteca_Informe

INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('001', 'CC', '0000000000', 'CC', '0000000010')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('002', 'CC', '0000000001', 'CC', '0000000011')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('003', 'CC', '0000000002', 'CC', '0000000012')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('004', 'CC', '0000000004', 'CC', '0000000013')
INSERT INTO CursoProfesorEstudiante(ID_Curso, TypeID_Profesor, ID_Profesor, TypeID_EStudiante, ID_Estudiante) values ('005', 'CC', '0000000003', 'CC', '0000000014')

SELECT * FROM CursoProfesorEstudiante

INSERT INTO SedeBiblioteca(ID_Sede, ID_Biblioteca) VALUES ('EF5B69E2-C67D-41C5-911F-488D4E32A9C8', 'CC4418CC-B858-495C-8EEB-4A937FA5FD34');

SELECT * FROM SedeBiblioteca
