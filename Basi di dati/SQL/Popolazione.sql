INSERT INTO Utente(Nome,Cognome,Username,Pwd)
values 
('Paolo','Tedesco','PaoloTed','CallOfDuty2019'), 
('Giulio','Pianese','GiulioP','Passwordjjs123'),
('Vitale','Agrillo','MaradonaVitale','ForzaNapol123'),('Giulio','Ruopolo','NeymarGiulio','MbappeLottin17'),
('Roberta','Beneduce','DajeRoma','SIuuuuum17'),('Nicolo','Vanacore','SalernoCapitale','ChampionsLeauge2003');

INSERT INTO Conferenza (DataInizio, DataFine, Luogo, Responsabile, StrutturaOrganizzatrice)
VALUES 
   ('2023-07-10', '2023-07-12', 'Londra, Regno Unito', 'Dr. Jane Smith', 'International Association of Scientific Publishers'),
   ('2023-09-05', '2023-09-07', 'New York, USA', 'Prof. John Johnson', 'Scientific Publishing Society'),
   ('2023-10-15', '2023-10-18', 'Parigi, Francia', 'Dr. Maria Garcia', 'European Society for Scientific Research'),
   ('2023-11-20', '2023-11-22', 'Tokyo, Giappone', 'Prof. Takeshi Yamamoto', 'Japan Association of Scientific Publishers'),
   ('2024-03-12', '2024-03-15', 'Berlino, Germania', 'Dr. Anna Müller', 'German Society for Scientific Advancement'),
   ('2024-05-01', '2024-05-03', 'San Francisco, USA', 'Prof. Robert Davis', 'American Academy of Scientific Research'),
   ('2024-06-20', '2024-06-22', 'Sydney, Australia', 'Dr. Sarah Thompson', 'Australian Association of Scientific Publishers'),
   ('2024-08-10', '2024-08-13', 'Mosca, Russia', 'Prof. Ivan Petrov', 'Russian Society for Scientific Advancement'),
   ('2024-09-25', '2024-09-27', 'Città del Messico, Messico', 'Dr. Alejandro Hernandez', 'Latin American Scientific Publishing Association'),
   ('2024-11-15', '2024-11-18', 'Pechino, Cina', 'Prof. Li Wei', 'Chinese Association of Scientific Publishers');

INSERT INTO Serie (Nome, NumeroVolumi)
VALUES 
   ('Le Cronache del Ghiaccio e del Fuoco', 0),
   ('Il Signore degli Anelli', 0),
   ('Commissario Montalbano', 0),
   ('Harry Potter', 0),
   ('L ispettore Coliandro', 0),
   ('La Divina Commedia', 0),
   ('Le inchieste del commissario Maigret', 0),
   ('Neapolitan Novels', 0),
   ('La trilogia dei mercanti', 0),
   ('La saga dei Cazalet', 0);

-- Inserimento righe per siti online
INSERT INTO CanaleDistribuzione (Nome, TipoCanale, URL, Indirizzo, NumeroTelefono, OrarioApertura, OrarioChiusura)
VALUES
  ('Amazon', 'Sito Online', 'http://www.amazon.com', NULL, NULL, NULL, NULL),
  ('EBay', 'Sito Online', 'http://www.ebay.com', NULL, NULL, NULL, NULL),
  ('IBS', 'Sito Online', 'http://www.ibs.com', NULL, NULL, NULL, NULL),
  ('La Feltrinelli', 'Sito Online', 'http://www.lafeltrinelli.com', NULL, NULL, NULL, NULL),
  ('Libreria Universitaria', 'Sito Online', 'http://www.libreriauniversitaria.com', NULL, NULL, NULL, NULL);
  
-- Inserimento righe per librerie
INSERT INTO CanaleDistribuzione (Nome, TipoCanale, URL, Indirizzo, NumeroTelefono, OrarioApertura, OrarioChiusura)
VALUES
  ('Acqua alta', 'Libreria','https://ciao' , 'Via Porricelli 1', '0123456789', '09:00:00', '18:00:00'),
  ('Luxemburg', 'Libreria', NULL, 'Via Del Cedro 2', '9876543210', '10:00:00', '19:00:00'),
  ('Palazzo Roberti', 'Libreria', NULL, 'Via Alfa 3', '1234567890', '08:30:00', '17:30:00'),
  ('Libreria del Viaggatore', 'Libreria', NULL, 'Via Borsellino 4', '0987654321', '09:30:00', '18:30:00'),
  ('Mondadori', 'Libreria', NULL, 'Via Eduardo de Filippo 5', '1112223333', '10:30:00', '19:30:00');




INSERT INTO Preferiti (Utente, Serie)
VALUES
   (1,1);


INSERT INTO Collana (Nome, Editore)
VALUES 
   ('Collana Fantasy', 'Mondadori'),
   ('Collana Gialli', 'Feltrinelli'),
   ('Collana Storica', 'Rizzoli'),
   ('Collana Romance', 'HarperCollins'),
   ('Collana Thriller', 'Newton Compton'),
   ('Collana Classici', 'Einaudi'),
   ('Collana Saggistica', 'Laterza'),
   ('Collana Horror', 'Piemme'),
   ('Collana Young Adult', 'Giunti'),
   ('Collana Poesia', 'Bompiani');

