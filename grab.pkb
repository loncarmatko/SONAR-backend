create or replace NONEDITIONABLE PACKAGE BODY GRAB AS
e_iznimka exception;


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


END GRAB; 