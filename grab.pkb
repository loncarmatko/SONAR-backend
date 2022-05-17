create or replace NONEDITIONABLE PACKAGE BODY GRAB AS
e_iznimka exception;


------------------------------------------------------------------------------------
--login
 PROCEDURE p_login(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_username   korisnici.email%TYPE;
    l_password   korisnici.password%TYPE;
    l_id         korisnici.id%TYPE;
    l_out        json_array_t := json_array_t('[]');
 BEGIN
    l_obj.put('h_message', '');
    --l_obj.put('h_errcode', '');
    l_input := in_json.to_string;
    SELECT
        JSON_VALUE(l_input, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.password' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password
    FROM
        dual;

    IF (l_username IS NULL OR l_password is NULL) THEN
       l_obj.put('h_message', 'Molimo unesite korisničko ime i zaporku');
       l_obj.put('h_errcod', 100);
       RAISE e_iznimka;
    ELSE
       BEGIN
          SELECT
             id
          INTO 
             l_id
          FROM
             korisnici
          WHERE
             email = l_username AND 
             password = hash.f_hash_pw(l_username, l_password);
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Nepoznato korisničko ime ili zaporka');
                l_obj.put('h_errcod', 99);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
       END;

       SELECT
          JSON_OBJECT( 
             'ID' VALUE kor.id,
             'IDknjiznica' VALUE kor.idknjiznica, 
             'ime' VALUE kor.ime, 
             'prezime' VALUE kor.prezime, 
             'email' VALUE kor.email,
             'spol' VALUE kor.spol, 
             'oib' VALUE kor.oib, 
             'datrod' VALUE kor.datrod,
             'slika' VALUE kor.slika,
             'IDzvanje' VALUE kor.idzvanje,
             'radnomj' VALUE kor.radnomj,
             'IDpovjerenik' VALUE kor.idpovjerenik,
             'titula' VALUE kor.titula)
       INTO 
          l_record
       FROM
          korisnici kor
       WHERE
          id = l_id;

    END IF;

    l_out.append(json_object_t(l_record));
    l_obj.put('data', l_out);
    out_json := l_obj;
 EXCEPTION
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       --common.p_errlog('p_users_upd', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 98);
       ROLLBACK;
 END p_login;


------------------------------------------------------------------------------------
--p_get_korisnici  
procedure p_get_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_korisnici json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IDKNJIZNICA' VALUE IDKNJIZNICA,
                           'IME' VALUE IME,
                           'PREZIME' VALUE PREZIME,
                           'EMAIL' VALUE EMAIL,
                           'SPOL' VALUE SPOL,
                           'OIB' VALUE OIB,
                           'DATROD' VALUE DATROD,
                           'SLIKA' VALUE SLIKA,
                           'IDZVANJE' VALUE IDZVANJE,
                           'RADNOMJ' VALUE RADNOMJ,
                           'IDPOVJERENIK' VALUE IDPOVJERENIK,
                           'TITULA' VALUE TITULA) as izlaz
             FROM
                korisnici
             where
                ID = nvl(l_id, ID)
            order by id
            )
        LOOP
            l_korisnici.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       korisnici
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_korisnici);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_korisnici', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 97);
       ROLLBACK;    


  end p_get_korisnici;


------------------------------------------------------------------------------------
--p_get_knjiznice  
procedure p_get_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_knjiznice json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV
                           /*'ADRESA' VALUE ADRESA,
                           'IDMJESTO' VALUE IDMJESTO,
                           'EMAIL' VALUE EMAIL,
                           'POZBRO' VALUE POZBRO,
                           'TELBRO' VALUE TELBRO,
                           'OIB' VALUE OIB*/) as izlaz
             FROM
                knjiznice
             where
                ID = nvl(l_id, ID) 
             ORDER BY ID
            )
        LOOP
            l_knjiznice.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       knjiznice
    where
        ID = nvl(l_id, ID) ;


    l_obj.put('count',l_count);
    l_obj.put('data',l_knjiznice);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 96);
       ROLLBACK;    


  end p_get_knjiznice;


------------------------------------------------------------------------------------
--p_get_mjesta
procedure p_get_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_mjesta json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number;

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
                json_object('ID' VALUE ID, 
                            'NAZIV' VALUE NAZIV,
                            'IDZUPANIJE' VALUE IDZUPANIJE,
                            'IDPU' VALUE IDPU) as izlaz
             FROM
                mjesta
             where
                ID = nvl(l_id, ID)
             ORDER BY ID
             FETCH FIRST 10 ROWS ONLY
            ) 
        LOOP
            l_mjesta.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       mjesta
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_mjesta);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 95);
       ROLLBACK;    


  end p_get_mjesta;


------------------------------------------------------------------------------------
--p_get_zupanije
procedure p_get_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_zupanije json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV,
                           'SIFRA' VALUE SIFRA) as izlaz
             FROM
                zupanije
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_zupanije.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       zupanije
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_zupanije);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_zupanije', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 94);
       ROLLBACK;    


  end p_get_zupanije;


