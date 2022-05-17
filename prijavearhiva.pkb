create or replace NONEDITIONABLE PACKAGE BODY PRIJAVEARHIVA AS 
e_iznimka exception;
-----------------------------------------------------------------------------------------
--p_arhivirajprijavu
procedure p_arhivirajprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_prijave prijave%rowtype;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_statusprijave number;
  l_id number;
  l_string varchar2(1000);
  l_stringprijava varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  CURSOR c_show IS
    SELECT 
        json_object('ID' VALUE ID, 
                    'IDKORISNIKA' VALUE IDKORISNIKA,
                    'PODNESENO' VALUE PODNESENO,
                    'IDZVANJE' VALUE IDZVANJE,
                    'IDSTATUSPRIJAVE' VALUE IDSTATUSPRIJAVE,
                    'IDPOVJERENIK' VALUE IDPOVJERENIK) as izlaz
    FROM
        prijave
    WHERE 
        ID = l_prijave.ID;

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.ID'),
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_prijave.ID,
        l_prijave.IDKORISNIKA
    FROM
        dual;
        
    UPDATE 
        prijave
    SET
        IDSTATUSPRIJAVE = 3
    WHERE
        ID = l_prijave.ID;

  OPEN c_show;
    FETCH c_show into l_show;
    l_shows.append(JSON_OBJECT_T(l_show));
  CLOSE c_show;            

    l_stringprijava := l_shows.TO_CLOB;


    INSERT INTO
        arhiva(IDKORISNIKA, HISTORY) VALUES (l_prijave.IDKORISNIKA, l_stringprijava);
        
    DELETE FROM prijave
    WHERE ID = l_prijave.ID;
        commit;
        
        l_obj.put('h_message', 'Prijava je arhivirana!'); 
        l_obj.put('h_errcode', 0);
        out_json := l_obj;


    l_obj.put('data',l_shows);
    out_json := l_obj;

 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka' || SQLERRM);
       l_obj.put('h_errcode', 600);
       ROLLBACK;    

END p_arhivirajprijavu;


-----------------------------------------------------------------------------------------
--p_procitajstavku
procedure p_procitajstavku(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_arhiva arhiva%rowtype;
  l_read CLOB;
  l_readjson JSON_ARRAY_T;
  l_id number;
  l_string varchar2(1000);
  l_stringprijava varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING();      
    
    SELECT
        JSON_VALUE(l_string, '$.IDARHIVE')
    INTO
        l_arhiva.ID
    FROM 
        dual;
        
        

    SELECT
        HISTORYDOKUMENTI
    INTO
        l_read
    FROM
        arhiva
    WHERE   
        ID = l_arhiva.ID;

    l_readjson := JSON_ARRAY_T(l_read);
        
    l_obj.put('dokumenti', l_readjson);
    out_json := l_obj;

 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka' || SQLERRM);
       l_obj.put('h_errcode', 601);
       ROLLBACK;    


END p_procitajstavku;


-----------------------------------------------------------------------------------------
--p_procitajarhivu
procedure p_procitajarhivu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_arhiva arhiva%rowtype;
  l_prijave prijave%rowtype;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_read CLOB;
  l_readjson JSON_OBJECT_T;
  l_id number(10);
  l_string varchar2(1000);
  l_stringprijava varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 


  CURSOR c_show IS
    SELECT 
        json_object('IDARHIVE' VALUE IDARHIVE,
                    'IDPRIJAVE' VALUE JSON_VALUE(jsons, '$.ID' RETURNING NUMBER),
                    'IDKORISNIKA' VALUE JSON_VALUE(jsons, '$.IDKORISNIKA' RETURNING NUMBER),
                    'PODNESENO' VALUE JSON_VALUE(jsons, '$.PODNESENO'),
                    'ZVANJE' VALUE (select naziv from zvanja where id = JSON_VALUE(jsons, '$.IDZVANJE' RETURNING NUMBER)),
                    'IDSTATUSPRIJAVE' VALUE JSON_VALUE(jsons, '$.IDSTATUSPRIJAVE' RETURNING NUMBER),
                    'IDPOVJERENIK' VALUE JSON_VALUE(jsons, '$.IDPOVJERENIK' RETURNING NUMBER))
    FROM
        (   SELECT
                ID as IDARHIVE,
                HISTORY as jsons
            FROM
                arhiva
            WHERE
                IDKORISNIKA = l_arhiva.IDKORISNIKA
        )
--    WHERE 
--        IDKORISNIKA = l_arhiva.IDKORISNIKA
    ORDER BY 
        IDARHIVE;

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    SELECT
        JSON_VALUE(l_string, '$.IDKORISNIKA')
    INTO
        l_arhiva.IDKORISNIKA
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

 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_get_knjiznice', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka' || SQLERRM);
       l_obj.put('h_errcode', 602);
       ROLLBACK;    


END p_procitajarhivu;







END PRIJAVEARHIVA;