PGDMP         ;                {           biblioteca_digitale    15.2    15.2 Z    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    18082    biblioteca_digitale    DATABASE     �   CREATE DATABASE biblioteca_digitale WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Italian_Italy.1252';
 #   DROP DATABASE biblioteca_digitale;
                postgres    false            y           1247    18153    isbn    DOMAIN     �   CREATE DOMAIN public.isbn AS character varying(17)
	CONSTRAINT isbn_check CHECK (((VALUE)::text ~ '^(97(8|9))?\d{9}(\d|X)$'::text));
    DROP DOMAIN public.isbn;
       public          postgres    false            �           1247    18191    modalita_fruizione    DOMAIN     �   CREATE DOMAIN public.modalita_fruizione AS character varying(10)
	CONSTRAINT modalita_fruizione_check CHECK (((VALUE)::text = ANY ((ARRAY['Cartaceo'::character varying, 'Digitale'::character varying, 'Audiolibro'::character varying])::text[])));
 '   DROP DOMAIN public.modalita_fruizione;
       public          postgres    false            }           1247    18156    modalita_fruizione_libro    DOMAIN     �   CREATE DOMAIN public.modalita_fruizione_libro AS character varying(50)
	CONSTRAINT modalita_fruizione_libro_check CHECK ((((VALUE)::text ~~ '%Cartaceo%'::text) OR ((VALUE)::text ~~ '%Digitale%'::text) OR ((VALUE)::text ~~ '%Audiolibro%'::text)));
 -   DROP DOMAIN public.modalita_fruizione_libro;
       public          postgres    false            b           1247    18099    tipo_canale    DOMAIN     �   CREATE DOMAIN public.tipo_canale AS character varying(20)
	CONSTRAINT tipo_canale_check CHECK (((VALUE)::text = ANY ((ARRAY['Sito Online'::character varying, 'Libreria'::character varying])::text[])));
     DROP DOMAIN public.tipo_canale;
       public          postgres    false            �           1247    18176 
   tipo_libro    DOMAIN     �   CREATE DOMAIN public.tipo_libro AS character varying(10)
	CONSTRAINT tipo_libro_check CHECK (((VALUE)::text = ANY ((ARRAY['Romanzo'::character varying, 'Didattico'::character varying])::text[])));
    DROP DOMAIN public.tipo_libro;
       public          postgres    false            f           1247    18102    url    DOMAIN     �   CREATE DOMAIN public.url AS character varying(100)
	CONSTRAINT url_check CHECK ((((VALUE)::text ~~ 'http://%'::text) OR ((VALUE)::text ~~ 'https://%'::text)));
    DROP DOMAIN public.url;
       public          postgres    false            �            1255    18260 #   aggiorna_num_volumi_cancellazione()    FUNCTION     �   CREATE FUNCTION public.aggiorna_num_volumi_cancellazione() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF OLD.serie IS NOT NULL THEN
UPDATE serie
SET NumeroVolumi = NumeroVolumi - 1
WHERE CodSerie = OLD.serie;

END IF;
RETURN OLD;
END;
$$;
 :   DROP FUNCTION public.aggiorna_num_volumi_cancellazione();
       public          postgres    false            �            1255    18258 !   aggiorna_num_volumi_inserimento()    FUNCTION     �   CREATE FUNCTION public.aggiorna_num_volumi_inserimento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.serie IS NOT NULL THEN
UPDATE serie
SET numerovolumi = numerovolumi + 1
WHERE CodSerie = NEW.serie;

END IF;
RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.aggiorna_num_volumi_inserimento();
       public          postgres    false            �            1255    18244    check_tipo_canale()    FUNCTION     �  CREATE FUNCTION public.check_tipo_canale() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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