------------------------------------------------------------------------------------
--p_get_pu
procedure p_get_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_pu json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID,
                           'BROJ' VALUE BROJ, 
                           'NAZIV' VALUE NAZIV) as izlaz
             FROM
                pu
             where
                ID = nvl(l_id, ID) 
             ORDER BY ID
             FETCH FIRST 10 ROWS ONLY
            )
        LOOP
            l_pu.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       pu
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_pu);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_pu', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 93);
       ROLLBACK;    


  end p_get_pu;


------------------------------------------------------------------------------------
--p_get_arhiva  
procedure p_get_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_arhiva json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IDKORISNIKA' VALUE IDKORISNIKA,
                           'HISTORY' VALUE HISTORY) as izlaz
             FROM
                arhiva
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_arhiva.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       arhiva
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_arhiva);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_arhiva', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 92);
       ROLLBACK;    


  end p_get_arhiva;


------------------------------------------------------------------------------------
--p_get_dokumenti
procedure p_get_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_dokumenti json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IDKORISNIKA' VALUE IDKORISNIKA,
                           'IDPRAVILNIK' VALUE IDPRAVILNIK,
                           'IDPRIJAVE' VALUE IDPRIJAVE,
                           'LINK' VALUE LINK,
                           'DATUM' VALUE DATUM) as izlaz
             FROM
                dokumenti
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_dokumenti.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       dokumenti
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_dokumenti);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_dokumenti', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 91);
       ROLLBACK;    


  end p_get_dokumenti;


------------------------------------------------------------------------------------
--p_get_opci
procedure p_get_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_opci json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID,
                           'TIP' VALUE TIP,
                           'IDKORISNIKA' VALUE IDKORISNIKA, 
                           'LINK' VALUE LINK) as izlaz
             FROM
                opci
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_opci.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       opci
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_opci);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_opci', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 90);
       ROLLBACK;    


  end p_get_opci;


------------------------------------------------------------------------------------
--p_get_pravilnici  
procedure p_get_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_pravilnici json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IDSKUPINE' VALUE IDSKUPINE,
                           'RBR' VALUE RBR,
                           'NAZIV' VALUE NAZIV,
                           'BODOVI' VALUE BODOVI) as izlaz
             FROM
                pravilnici
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_pravilnici.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       pravilnici
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_pravilnici);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_pravilnici', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 89);
       ROLLBACK;    


  end p_get_pravilnici;


------------------------------------------------------------------------------------
--p_get_skupine  
procedure p_get_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_skupine json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV,
                           'NAPOMENA' VALUE NAPOMENA,
                           'MAXBODOVI' VALUE MAXBODOVI) as izlaz
             FROM
                skupine
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_skupine.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       skupine
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_skupine);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_skupine', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 88);
       ROLLBACK;    


  end p_get_skupine;


------------------------------------------------------------------------------------
--p_get_prijave  
procedure p_get_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_prijave json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IDKORISNIKA' VALUE IDKORISNIKA,
                           'PODNESENO' VALUE PODNESENO,
                           'IDZVANJE' VALUE IDZVANJE,
                           'IDSTATUSPRIJAVE' VALUE IDSTATUSPRIJAVE,
                           'IDPOVJERENIK' VALUE IDPOVJERENIK) as izlaz
             FROM
                prijave
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_prijave.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       prijave
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_prijave);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_prijave', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 87);
       ROLLBACK;    


  end p_get_prijave;


------------------------------------------------------------------------------------
--p_get_zvanja  
procedure p_get_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_zvanja json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV,
                           'MINBODOVI' VALUE MINBODOVI,
                           'MINSKUPINE' VALUE MINSKUPINE) as izlaz
             FROM
                zvanja
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_zvanja.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       zvanja
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_zvanja);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_zvanja', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 86);
       ROLLBACK;    


  end p_get_zvanja;


------------------------------------------------------------------------------------
--p_get_povjerenici  
procedure p_get_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_povjerenici json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV) as izlaz
             FROM
                povjerenici
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_povjerenici.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       povjerenici
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_povjerenici);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_povjerenici', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 85);
       ROLLBACK;    


  end p_get_povjerenici;


------------------------------------------------------------------------------------
--p_get_statusprijave 
procedure p_get_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_statusprijave json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV) as izlaz
             FROM
                statusprijave
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_statusprijave.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       statusprijave
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_statusprijave);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_statusprijave', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 84);
       ROLLBACK;    


  end p_get_statusprijave;
  
  --p_get_bodovizvanja
procedure p_get_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_bodovizvanja json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  BEGIN
    l_obj := JSON_OBJECT_T(in_json);

    l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;

    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID,
                           'IDSKUPINE' VALUE IDSKUPINE, 
                           'IDZVANJA' VALUE IDZVANJA,
                           'BODOVI' VALUE BODOVI) as izlaz
             FROM
                bodovizvanja
             where
                ID = nvl(l_id, ID) 
             ORDER BY ID
             FETCH FIRST 10 ROWS ONLY
            )
        LOOP
            l_bodovizvanja.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

    SELECT
      count(1)
    INTO
       l_count
    FROM 
       bodovizvanja
    where
        ID = nvl(l_id, ID) ;

    l_obj.put('count',l_count);
    l_obj.put('data',l_bodovizvanja);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_bodovizvanja', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 83);
       ROLLBACK;    


  end p_get_bodovizvanja;



END GRAB;