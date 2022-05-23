CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY CONTROLPRIJAVE AS 
e_iznimka exception;

------------------------------------------------------------------------------------
--p_uzmirazmatranje
procedure p_uzmirazmatranje(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_prijava varchar2(8000);
  l_prijave prijave%rowtype;
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

   SELECT 
      JSON_VALUE(l_string, '$.UserID' RETURNING NUMBER),
      JSON_VALUE(l_string, '$.ID' RETURNING NUMBER) 
   INTO
      l_prijave.IDPOVJERENIK,
      l_prijave.ID
   FROM 
      DUAL;   

    
    UPDATE prijave
    SET 
        IDSTATUSPRIJAVE = 2,
        IDPOVJERENIK = l_prijave.IDPOVJERENIK
    WHERE
        ID = l_prijave.ID;


    l_obj.put('h_message', 'Prijava uzeta na razmatranje');
    l_obj.put('h_errcode', '0');
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 200);
       ROLLBACK;    


  end p_uzmirazmatranje;
 

-----------------------------------------------------------------------------------------
--p_zatvoriprijavu
procedure p_zatvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_prijave prijave%rowtype;
  l_prijava varchar2(8000);
  l_prs json_array_t :=JSON_ARRAY_T('[]');
  l_dokument varchar2(8000);
  l_dokumenti json_array_t :=JSON_ARRAY_T('[]');
  l_statusprijave number;
  l_id number;
  l_string varchar2(1000);
  l_clobprijave CLOB;
  l_clobdokumenti CLOB;
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  CURSOR c_prijava IS
    SELECT 
        json_object('ID' VALUE ID, 
                    'IDKORISNIKA' VALUE IDKORISNIKA,
                    'PODNESENO' VALUE PODNESENO,
                    'IDZVANJE' VALUE IDZVANJE,
                    'IDSTATUSPRIJAVE' VALUE IDSTATUSPRIJAVE,
                    'IDPOVJERENIK' VALUE IDPOVJERENIK,
                    'PRIHVACENO' VALUE PRIHVACENO,
                    'KOMENTAR' VALUE KOMENTAR)
    FROM
        prijave
    WHERE 
        ID = l_prijave.ID;
  
  CURSOR c_dokument IS
    SELECT
        json_object('ID' VALUE dok.ID,
                    'IDKORISNIKA' VALUE dok.IDKORISNIKA,
                    'PRAVILNIK' VALUE prav.NAZIV,
                    'IDPRIJAVE' VALUE dok.IDPRIJAVE,
                    'LINK' VALUE dok.LINK,
                    'DATUM' VALUE dok.DATUM,
                    'PRIHVACENO' VALUE dok.PRIHVACENO,
                    'KOMENTAR' VALUE dok.KOMENTAR)
    FROM
        dokumenti dok INNER JOIN pravilnici prav on dok.IDPRAVILNIK = prav.id
    WHERE
        dok.IDPRIJAVE = l_prijave.ID;
  
  
    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.IDPRIJAVE'),
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.PRIHVACENO'),
        JSON_VALUE(l_string, '$.KOMENTAR')
    INTO
        l_prijave.ID,
        l_prijave.IDKORISNIKA,
        l_prijave.PRIHVACENO,
        l_prijave.KOMENTAR
    FROM
        dual;
        

  OPEN c_prijava;
    LOOP
        FETCH c_prijava into l_prijava;
        EXIT WHEN c_prijava%notfound;
        l_prs.append(JSON_OBJECT_T(l_prijava));
    END LOOP;
  CLOSE c_prijava;            

  OPEN c_dokument;
    LOOP
        FETCH c_dokument into l_dokument;
        EXIT WHEN c_dokument%notfound;
        l_dokumenti.append(JSON_OBJECT_T(l_dokument));
    END LOOP;
  CLOSE c_dokument;            

    l_clobprijave := l_prs.TO_CLOB;
    l_clobdokumenti := l_dokumenti.TO_CLOB;



    if(l_prijave.PRIHVACENO = 1)  THEN
        UPDATE korisnici SET IDZVANJE = (select IDZVANJE from prijave where ID = l_prijave.ID) WHERE ID = l_prijave.IDKORISNIKA;
        commit;
    end if;

       

    UPDATE prijave 
    SET
        IDSTATUSPRIJAVE = 3,
        PRIHVACENO = l_prijave.PRIHVACENO,
        KOMENTAR = l_prijave.KOMENTAR
    WHERE 
        ID = l_prijave.ID;
    commit;


    INSERT INTO
        arhiva(IDKORISNIKA, HISTORY, HISTORYDOKUMENTI) VALUES (l_prijave.IDKORISNIKA, l_clobprijave, l_clobdokumenti);
    commit;
   

    DELETE FROM dokumenti
    WHERE IDPRIJAVE = l_prijave.ID;
    commit;

    DELETE FROM prijave
    WHERE ID = l_prijave.ID;
    commit;
            
    
    l_obj.put('h_message', 'Prijava i dokumenti su arhivirani!'); 
    l_obj.put('h_errcode', 0);
    out_json := l_obj;


    l_obj.put('prijava',l_prs);
    l_obj.put('dokumenti', l_dokumenti);
    out_json := l_obj;

 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka' || SQLERRM);
       l_obj.put('h_errcode', 201);
       ROLLBACK;    

END p_zatvoriprijavu;


-----------------------------------------------------------------------------------------
--p_zatvoridokument
procedure p_zatvoridokument(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_dokumenti dokumenti%rowtype;
  l_dokument varchar2(8000);
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 
  
    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID'),
        JSON_VALUE(l_string, '$.PRIHVACENO'),
        JSON_VALUE(l_string, '$.KOMENTAR')
    INTO
        l_dokumenti.ID,
        l_dokumenti.PRIHVACENO,
        l_dokumenti.KOMENTAR
    FROM
        dual;
        

    UPDATE dokumenti 
    SET
        PRIHVACENO = l_dokumenti.PRIHVACENO,
        KOMENTAR = l_dokumenti.KOMENTAR
    WHERE 
        ID = l_dokumenti.ID;
    commit;
    
    l_obj.put('h_message', 'Dokument je ocjenjen!'); 
    l_obj.put('h_errcode', 0);
    out_json := l_obj;


 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka' || SQLERRM);
       l_obj.put('h_errcode', 202);
       ROLLBACK;    

END p_zatvoridokument;

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
        JSON_VALUE(l_string, '$.UserID'),
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
        controlprijave.p_otvoriprijavu(in_json, l_obj);
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
      l_obj.put('h_errcode', 203);
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
        JSON_VALUE(l_string, '$.IDPRIJAVE'),
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
      l_obj.put('h_errcode', 204);
      out_json := l_obj;

END p_podnesiprijavu;



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
        JSON_VALUE(l_string, '$.UserID'),
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
      l_obj.put('h_errcode', 205);
      out_json := l_obj;

END p_otvoriprijavu;


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
        JSON_VALUE(l_string, '$.UserID')
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
      l_obj.put('h_errcode', 206);
      out_json := l_obj;

END p_obrisiprijavu;


END CONTROLPRIJAVE;