$$;
 *   DROP FUNCTION public.check_tipo_canale();
       public          postgres    false            �            1255    18248    chk_libro()    FUNCTION     l  CREATE FUNCTION public.chk_libro() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

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
$$;
 "   DROP FUNCTION public.chk_libro();
       public          postgres    false            �            1255    18250    chk_pubblicazione()    FUNCTION     �  CREATE FUNCTION public.chk_pubblicazione() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

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
$$;
 *   DROP FUNCTION public.chk_pubblicazione();
       public          postgres    false            �            1255    18262    set_numerovolumi_to_zero()    FUNCTION     �   CREATE FUNCTION public.set_numerovolumi_to_zero() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.NumeroVolumi <> 0 THEN
    NEW.NumeroVolumi := 0;
  END IF;
  RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.set_numerovolumi_to_zero();
       public          postgres    false            �            1255    18282    trova_librerie_siti(integer)    FUNCTION     �  CREATE FUNCTION public.trova_librerie_siti(utente_input integer) RETURNS TABLE(nome character varying, cod integer, tipo public.tipo_canale)
    LANGUAGE plpgsql
    AS $$

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

$$;
 @   DROP FUNCTION public.trova_librerie_siti(utente_input integer);
       public          postgres    false    866            �            1259    18105    canaledistribuzione    TABLE     �  CREATE TABLE public.canaledistribuzione (
    codcanale integer NOT NULL,
    nome character varying(50) NOT NULL,
    tipocanale public.tipo_canale NOT NULL,
    url public.url,
    indirizzo character varying(50),
    numerotelefono character varying(11),
    orarioapertura time without time zone,
    orariochiusura time without time zone,
    CONSTRAINT ck_numerotelefono CHECK (((numerotelefono)::text ~ '^[0-9]+$'::text)),
    CONSTRAINT orario_libreria CHECK ((orarioapertura < orariochiusura))
);
 '   DROP TABLE public.canaledistribuzione;
       public         heap    postgres    false    866    870            �            1259    18104 !   canaledistribuzione_codcanale_seq    SEQUENCE     �   CREATE SEQUENCE public.canaledistribuzione_codcanale_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.canaledistribuzione_codcanale_seq;
       public          postgres    false    219            �           0    0 !   canaledistribuzione_codcanale_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.canaledistribuzione_codcanale_seq OWNED BY public.canaledistribuzione.codcanale;
          public          postgres    false    218            �            1259    18146    collana    TABLE     �   CREATE TABLE public.collana (
    codcollana integer NOT NULL,
    nome character varying(50) NOT NULL,
    editore character varying(32) NOT NULL
);
    DROP TABLE public.collana;
       public         heap    postgres    false            �            1259    18145    collana_codcollana_seq    SEQUENCE     �   CREATE SEQUENCE public.collana_codcollana_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.collana_codcollana_seq;
       public          postgres    false    225            �           0    0    collana_codcollana_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.collana_codcollana_seq OWNED BY public.collana.codcollana;
          public          postgres    false    224            �            1259    18227    compone    TABLE     ]   CREATE TABLE public.compone (
    isbn public.isbn NOT NULL,
    collana integer NOT NULL
);
    DROP TABLE public.compone;
       public         heap    postgres    false    889            �            1259    18084 
   conferenza    TABLE     X  CREATE TABLE public.conferenza (
    codconferenza integer NOT NULL,
    datainizio date NOT NULL,
    datafine date NOT NULL,
    luogo character varying(50) NOT NULL,
    responsabile character varying(50) NOT NULL,
    strutturaorganizzatrice character varying(50) NOT NULL,
    CONSTRAINT data_conferenza CHECK ((datainizio < datafine))
);
    DROP TABLE public.conferenza;
       public         heap    postgres    false            �            1259    18083    conferenza_codconferenza_seq    SEQUENCE     �   CREATE SEQUENCE public.conferenza_codconferenza_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.conferenza_codconferenza_seq;
       public          postgres    false    215            �           0    0    conferenza_codconferenza_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.conferenza_codconferenza_seq OWNED BY public.conferenza.codconferenza;
          public          postgres    false    214            �            1259    18264    disponibilital    TABLE     �   CREATE TABLE public.disponibilital (
    isbn public.isbn NOT NULL,
    canale integer NOT NULL,
    modalitafruizione public.modalita_fruizione NOT NULL
);
 "   DROP TABLE public.disponibilital;
       public         heap    postgres    false    907    889            �            1259    18210    disponibilitap    TABLE     �   CREATE TABLE public.disponibilitap (
    isbn public.isbn NOT NULL,
    canale integer NOT NULL,
    modalitafruizione public.modalita_fruizione NOT NULL
);
 "   DROP TABLE public.disponibilitap;
       public         heap    postgres    false    907    889            �            1259    18178    libro    TABLE     �  CREATE TABLE public.libro (
    isbn public.isbn NOT NULL,
    titolo character varying(50) NOT NULL,
    tipo public.tipo_libro NOT NULL,
    editore character varying(32) NOT NULL,
    salapresentazione character varying(32),
    datauscita date NOT NULL,
    genere character varying(50),
    materia character varying(50),
    annopubblicazione integer NOT NULL,
    modalitafruizione public.modalita_fruizione_libro NOT NULL,
    serie integer,
    CONSTRAINT chk_tipo CHECK (((((tipo)::text = 'Romanzo'::text) AND (materia IS NULL) AND (genere IS NOT NULL)) OR (((tipo)::text = 'Didattico'::text) AND (genere IS NULL) AND (materia IS NOT NULL)) OR ((tipo)::text <> ALL ((ARRAY['Romanzo'::character varying, 'Didattico'::character varying])::text[])))),
    CONSTRAINT ck_libro_serie CHECK (((((tipo)::text = 'Didattico'::text) AND (serie IS NULL)) OR ((tipo)::text <> 'Didattico'::text)))
);
    DROP TABLE public.libro;
       public         heap    postgres    false    889    893    900            �            1259    18130 	   preferiti    TABLE     [   CREATE TABLE public.preferiti (
    utente integer NOT NULL,
    serie integer NOT NULL
);
    DROP TABLE public.preferiti;
       public         heap    postgres    false            �            1259    18158    pubblicazione    TABLE     �  CREATE TABLE public.pubblicazione (
    isbn public.isbn NOT NULL,
    titolo character varying(50) NOT NULL,
    editore character varying(32) NOT NULL,
    annopubblicazione integer NOT NULL,
    modalitafruizione public.modalita_fruizione_libro NOT NULL,
    conferenza integer,
    rivista character varying(100),
    CONSTRAINT ck_rivistaconferenzanotnull CHECK ((((conferenza IS NOT NULL) AND (rivista IS NULL)) OR ((conferenza IS NULL) AND (rivista IS NOT NULL))))
);
 !   DROP TABLE public.pubblicazione;
       public         heap    postgres    false    889    893            �            1259    18115    rivista    TABLE     �   CREATE TABLE public.rivista (
    doi character varying(100) NOT NULL,
    nome character varying(30) NOT NULL,
    argomento character varying(50) NOT NULL,
    annopubblicazione integer NOT NULL,
    responsabile character varying(30) NOT NULL
);
    DROP TABLE public.rivista;
       public         heap    postgres    false            �            1259    18092    serie    TABLE     �   CREATE TABLE public.serie (
    codserie integer NOT NULL,
    nome character varying(50) NOT NULL,
    numerovolumi integer NOT NULL
);
    DROP TABLE public.serie;
       public         heap    postgres    false            �            1259    18091    serie_codserie_seq    SEQUENCE     �   CREATE SEQUENCE public.serie_codserie_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.serie_codserie_seq;
       public          postgres    false    217            �           0    0    serie_codserie_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.serie_codserie_seq OWNED BY public.serie.codserie;
          public          postgres    false    216            �            1259    18121    utente    TABLE     �  CREATE TABLE public.utente (
    idutente integer NOT NULL,
    nome character varying(32) NOT NULL,
    cognome character varying(32) NOT NULL,
    username character varying(32) NOT NULL,
    pwd character varying(50) NOT NULL,
    CONSTRAINT ck_password CHECK (((length((pwd)::text) >= 10) AND ((pwd)::text ~ '[0-9]'::text) AND ((pwd)::text ~ '[a-z]'::text) AND ((pwd)::text ~ '[A-Z]'::text)))
);
    DROP TABLE public.utente;
       public         heap    postgres    false            �            1259    18120    utente_idutente_seq    SEQUENCE     �   CREATE SEQUENCE public.utente_idutente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.utente_idutente_seq;
       public          postgres    false    222            �           0    0    utente_idutente_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.utente_idutente_seq OWNED BY public.utente.idutente;
          public          postgres    false    221            �           2604    18108    canaledistribuzione codcanale    DEFAULT     �   ALTER TABLE ONLY public.canaledistribuzione ALTER COLUMN codcanale SET DEFAULT nextval('public.canaledistribuzione_codcanale_seq'::regclass);
 L   ALTER TABLE public.canaledistribuzione ALTER COLUMN codcanale DROP DEFAULT;
       public          postgres    false    218    219    219            �           2604    18149    collana codcollana    DEFAULT     x   ALTER TABLE ONLY public.collana ALTER COLUMN codcollana SET DEFAULT nextval('public.collana_codcollana_seq'::regclass);
 A   ALTER TABLE public.collana ALTER COLUMN codcollana DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    18087    conferenza codconferenza    DEFAULT     �   ALTER TABLE ONLY public.conferenza ALTER COLUMN codconferenza SET DEFAULT nextval('public.conferenza_codconferenza_seq'::regclass);
 G   ALTER TABLE public.conferenza ALTER COLUMN codconferenza DROP DEFAULT;
       public          postgres    false    215    214    215            �           2604    18095    serie codserie    DEFAULT     p   ALTER TABLE ONLY public.serie ALTER COLUMN codserie SET DEFAULT nextval('public.serie_codserie_seq'::regclass);
 =   ALTER TABLE public.serie ALTER COLUMN codserie DROP DEFAULT;
       public          postgres    false    216    217    217            �           2604    18124    utente idutente    DEFAULT     r   ALTER TABLE ONLY public.utente ALTER COLUMN idutente SET DEFAULT nextval('public.utente_idutente_seq'::regclass);
 >   ALTER TABLE public.utente ALTER COLUMN idutente DROP DEFAULT;
       public          postgres    false    221    222    222            }          0    18105    canaledistribuzione 
   TABLE DATA           �   COPY public.canaledistribuzione (codcanale, nome, tipocanale, url, indirizzo, numerotelefono, orarioapertura, orariochiusura) FROM stdin;
    public          postgres    false    219   �~       �          0    18146    collana 
   TABLE DATA           <   COPY public.collana (codcollana, nome, editore) FROM stdin;
    public          postgres    false    225   �       �          0    18227    compone 
   TABLE DATA           0   COPY public.compone (isbn, collana) FROM stdin;
    public          postgres    false    229   �       y          0    18084 
   conferenza 
   TABLE DATA           w   COPY public.conferenza (codconferenza, datainizio, datafine, luogo, responsabile, strutturaorganizzatrice) FROM stdin;
    public          postgres    false    215   �       �          0    18264    disponibilital 
   TABLE DATA           I   COPY public.disponibilital (isbn, canale, modalitafruizione) FROM stdin;
    public          postgres    false    230   �       �          0    18210    disponibilitap 
   TABLE DATA           I   COPY public.disponibilitap (isbn, canale, modalitafruizione) FROM stdin;
    public          postgres    false    228   F�       �          0    18178    libro 
   TABLE DATA           �   COPY public.libro (isbn, titolo, tipo, editore, salapresentazione, datauscita, genere, materia, annopubblicazione, modalitafruizione, serie) FROM stdin;
    public          postgres    false    227   ��       �          0    18130 	   preferiti 
   TABLE DATA           2   COPY public.preferiti (utente, serie) FROM stdin;
    public          postgres    false    223   ��       �          0    18158    pubblicazione 
   TABLE DATA           y   COPY public.pubblicazione (isbn, titolo, editore, annopubblicazione, modalitafruizione, conferenza, rivista) FROM stdin;
    public          postgres    false    226   ʅ       ~          0    18115    rivista 
   TABLE DATA           X   COPY public.rivista (doi, nome, argomento, annopubblicazione, responsabile) FROM stdin;
    public          postgres    false    220   ��       {          0    18092    serie 
   TABLE DATA           =   COPY public.serie (codserie, nome, numerovolumi) FROM stdin;
    public          postgres    false    217   D�       �          0    18121    utente 
   TABLE DATA           H   COPY public.utente (idutente, nome, cognome, username, pwd) FROM stdin;
    public          postgres    false    222   8�       �           0    0 !   canaledistribuzione_codcanale_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.canaledistribuzione_codcanale_seq', 14, true);
          public          postgres    false    218            �           0    0    collana_codcollana_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.collana_codcollana_seq', 10, true);
          public          postgres    false    224            �           0    0    conferenza_codconferenza_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.conferenza_codconferenza_seq', 10, true);
          public          postgres    false    214            �           0    0    serie_codserie_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.serie_codserie_seq', 13, true);
          public          postgres    false    216            �           0    0    utente_idutente_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.utente_idutente_seq', 6, true);
          public          postgres    false    221            �           2606    18114 +   canaledistribuzione pk_canale_distribuzione 
   CONSTRAINT     p   ALTER TABLE ONLY public.canaledistribuzione
    ADD CONSTRAINT pk_canale_distribuzione PRIMARY KEY (codcanale);
 U   ALTER TABLE ONLY public.canaledistribuzione DROP CONSTRAINT pk_canale_distribuzione;
       public            postgres    false    219            �           2606    18151    collana pk_collana 
   CONSTRAINT     X   ALTER TABLE ONLY public.collana
    ADD CONSTRAINT pk_collana PRIMARY KEY (codcollana);
 <   ALTER TABLE ONLY public.collana DROP CONSTRAINT pk_collana;
       public            postgres    false    225            �           2606    18233    compone pk_compone 
   CONSTRAINT     [   ALTER TABLE ONLY public.compone
    ADD CONSTRAINT pk_compone PRIMARY KEY (isbn, collana);
 <   ALTER TABLE ONLY public.compone DROP CONSTRAINT pk_compone;
       public            postgres    false    229    229            �           2606    18090    conferenza pk_conferenza 
   CONSTRAINT     a   ALTER TABLE ONLY public.conferenza
    ADD CONSTRAINT pk_conferenza PRIMARY KEY (codconferenza);
 B   ALTER TABLE ONLY public.conferenza DROP CONSTRAINT pk_conferenza;
       public            postgres    false    215            �           2606    18216 (   disponibilitap pk_disponibilitallibreria 
   CONSTRAINT     �   ALTER TABLE ONLY public.disponibilitap
    ADD CONSTRAINT pk_disponibilitallibreria PRIMARY KEY (canale, isbn, modalitafruizione);
 R   ALTER TABLE ONLY public.disponibilitap DROP CONSTRAINT pk_disponibilitallibreria;
       public            postgres    false    228    228    228            �           2606    18270 !   disponibilital pk_disponibilitapl 
   CONSTRAINT     |   ALTER TABLE ONLY public.disponibilital
    ADD CONSTRAINT pk_disponibilitapl PRIMARY KEY (canale, isbn, modalitafruizione);
 K   ALTER TABLE ONLY public.disponibilital DROP CONSTRAINT pk_disponibilitapl;
       public            postgres    false    230    230    230            �           2606    18184    libro pk_libro 
   CONSTRAINT     N   ALTER TABLE ONLY public.libro
    ADD CONSTRAINT pk_libro PRIMARY KEY (isbn);
 8   ALTER TABLE ONLY public.libro DROP CONSTRAINT pk_libro;
       public            postgres    false    227            �           2606    18134    preferiti pk_preferiti 
   CONSTRAINT     _   ALTER TABLE ONLY public.preferiti
    ADD CONSTRAINT pk_preferiti PRIMARY KEY (utente, serie);
 @   ALTER TABLE ONLY public.preferiti DROP CONSTRAINT pk_preferiti;
       public            postgres    false    223    223            �           2606    18164    pubblicazione pk_pubblicazione 
   CONSTRAINT     ^   ALTER TABLE ONLY public.pubblicazione
    ADD CONSTRAINT pk_pubblicazione PRIMARY KEY (isbn);
 H   ALTER TABLE ONLY public.pubblicazione DROP CONSTRAINT pk_pubblicazione;
       public            postgres    false    226            �           2606    18119    rivista pk_rivista 
   CONSTRAINT     Q   ALTER TABLE ONLY public.rivista
    ADD CONSTRAINT pk_rivista PRIMARY KEY (doi);
 <   ALTER TABLE ONLY public.rivista DROP CONSTRAINT pk_rivista;
       public            postgres    false    220            �           2606    18097    serie pk_serie 
   CONSTRAINT     R   ALTER TABLE ONLY public.serie
    ADD CONSTRAINT pk_serie PRIMARY KEY (codserie);
 8   ALTER TABLE ONLY public.serie DROP CONSTRAINT pk_serie;
       public            postgres    false    217            �           2606    18127    utente pk_utente 
   CONSTRAINT     T   ALTER TABLE ONLY public.utente
    ADD CONSTRAINT pk_utente PRIMARY KEY (idutente);
 :   ALTER TABLE ONLY public.utente DROP CONSTRAINT pk_utente;
       public            postgres    false    222            �           2606    18129    utente username_unique 
   CONSTRAINT     U   ALTER TABLE ONLY public.utente
    ADD CONSTRAINT username_unique UNIQUE (username);
 @   ALTER TABLE ONLY public.utente DROP CONSTRAINT username_unique;
       public            postgres    false    222            �           2620    18251 !   disponibilitap chk_disponibilitap    TRIGGER     �   CREATE TRIGGER chk_disponibilitap AFTER INSERT OR UPDATE ON public.disponibilitap FOR EACH ROW EXECUTE FUNCTION public.chk_pubblicazione();
 :   DROP TRIGGER chk_disponibilitap ON public.disponibilitap;
       public          postgres    false    232    228            �           2620    18245 '   canaledistribuzione trg_checktipocanale    TRIGGER     �   CREATE TRIGGER trg_checktipocanale BEFORE INSERT OR UPDATE ON public.canaledistribuzione FOR EACH ROW EXECUTE FUNCTION public.check_tipo_canale();
 @   DROP TRIGGER trg_checktipocanale ON public.canaledistribuzione;
       public          postgres    false    219    248            �           2620    18263    serie trg_setnumerovolumitozero    TRIGGER     �   CREATE TRIGGER trg_setnumerovolumitozero BEFORE INSERT ON public.serie FOR EACH ROW EXECUTE FUNCTION public.set_numerovolumi_to_zero();
 8   DROP TRIGGER trg_setnumerovolumitozero ON public.serie;
       public          postgres    false    217    245            �           2620    18259 !   libro trigger_aggiorna_num_volumi    TRIGGER     �   CREATE TRIGGER trigger_aggiorna_num_volumi AFTER INSERT ON public.libro FOR EACH ROW EXECUTE FUNCTION public.aggiorna_num_volumi_inserimento();
 :   DROP TRIGGER trigger_aggiorna_num_volumi ON public.libro;
       public          postgres    false    227    244            �           2620    18283 /   libro trigger_aggiorna_num_volumi_cancellazione    TRIGGER     �   CREATE TRIGGER trigger_aggiorna_num_volumi_cancellazione BEFORE DELETE ON public.libro FOR EACH ROW EXECUTE FUNCTION public.aggiorna_num_volumi_cancellazione();
 H   DROP TRIGGER trigger_aggiorna_num_volumi_cancellazione ON public.libro;
       public          postgres    false    247    227            �           2606    18239    compone fk_compone_collana    FK CONSTRAINT     �   ALTER TABLE ONLY public.compone
    ADD CONSTRAINT fk_compone_collana FOREIGN KEY (collana) REFERENCES public.collana(codcollana);
 D   ALTER TABLE ONLY public.compone DROP CONSTRAINT fk_compone_collana;
       public          postgres    false    3279    225    229            �           2606    18234    compone fk_compone_libro    FK CONSTRAINT     v   ALTER TABLE ONLY public.compone
    ADD CONSTRAINT fk_compone_libro FOREIGN KEY (isbn) REFERENCES public.libro(isbn);
 B   ALTER TABLE ONLY public.compone DROP CONSTRAINT fk_compone_libro;
       public          postgres    false    227    3283    229            �           2606    18217    disponibilitap fk_displl_canale    FK CONSTRAINT     �   ALTER TABLE ONLY public.disponibilitap
    ADD CONSTRAINT fk_displl_canale FOREIGN KEY (isbn) REFERENCES public.pubblicazione(isbn);
 I   ALTER TABLE ONLY public.disponibilitap DROP CONSTRAINT fk_displl_canale;
       public          postgres    false    3281    228    226            �           2606    18222    disponibilitap fk_displl_libro    FK CONSTRAINT     �   ALTER TABLE ONLY public.disponibilitap
    ADD CONSTRAINT fk_displl_libro FOREIGN KEY (canale) REFERENCES public.canaledistribuzione(codcanale);
 H   ALTER TABLE ONLY public.disponibilitap DROP CONSTRAINT fk_displl_libro;
       public          postgres    false    219    228    3269            �           2606    18271 !   disponibilital fk_disppl_libreria    FK CONSTRAINT     �   ALTER TABLE ONLY public.disponibilital
    ADD CONSTRAINT fk_disppl_libreria FOREIGN KEY (canale) REFERENCES public.canaledistribuzione(codcanale);
 K   ALTER TABLE ONLY public.disponibilital DROP CONSTRAINT fk_disppl_libreria;
       public          postgres    false    219    3269    230            �           2606    18276 &   disponibilital fk_disppl_pubblicazione    FK CONSTRAINT     �   ALTER TABLE ONLY public.disponibilital
    ADD CONSTRAINT fk_disppl_pubblicazione FOREIGN KEY (isbn) REFERENCES public.libro(isbn);
 P   ALTER TABLE ONLY public.disponibilital DROP CONSTRAINT fk_disppl_pubblicazione;
       public          postgres    false    3283    230    227            �           2606    18185    libro fk_libro_serie    FK CONSTRAINT     w   ALTER TABLE ONLY public.libro
    ADD CONSTRAINT fk_libro_serie FOREIGN KEY (serie) REFERENCES public.serie(codserie);
 >   ALTER TABLE ONLY public.libro DROP CONSTRAINT fk_libro_serie;
       public          postgres    false    217    227    3267            �           2606    18140    preferiti fk_preferiti_serie    FK CONSTRAINT        ALTER TABLE ONLY public.preferiti
    ADD CONSTRAINT fk_preferiti_serie FOREIGN KEY (serie) REFERENCES public.serie(codserie);
 F   ALTER TABLE ONLY public.preferiti DROP CONSTRAINT fk_preferiti_serie;
       public          postgres    false    3267    217    223            �           2606    18135    preferiti fk_preferiti_utente    FK CONSTRAINT     �   ALTER TABLE ONLY public.preferiti
    ADD CONSTRAINT fk_preferiti_utente FOREIGN KEY (utente) REFERENCES public.utente(idutente);
 G   ALTER TABLE ONLY public.preferiti DROP CONSTRAINT fk_preferiti_utente;
       public          postgres    false    3273    222    223            �           2606    18165 )   pubblicazione fk_pubblicazione_conferenza    FK CONSTRAINT     �   ALTER TABLE ONLY public.pubblicazione
    ADD CONSTRAINT fk_pubblicazione_conferenza FOREIGN KEY (conferenza) REFERENCES public.conferenza(codconferenza);
 S   ALTER TABLE ONLY public.pubblicazione DROP CONSTRAINT fk_pubblicazione_conferenza;
       public          postgres    false    3265    215    226            �           2606    18170 &   pubblicazione fk_pubblicazione_rivista    FK CONSTRAINT     �   ALTER TABLE ONLY public.pubblicazione
    ADD CONSTRAINT fk_pubblicazione_rivista FOREIGN KEY (rivista) REFERENCES public.rivista(doi);
 P   ALTER TABLE ONLY public.pubblicazione DROP CONSTRAINT fk_pubblicazione_rivista;
       public          postgres    false    220    226    3271            }   C  x�u�Mn�0�דS���vЂT����]��C-���N_�!��k�f�����WS�Z9C^K�J	��'���|�_w�5ؼt	����'�9^IO�u�B�@���Bjg��֪O�qw