INSERT INTO Rivista (DOI, Nome, Argomento, AnnoPubblicazione, Responsabile)
VALUES 
   ('10.1001/123456', 'Nature', 'Medicina', 2021, 'Mario Rossi'),
   ('10.1002/234567', 'Le Scienze', 'Chimica', 2022, 'Matteo Ricci'),
   ('10.1003/345678', 'Annual Reviews', 'Informatica', 2020, 'Giulia Romano'),
   ('10.1004/456789', 'Frontiers in Neuroscience', 'Fisica', 2023, 'Chiara Moretti'),
   ('10.1005/567890', 'National Geographic ', 'Biologia', 2022, 'Alessandro Conti'),
   ('10.1006/678901', 'Plos One', 'Matematica', 2021, 'Davide Rizzo'),
   ('10.1007/789012', 'Journal of Kant ', 'Psicologia', 2020, 'Valentina De Luca'),
   ('10.1008/890123', 'Mind – Mente e cervello', 'Letteratura', 2023, 'Luca Rossi'),
   ('10.1009/901234', 'Economy is a opinion', 'Economia', 2022, 'Sofia Bianchi'),
   ('10.1010/012345', 'Storia e Storie', 'Storia', 2021, 'Sabrina Cirelli');

	   


INSERT INTO Pubblicazione (ISBN, Titolo, Editore, AnnoPubblicazione, ModalitaFruizione, Conferenza, Rivista)
VALUES 
   ('9788838945672', 'The Structure and Interpretation of the Computer', 'MIT Press', 2021, 'Cartaceo', 1, NULL),
   ('9788869876543', 'The Gene: An Intimate History', 'HarperCollins', 2022, 'Cartaceo', NULL, '10.1008/890123'),
   ('9788890123456', 'Sapiens: A Brief History of Humankind', 'Farrar, Straus and Giroux', 2020, 'Digitale', NULL, '10.1009/901234'),
   ('9788809801234', 'Thinking, Fast and Slow', 'Crown Publishing Group', 2023, 'Audiolibro', 2, NULL),
   ('9788845678901', 'The Immortal Life of Henrietta Lacks', 'Simon & Schuster', 2022, 'Cartaceo, Digitale, Audiolibro', 3, NULL),
   ('9788890987654', 'The Innovators: How a Group of Hackers', 'New World Library', 2021, 'Digitale', NULL, '10.1010/012345'),
   ('9788823456789', 'The Power of Now', 'Crown Publishing Group', 2020, 'Cartaceo', NULL, '10.1010/012345'),
   ('9788897654321', 'The Power of Introverts', 'Monadadori', 2023, 'Cartaceo, Audiolibro', 4, NULL),
   ('9788812345678', 'The Origin of Species', 'Feltrinelli', 2022, 'Digitale, Audiolibro', NULL, '10.1002/234567'),
   ('9788834567890', 'A Brief History of Time', 'Mondadori', 2021, 'Audiolibro', NULL, '10.1005/567890');


INSERT INTO Libro (ISBN, Titolo, Tipo, Editore, SalaPresentazione, DataUscita, Genere, Materia, AnnoPubblicazione, ModalitaFruizione, Serie)
VALUES 
   ('9788804668230', 'La ragazza della neve', 'Romanzo', 'Mondadori', 'Sala 1', '2020-03-10', 'Giallo', NULL, 2020, 'Cartaceo, Digitale', NULL),
   ('9788804668247', 'Il signore degli anelli', 'Romanzo', 'Bompiani', 'Sala 2', '1954-07-29', 'Fantasy', NULL, 1954, 'Digitale', 1),
   ('9788804668254', 'Educated', 'Romanzo', 'Giunti Editore', 'Sala 3', '2018-02-20', 'Biografia', NULL, 2018, 'Audiolibro', NULL),
   ('9788804668261', 'Il codice da Vinci', 'Romanzo', 'Mondadori', 'Sala 1', '2003-03-18', 'Thriller', NULL, 2003, 'Digitale', NULL),
   ('9788804668278', 'Harry Potter e la pietra filosofale', 'Romanzo', 'Salani Editore', 'Sala 2', '1997-06-26', 'Fantasy', NULL, 1997, 'Digitale', 1),
   ('9788804668285', '1984', 'Romanzo', 'Mondadori', 'Sala 3', '1949-06-08', 'Distopia', NULL, 1949, 'Digitale', NULL),
   ('9788804668292', 'Il nome della rosa', 'Romanzo', 'Bompiani', 'Sala 1', '1980-10-01', 'Giallo', NULL, 1980, 'Cartaceo, Audiolibro', NULL),
   ('9788804668308', 'Cinquanta sfumature di grigio', 'Romanzo', 'Mondadori', 'Sala 2', '2011-06-20', 'Erotico', NULL, 2011, 'Digitale', NULL),
   ('9788804668315', 'To Kill a Mockingbird', 'Didattico', 'Garzanti', 'Sala 3', '1960-07-11', NULL , 'Narrativa', 1960, 'Cartaceo', NULL),
   ('9788804668322', 'Matematica insieme', 'Didattico', 'Zanichelli', 'Sala 1', '1957-09-06', NULL, 'Matematica', 1957, 'Cartaceo,Digitale', NULL);
   
  INSERT INTO DisponibilitaP (ISBN, Canale, ModalitaFruizione)
VALUES ('9788838945672', 2, 'Cartaceo'),
       ('9788809801234', 2, 'Audiolibro'),
       ('9788897654321', 3, 'Audiolibro'),
       ('9788823456789', 4, 'Cartaceo'),
       ('9788845678901', 5, 'Cartaceo');



INSERT INTO DisponibilitaL (ISBN, Canale, ModalitaFruizione)
VALUES 
	   ('9788804668247', 2, 'Digitale'),
       ('9788804668278', 2, 'Digitale'),
	   ('9788804668247', 12, 'Digitale'),
       ('9788804668278', 12, 'Digitale');

