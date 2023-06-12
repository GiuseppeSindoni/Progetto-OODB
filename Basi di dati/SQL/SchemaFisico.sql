CREATE DOMAIN tipo_canale AS VARCHAR(20)
CHECK (VALUE IN ('Sito Online', 'Libreria'));

CREATE DOMAIN URL varchar(100)
CHECK (VALUE LIKE 'http://%' OR VALUE LIKE 'https://%' );


CREATE DOMAIN ISBN AS VARCHAR(17)
CHECK (VALUE ~ '^(97(8|9))?\d{9}(\d|X)$');

CREATE DOMAIN tipo_libro AS VARCHAR(10)
CHECK (VALUE IN ('Romanzo', 'Didattico'));


CREATE DOMAIN modalita_fruizione AS VARCHAR(10)
CHECK (VALUE IN ('Cartaceo', 'Digitale', 'Audiolibro'));


CREATE DOMAIN modalita_fruizione_libro AS VARCHAR(50)
CHECK (VALUE LIKE '%Cartaceo%' OR VALUE LIKE '%Digitale%' OR VALUE LIKE
'%Audiolibro%');

CREATE TABLE Conferenza(
	CodConferenza serial,
	DataInizio date NOT NULL,
	DataFine date NOT NULL,
	Luogo varchar(50) NOT NULL,
	Responsabile varchar(50) NOT NULL,
	StrutturaOrganizzatrice varchar(50) NOT NULL,
	
	CONSTRAINT Data_conferenza CHECK (DataInizio < DataFine),
	CONSTRAINT PK_Conferenza PRIMARY KEY (CodConferenza)
);

CREATE TABLE Serie(
	CodSerie serial,
	Nome varchar(50) NOT NULL,
	NumeroVolumi int  NOT NULL,
	
	CONSTRAINT PK_Serie PRIMARY KEY(CodSerie)
);


CREATE TABLE CanaleDistribuzione(
	CodCanale serial,
	Nome varchar(50) NOT NULL,
	TipoCanale tipo_canale NOT NULL,

	
	URL URL,

	Indirizzo varchar(50),
	NumeroTelefono varchar(11) ,
	OrarioApertura time,
	OrarioChiusura time,
	
	CONSTRAINT PK_canale_distribuzione PRIMARY KEY (CodCanale),
	CONSTRAINT orario_libreria CHECK (OrarioApertura < OrarioChiusura),
	CONSTRAINT CK_NumeroTelefono CHECK (NumeroTelefono ~ '^[0-9]+$')

);

CREATE TABLE Rivista(
	DOI varchar(100) NOT NULL ,
	Nome varchar(30) NOT NULL,
	Argomento varchar(50) NOT NULL,
	AnnoPubblicazione int NOT NULL,
	Responsabile varchar(30) NOT NULL,
	
	CONSTRAINT PK_Rivista PRIMARY KEY (DOI)
);

CREATE TABLE Utente (
	idUtente serial,
	Nome varchar(32) NOT NULL,
	Cognome varchar(32) NOT NULL,
	Username varchar(32) NOT NULL,
 	Pwd varchar(50) NOT NULL,
	
	
	CONSTRAINT PK_Utente PRIMARY KEY(idUtente),
	CONSTRAINT Username_Unique UNIQUE(Username),
	CONSTRAINT CK_Password CHECK (
   		 length(Pwd) >= 10 AND
    		 Pwd ~ '[0-9]' AND
   		 	Pwd ~ '[a-z]' AND
    		 Pwd ~ '[A-Z]'
)

	);

CREATE TABLE Preferiti(
	Utente int NOT NULL,
	Serie int NOT NULL,
	 
	CONSTRAINT PK_Preferiti PRIMARY KEY (Utente,Serie),
	CONSTRAINT FK_Preferiti_Utente FOREIGN KEY (Utente) REFERENCES Utente(idUtente),
	CONSTRAINT FK_Preferiti_Serie FOREIGN KEY (Serie) REFERENCES Serie(CodSerie)
);

CREATE TABLE Collana(
	CodCollana serial,
	Nome varchar(50) NOT NULL,
	Editore varchar(32) NOT NULL,
	
	CONSTRAINT PK_Collana PRIMARY KEY(CodCollana)
);

CREATE TABLE Pubblicazione (
	ISBN ISBN NOT NULL,
	Titolo varchar(50) NOT NULL,
	Editore varchar(32) NOT NULL,
	AnnoPubblicazione int NOT NULL,
	ModalitaFruizione modalita_fruizione_libro NOT NULL,
	Conferenza int,
	Rivista varchar(100),
	
	CONSTRAINT PK_Pubblicazione PRIMARY KEY(ISBN),
	CONSTRAINT FK_Pubblicazione_Conferenza FOREIGN KEY (Conferenza) REFERENCES Conferenza(CodConferenza),
	CONSTRAINT FK_Pubblicazione_Rivista FOREIGN KEY(Rivista) REFERENCES Rivista(DOI)
);





CREATE TABLE Libro (
	ISBN ISBN NOT NULL,
	Titolo varchar(50) NOT NULL,
	Tipo tipo_libro NOT NULL,
	Editore varchar(32) NOT NULL,
	SalaPresentazione varchar(32),
	DataUscita date NOT NULL,
	Genere varchar(50),
	Materia varchar(50),
	AnnoPubblicazione int  NOT NULL,
	ModalitaFruizione modalita_fruizione_libro NOT NULL,
	Serie int,
	
	CONSTRAINT PK_Libro PRIMARY KEY(ISBN),
	CONSTRAINT FK_Libro_Serie FOREIGN KEY(Serie) REFERENCES Serie(CodSerie));



CREATE TABLE DisponibilitaL(
	ISBN ISBN NOT NULL,
	Canale int NOT NULL ,
	ModalitaFruizione modalita_fruizione NOT NULL,
	
	 CONSTRAINT PK_DisponibilitaPL PRIMARY KEY (Canale, ISBN,ModalitaFruizione),
	CONSTRAINT FK_DispPL_Libreria FOREIGN KEY (Canale) REFERENCES CanaleDistribuzione(CodCanale),
	CONSTRAINT FK_DispPL_Pubblicazione FOREIGN KEY (ISBN) REFERENCES Libro(ISBN)
);

CREATE TABLE DisponibilitaP(
	ISBN ISBN NOT NULL,
	Canale int NOT NULL,
	ModalitaFruizione modalita_fruizione NOT NULL,
	
	CONSTRAINT PK_DisponibilitaLLibreria PRIMARY KEY (Canale, ISBN,ModalitaFruizione),
	CONSTRAINT FK_DispLL_Canale FOREIGN KEY (ISBN) REFERENCES Pubblicazione(ISBN),
	CONSTRAINT FK_DispLL_Libro FOREIGN KEY (Canale) REFERENCES CanaleDistribuzione (CodCanale)
);



CREATE TABLE Compone(
	ISBN ISBN NOT NULL,
	Collana int NOT NULL,
	
	CONSTRAINT PK_Compone PRIMARY KEY (ISBN,Collana),
	CONSTRAINT FK_Compone_Libro FOREIGN KEY (ISBN) REFERENCES Libro(ISBN),
	CONSTRAINT FK_Compone_Collana FOREIGN KEY (Collana) REFERENCES Collana(CodCollana)
);