(#X��J�����[ړr�_���t�8�2
��W���Ρn~x���Vm�uʸ���8̀fJ}K�K�,�y�+�0�R�YXC8d�x�Ă{cF[J�R8�P��jțɥu*`M���n
4��3n.��*�����茕nf��W�X�ruB�&�Acx6e����V�B[�FJ��ѐc�s�OU�Q�fE�/�˛      �   �   x�E��JQ�u��bm���CVJu#�	3a�$%��<����*�|���JF͎,S���[O���C������5���?r)wg�g/��r���c8P\9n�X��ꟗUx��ִ>^��um�J)I'���|�?K� )�.�Q�	�+<�N����R�/�lh^�I3�e�,���zrNB�)o���"��b      �      x������ � �      y   �  x��S�n�@}^�| �lxtI�&�
a�*R_&����;h�Pѯ��-?���`ԋċu�c�3��l(� ����Fb�*�8�%mó�5�{}O��JօxT5i��d�%$�p&�7�5��$U˵�`�-�)H/r?�{8_�����9M�B��*q�ڇa%���j�U���;�0�ø�c�@-7r �4*�[k`n�P7��w���k֗�/ɐ���nm�GA#���� q�cE��n�v/Xa�6�'�Y��"j���������R�F�t�ʹI�B���.KҢ���K�l
T�w��1�~�p(R�{���rK~%]�=�IEZf��s���9�6r�w.�F"=抎H���X:+)j,`Up�k&~.^���)��"wp(�l�f���X��ͣMTk>��pUj�;񣸇#1�u��r*aN���΁nH%}G{�>7F��S̬�����¸wre�.�{h����]��T'�3	_I��-�a\�����ZE�      �   4   x��4���0013�021�4�t�L�,I�I�DH�[�� �0ĩY&F��� o6�      �   [   x��4���0��41537�4�tN,*ILN��IXZ� %KS2�s2���R��f�&�F���R@@�,,9MЌ�r�"$b���� θ!g      �   �  x�}�ݎ�0��ݧ�d;m~.٥�B����l�fG���8+m��qZ�P)�����9sR�UU�eQT&W��  [�Ho_��F;�w�[h)�����(�2�gZ��s$�Ǣ�����F��#8˭E}�-K���;O�2�s(�3ϸ����f��W�L������ׄKUq��)��vh ��<t���(�-FG缳�2e2����E8jѕx7�H�]i(t��P�K �}��s��JnU��9�s6*3.���!�ʯ��J��G�-:�i��E&���|��L�)���.g|�Vܭ�sJr�.�4QU<���?���sJj��򴳧d�a��:��*Sz�T�k�,9ou������~;� )c(���ќ.�έG��X�؜����\����|L	�_�'-�B'l x��y�J1�<���_`���]a�wcV�H�=ڝ�0~�w�����\��ӕ��xl\\��z|�X,� J10�      �      x�3�4����� ]      �   �  x�}��n�0E���+#�$?��R~ �k@�����T��}�H�1�� ��;g���y���x2���{BVZꎶ#dBUl�,RKh��Z1}b��3�M۹�ޱ-�1��4�� +��!��fPx���g��8�%*�����FXd+i��WX	j�溮�
��
�o �w	��(/x�f�]o(E+Qf?H���ۮ�F�g�*X"AC?��Ln)Iw|���,���V�bBL�E����C��NY��{Ŷݡ���rfKo=<������Ґ^�x�~�`f�4ڍ[�y�P���Z����@)��+�O���?9���C�!,��<�!�)�_�S䜭t�D�b]���췦�r���k\�K	�5Ę�7U����C7��ÿn�j.(M>S��~A����4����僌�EF�V3�~��)\v��Q��֖�Bw���M��;IG�o8�8Ɲl�w�VM�q2����n0�&�      ~   {  x�U�Kn1�לS�����c�8�ͤAt�#�1��H�*w�s�J����y��dמtmۙ�����@q��Ŋ#�۾���(>i�te�7e��WV��[ى-H��91b푙���ås���{�?�����ʶp'�(��v��sS���ꢰ(x���e��P%f9y�A=�x�0E��%E]�p����u+�Jt���/G���+.�a�85E���Q�t���W��i/kN��c�3S���䳭n��������FNf���~�T�M�� n���8�9FF�~���i�>_�� ������9�Xu�{C	H����2��c��n�����V�kM������t�����_�=��)>Œ��I�4�n��      {   �   x�U��N�0E��W��<x.QG<�2Bb�ƤVjɍGN���8t;���s�]x����FJ��I�æۇ^�KAc�7����u^��޵V2n� \NTk�*�y����G#��wa �'�R[�@�ۆ����Ñ�������W��&F�f��"���n�[0�N��_ֶ����v>O�1z��|:k԰���I��g�
��/>G��8���3�i�      �   �   x�5�KO�0�����( ��
�Ԇ*E=q�&K���Z~�j=��6��o���}�����ʂ���N�Z勪�C'�s@�r�E�r!���aCYժ���0L�'�Mo�1��b�����3�W��.��g�|��s{�s���-��#urdAolyH=�#w2���i�)Ǟ����:��ϴϏ��9crZl�0҉����σR��HZ     