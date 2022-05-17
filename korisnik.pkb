create or replace NONEDITIONABLE PACKAGE BODY KORISNIK AS 
e_iznimka exception;

-----------------------------------------------------------------------------------------
--p_otvoriprijavu
procedure p_otvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_zvanje varchar2(8000);
      l_minzvanje varchar2(8000);
      l_shows json_array_t :=JSON_ARRAY_T('[]');
      l_test number;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
  CURSOR c_zvanje IS
    SELECT
        JSON_OBJECT('ZVANJEID' VALUE zv.ID,
                    'ZVANJE' VALUE zv.naziv,
                    'minbodovi' VALUE zv.minbodovi,
                    'minskupine' VALUE zv.minskupine) as izlaz
    FROM 
        zvanja zv 
    WHERE 
        zv.id = l_prijave.IDZVANJE;

  CURSOR c_minzvanje IS
    SELECT
        JSON_OBJECT('minbodovizvanja' VALUE bod.BODOVI,
                    'skupina' VALUE sk.naziv,
                    'idskupina' VALUE sk.ID) as izlaz
    FROM 
        bodovizvanja bod INNER JOIN zvanja zv on bod.IDZVANJA = zv.ID INNER JOIN skupine sk on bod.IDSKUPINE = sk.ID
    WHERE 
        bod.IDZVANJA = l_prijave.IDZVANJE;


    BEGIN
  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.IDZVANJE')
    INTO
        l_prijave.IDKORISNIKA,
        l_prijave.IDZVANJE
    FROM 
       dual;     

     
  OPEN c_zvanje;
    LOOP
        FETCH c_zvanje into l_zvanje;
        EXIT WHEN c_zvanje%notfound;
        l_shows.append(JSON_OBJECT_T(l_zvanje));
    END LOOP;
  CLOSE c_zvanje;
  
  OPEN c_minzvanje;
    LOOP
        FETCH c_minzvanje into l_minzvanje;
        EXIT WHEN c_minzvanje%notfound;
        l_shows.append(JSON_OBJECT_T(l_minzvanje));
    END LOOP;
  CLOSE c_minzvanje;
  
  
  
  l_obj.put('data',l_shows);
        
  BEGIN
    insert into prijave(IDKORISNIKA, IDZVANJE, IDSTATUSPRIJAVE) values
          (l_prijave.IDKORISNIKA, l_prijave.IDZVANJE, 4)
    returning id into l_test;
        commit;

        l_obj.put('idprijave', l_test);
        out_json := l_obj;

      exception
          when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
            rollback;
            raise;
  
    END;
 

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 300);
      out_json := l_obj;

END p_otvoriprijavu;

------------------------------------------------------------------------------------
--p_widgetkorisnik
procedure p_widgetkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_idprijave number; 

   

  CURSOR c_show IS
    SELECT 
        json_object('korisnik' VALUE kor.ime || ' ' || kor.prezime,
                    'email' VALUE kor.email,
                    'datrod' VALUE kor.datrod,
                    'slika' VALUE kor.slika,
                    'knjiznica' VALUE knj.naziv,
                    'radnomj' VALUE kor.radnomj,
                    'zvanje' VALUE zv.naziv,
                    'titula' VALUE kor.titula) as izlaz
    FROM
        korisnici kor inner join zvanja zv on kor.idzvanje = zv.id inner join knjiznice knj on kor.idknjiznica = knj.id
    where
        kor.id = l_id;

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_id
    FROM 
       dual;     


  OPEN c_show;
    LOOP
        FETCH c_show into l_show;
        EXIT WHEN c_show%notfound;
        l_shows.append(JSON_OBJECT_T(l_show));
    END LOOP;
  CLOSE c_show;            
    

    l_obj.put('data',l_shows);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 301);
       ROLLBACK;    


  end p_widgetkorisnik;


