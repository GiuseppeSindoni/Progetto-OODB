
CREATE OR REPLACE FUNCTION check_tipo_canale()
  RETURNS TRIGGER AS
$$
BEGIN
  IF NEW.tipocanale = 'Sito Online' THEN
    -- Imposta gli attributi della Libreria a NULL
    NEW.Indirizzo := NULL;
    NEW.NumeroTelefono := NULL;
    NEW.OrarioApertura := NULL;
    NEW.OrarioChiusura := NULL;
    
    -- Verifica che gli attributi del SitoOnline siano diversi da NULL
    IF NEW.URL IS NULL THEN
      RAISE EXCEPTION 'Gli attributi del Sito Online non possono essere NULL';
    END IF;
    
  ELSIF NEW.tipocanale = 'Libreria' THEN
    -- Imposta gli attributi del SitoOnline a NULL
    NEW.URL := NULL;
    
    -- Verifica che gli attributi della Libreria siano diversi da NULL
    IF NEW.NumeroTelefono IS NULL OR NEW.OrarioApertura IS NULL OR NEW.OrarioChiusura IS NULL OR NEW.Indirizzo IS NULL THEN
      RAISE EXCEPTION 'Gli attributi della Libreria non possono essere NULL';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER before_insert_canale
BEFORE INSERT ON CanaleDistribuzione
FOR EACH ROW
EXECUTE FUNCTION check_tipo_canale () ;



ALTER TABLE Libro
ADD CONSTRAINT CK_Libro_Serie CHECK (
    (Tipo = 'Didattico' AND Serie IS NULL) OR
    (Tipo <> 'Didattico')
);







CREATE OR REPLACE FUNCTION chk_libro()
RETURNS TRIGGER AS $$

BEGIN
IF (NOT EXISTS (
SELECT 1 FROM libro
WHERE libro.ISBN = NEW.ISBN
AND libro.ModalitaFruizione LIKE '%' || NEW.ModalitaFruizione || '%'
)) THEN
RAISE EXCEPTION 'La modalità di fruizione selezionata non è disponibile per il libro
selezionato.';

END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;



/*UN LIBRO NON PUO ESSERE DISPONIBILE SU UN SITO IN UN FORMATO PER CUI
NON ESISTE */
CREATE TRIGGER chk_DisponibilitaL
AFTER INSERT OR UPDATE ON DisponibilitaL
FOR EACH ROW
EXECUTE FUNCTION chk_libro();



/*UNA PUBBLICAZIONE NON PUO ESSERE ACQUISTATA IN UN FORMATO PER IL
QUALE NON ESISTE*/
CREATE OR REPLACE FUNCTION chk_pubblicazione()
RETURNS TRIGGER AS $$

BEGIN
IF (NOT EXISTS (
SELECT 1 FROM pubblicazione
WHERE pubblicazione.ISBN = NEW.ISBN
AND Pubblicazione.ModalitaFruizione LIKE '%' || New.ModalitaFruizione || '%'
)) THEN
RAISE EXCEPTION 'La modalità di fruizione selezionata non è disponibile per la pubblicazione selezionata.';

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;


/*UNA PUBBLICAZIONE NON PUO ESSERE DISPONIBILE IN UN
FORMATO PER IL QUALE NON ESISTE*/
CREATE TRIGGER chk_DisponibilitaP
AFTER INSERT OR UPDATE ON DisponibilitaP
FOR EACH ROW
EXECUTE FUNCTION chk_pubblicazione();



ALTER TABLE libro
ADD CONSTRAINT chk_tipo
CHECK (
    (tipo = 'Romanzo' AND Materia IS NULL AND Genere IS NOT NULL)
    OR (tipo = 'Didattico' AND Genere IS NULL AND Materia IS NOT NULL)
);



/*GESTIONE VINCOLO CONFERENZA/RIVISTA*/
ALTER TABLE Pubblicazione
ADD CONSTRAINT CK_RivistaConferenzaNotNull
CHECK (
   ( Conferenza IS NOT NULL AND Rivista IS NULL) OR
   ( Conferenza IS NULL AND Rivista IS NOT NULL) OR
    (Conferenza IS NULL AND Rivista IS NULL)
);


/* QUERY DEL GRUPPO DA 3*/
CREATE OR REPLACE FUNCTION trova_Librerie_Siti(utente_input int)
RETURNS TABLE (Nome VARCHAR(50), Cod int, Tipo tipo_canale) AS $$

BEGIN

    RETURN QUERY (
        SELECT cd.nome, cd.codCanale, cd.tipocanale
        FROM (
            SELECT pref.Serie, s.NumeroVolumi
            FROM preferiti pref
            JOIN serie s ON pref.Serie = s.CodSerie
            WHERE pref.Utente = utente_input
        ) AS v
        JOIN Libro AS l ON v.Serie = l.Serie
        JOIN disponibilitaL AS disp ON l.ISBN = disp.ISBN
        JOIN CanaleDistribuzione AS cd ON disp.Canale = cd.codCanale
        GROUP BY cd.Nome, cd.CodCanale, v.Serie, v.NumeroVolumi
        HAVING COUNT(*) = v.NumeroVolumi);
        

END;

$$ LANGUAGE plpgsql;






/* GESTIONE RINDONANZA NUMERO VOLUMI DI UNA SERIE*/
CREATE OR REPLACE FUNCTION aggiorna_num_volumi_inserimento()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.serie IS NOT NULL THEN
UPDATE serie
SET numerovolumi = numerovolumi + 1
WHERE CodSerie = NEW.serie;

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_aggiorna_num_volumi
BEFORE INSERT  ON libro
FOR EACH ROW
EXECUTE FUNCTION aggiorna_num_volumi_inserimento();

CREATE OR REPLACE FUNCTION aggiorna_num_volumi_cancellazione()
RETURNS TRIGGER AS $$
BEGIN
IF OLD.serie IS NOT NULL THEN
UPDATE serie
SET NumeroVolumi = NumeroVolumi - 1
WHERE CodSerie =OLD.serie;

END IF;
RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_aggiorna_num_volumi_cancellazione
BEFORE DELETE ON libro
FOR EACH ROW
EXECUTE FUNCTION aggiorna_num_volumi_cancellazione();

CREATE OR REPLACE FUNCTION set_NumeroVolumi_to_zero()
  RETURNS TRIGGER AS
$$
BEGIN
  IF NEW.NumeroVolumi <> 0 THEN
    NEW.NumeroVolumi := 0;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Creazione del trigger
CREATE TRIGGER trg_SetNumeroVolumiToZero
BEFORE INSERT ON serie
FOR EACH ROW
EXECUTE FUNCTION set_NumeroVolumi_to_zero();


