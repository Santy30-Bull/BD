USE Diplomados;

ALTER TABLE Libro
MODIFY COLUMN Tipo VARCHAR(15) NOT NULL,
MODIFY COLUMN Genero LONGTEXT NOT NULL,
MODIFY COLUMN Autor LONGTEXT NOT NULL;

ALTER TABLE RevistaCientifica
MODIFY COLUMN Tipo VARCHAR(15) NOT NULL,
MODIFY COLUMN Titulo LONGTEXT NOT NULL;

ALTER TABLE InformeInvestigacion
MODIFY COLUMN Tipo VARCHAR(15) NOT NULL,
MODIFY COLUMN Autor VARCHAR(40) NOT NULL,
MODIFY COLUMN Tematica VARCHAR(40), 
MODIFY COLUMN Titulo LONGTEXT NOT NULL;

ALTER TABLE sede
ADD COLUMN Nombre_Sede VARCHAR(12);