-----------------------------------------------------------------------------------------
--p_checkotvoreno
procedure p_checkotvoreno(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_show varchar2(8000);
      l_bodovi varchar2(8000);
      l_skupine json_array_t :=JSON_ARRAY_T('[]');
      l_shows json_array_t :=JSON_ARRAY_T('[]');
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
  CURSOR c_show IS
    SELECT 
        json_object('IDPRIJAVE' VALUE pr.ID,
                    'IDSTATUSPRIJAVE' VALUE pr.IDSTATUSPRIJAVE,
                    'STATUSPRIJAVE' VALUE stp.NAZIV,
                    'IDZVANJE' VALUE pr.IDZVANJE,
                    'ZVANJE' VALUE zv.NAZIV) as izlaz
    FROM
        prijave pr INNER JOIN zvanja zv on pr.IDZVANJE = zv.ID INNER JOIN statusprijave stp on pr.IDSTATUSPRIJAVE = stp.ID 
    WHERE
        IDKORISNIKA = l_prijave.IDKORISNIKA;

  CURSOR c_bodoviskupina IS
    SELECT 
        json_object('IDSKUPINE' VALUE bod.IDSKUPINE,
                    'SKUPINA' VALUE sk.NAZIV,
                    'MINBODOVI' VALUE bod.BODOVI) as izlaz
    FROM
        bodovizvanja bod inner join skupine sk on bod.IDSKUPINE = sk.ID
    WHERE
        bod.IDZVANJA = (select IDZVANJE from prijave where IDKORISNIKA = l_prijave.IDKORISNIKA);

      
    BEGIN
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.IDZVANJE')
    INTO
        l_prijave.IDKORISNIKA,
        l_prijave.IDZVANJE
    FROM 
       dual;     

  OPEN c_show;
    LOOP
        FETCH c_show into l_show;
        EXIT WHEN c_show%notfound;
        l_shows.append(JSON_OBJECT_T(l_show));
    END LOOP;
  CLOSE c_show;
  
  OPEN c_bodoviskupina;
    LOOP
        FETCH c_bodoviskupina into l_bodovi;
        EXIT WHEN c_bodoviskupina%notfound;
        l_skupine.append(JSON_OBJECT_T(l_bodovi));
    END LOOP;
  CLOSE c_bodoviskupina;


    if (l_show is null AND (l_prijave.IDZVANJE != 0)) then   
        korisnik.p_otvoriprijavu(in_json, l_obj);
    elsif(l_show is not null) then
        l_obj.put('data', l_shows);
        l_obj.put('skupine', l_skupine);
    else
        l_obj.put('h_message', 'Ne postoji prijava');
        l_obj.put('h_errcode', 404);
    end if;
    
  
  out_json := l_obj;

        
exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 302);
      out_json := l_obj;

END p_checkotvoreno;


-----------------------------------------------------------------------------------------
--p_podnesiprijavu
procedure p_podnesiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_zvanje varchar2(8000);
      l_zvanja json_array_t :=JSON_ARRAY_T('[]');
      l_target number;
      l_test number;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
    BEGIN
  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.ID'),
        JSON_VALUE(l_string, '$.UserID')
    INTO
        l_prijave.ID,
        l_prijave.IDKORISNIKA
    FROM 
       dual;     

    BEGIN
        UPDATE prijave
        SET PODNESENO = SYSDATE,
            IDSTATUSPRIJAVE = 1
        WHERE
            ID = l_prijave.ID;
        commit;
    END;

    l_obj.put('h_message', 'Prijava je podnesena'); 
    l_obj.put('h_errcode', 0);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 303);
      out_json := l_obj;

END p_podnesiprijavu;



-----------------------------------------------------------------------------------------
--p_dokumentiprijave
procedure p_dokumentiprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_dokumenti dokumenti%rowtype;
      l_show varchar2(8000);
      l_shows json_array_t :=JSON_ARRAY_T('[]');
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
    CURSOR c_show IS
        SELECT 
            json_object('IDDOKUMENTA' VALUE dok.ID,
                        'PRAVILNIK' VALUE prav.naziv,
                        'LINK' VALUE dok.link,
                        'DATUM' VALUE dok.DATUM) as izlaz
        FROM
            dokumenti dok INNER JOIN pravilnici prav on dok.IDPRAVILNIK = prav.ID
        WHERE
            dok.IDPRIJAVE = l_dokumenti.IDPRIJAVE
        ORDER BY
            prav.ID;
      

    BEGIN  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDPRIJAVE'),
        JSON_VALUE(l_string, '$.UserID')
    INTO
        l_dokumenti.IDPRIJAVE,
        l_dokumenti.IDKORISNIKA
    FROM 
       dual;     

    OPEN c_show;
        LOOP
            FETCH c_show into l_show;
            EXIT WHEN c_show%notfound;
            l_shows.append(JSON_OBJECT_T(l_show));
        END LOOP;
    CLOSE c_show;

    l_obj.put('data', l_shows);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 304);
      out_json := l_obj;

END p_dokumentiprijave;


------------------------------------------------------------------------------------
--p_getkorisnik
procedure p_getkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_idprijave number; 

   

  CURSOR c_show IS
    SELECT 
        json_object('IME' VALUE kor.IME, 
                    'PREZIME' VALUE kor.PREZIME,
                    'EMAIL' VALUE kor.EMAIL,
                    'IDKNJIZNICA' VALUE kor.IDKNJIZNICA,
                    'KNJIZNICA' VALUE knj.NAZIV,
                    'SPOL' VALUE kor.SPOL,
                    'OIB' VALUE kor.OIB,
                    'DATROD' VALUE kor.DATROD,
                    'SLIKA' VALUE kor.SLIKA,
                    'IDZVANJE' VALUE kor.IDZVANJE,
                    'ZVANJE' VALUE zv.NAZIV,
                    'RADNOMJ' VALUE kor.RADNOMJ,
                    'TITULA' VALUE kor.TITULA) as izlaz
    FROM
        korisnici kor inner join zvanja zv on kor.idzvanje = zv.id inner join knjiznice knj on kor.idknjiznica = knj.id
    where
        kor.id = l_id;

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_id
    FROM 
       dual;     


  OPEN c_show;
    LOOP
        FETCH c_show into l_show;
        EXIT WHEN c_show%notfound;
        l_shows.append(JSON_OBJECT_T(l_show));
    END LOOP;
  CLOSE c_show;            
    

    l_obj.put('data',l_shows);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 305);
       ROLLBACK;    


  end p_getkorisnik;


------------------------------------------------------------------------------------
--p_getkorisnik
procedure p_promjenipassword(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_korisnici korisnici%rowtype;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_idprijave number; 

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.PASSWORD')
    INTO
        l_korisnici.ID,
        l_korisnici.PASSWORD
    FROM 
       dual;     

    select email into l_korisnici.EMAIL from korisnici where ID = l_korisnici.ID;


    UPDATE KORISNICI 
    SET PASSWORD = hash.f_hash_pw(l_korisnici.EMAIL, l_korisnici.PASSWORD)
    WHERE ID = l_korisnici.ID;
    commit;
    
    l_obj.put('h_message', 'Lozinka je promjenjena'); 
    l_obj.put('h_errcode', 0);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 306);
       ROLLBACK;    


  end p_promjenipassword;


-----------------------------------------------------------------------------------------
--p_showopci
procedure p_showopci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_opci opci%rowtype;
      l_show varchar2(8000);
      l_shows json_array_t :=JSON_ARRAY_T('[]');
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
    CURSOR c_show IS
        SELECT 
            json_object('ID' VALUE ID,
                        'TIP' VALUE TIP,
                        'LINK' VALUE LINK) as izlaz
        FROM
            opci
        WHERE
            IDKORISNIKA = l_opci.IDKORISNIKA
        ORDER BY
            TIP;
      

    BEGIN  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_opci.IDKORISNIKA
    FROM 
       dual;     

    OPEN c_show;
        LOOP
            FETCH c_show into l_show;
            EXIT WHEN c_show%notfound;
            l_shows.append(JSON_OBJECT_T(l_show));
        END LOOP;
    CLOSE c_show;

    l_obj.put('data', l_shows);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 307);
      out_json := l_obj;

END p_showopci;


-----------------------------------------------------------------------------------------
--p_showdokumenti
procedure p_showdokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_dokumenti dokumenti%rowtype;
      l_show varchar2(8000);
      l_shows json_array_t :=JSON_ARRAY_T('[]');
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
    CURSOR c_show IS
        SELECT 
            json_object('IDDOKUMENT' VALUE dok.ID,
                        'PRAVILNIK' VALUE prav.NAZIV,
                        'LINK' VALUE dok.LINK,
                        'IDSKUPINE' VALUE prav.IDSKUPINE,
                        'DATUM' VALUE dok.DATUM) as izlaz
        FROM
            dokumenti dok INNER JOIN pravilnici prav on dok.IDPRAVILNIK = prav.ID 
        WHERE
            dok.IDPRIJAVE = l_dokumenti.IDPRIJAVE;            
      

    BEGIN  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDPRIJAVE')
    INTO
        l_dokumenti.IDPRIJAVE
    FROM 
       dual;     

    OPEN c_show;
        LOOP
            FETCH c_show into l_show;
            EXIT WHEN c_show%notfound;
            l_shows.append(JSON_OBJECT_T(l_show));
        END LOOP;
    CLOSE c_show;

    l_obj.put('data', l_shows);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 308);
      out_json := l_obj;

END p_showdokumenti;


-----------------------------------------------------------------------------------------
--p_obrisiprijavu
procedure p_obrisiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
      
    BEGIN
  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_prijave.IDKORISNIKA
    FROM 
       dual;     

    BEGIN
        DELETE prijave
        WHERE
            IDKORISNIKA = l_prijave.IDKORISNIKA;
        commit;
    END;

    l_obj.put('h_message', 'Prijava je obrisana'); 
    l_obj.put('h_errcode', 0);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 309);
      out_json := l_obj;

END p_obrisiprijavu;




END KORISNIK;