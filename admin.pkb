create or replace NONEDITIONABLE PACKAGE BODY ADMIN AS
e_iznimka exception;

------------------------------------------------------------------------------------
--p_show_mjesta
procedure p_show_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 

  CURSOR c_show IS
    SELECT 
        json_object('ID' VALUE mj.ID, 
                    'Mjesto' VALUE mj.NAZIV,
                    'Poštanski ured' VALUE pu.naziv,
                    'Županije' VALUE z.naziv) as izlaz
    FROM
        mjesta mj INNER JOIN pu pu on mj.idpu = pu.id INNER JOIN zupanije z on mj.idzupanije = z.id
    ORDER BY
        mj.ID
    OFFSET NVL(l_page, 0) ROWS FETCH NEXT nvl(l_perpage,1) ROWS ONLY;

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    
   SELECT 
      JSON_VALUE(l_string, '$.perpage' RETURNING NUMBER) 
   INTO
      l_perpage
   FROM 
      DUAL;   

   SELECT 
      (JSON_VALUE(l_string, '$.page' RETURNING NUMBER) -1) * l_perpage  
   INTO
      l_page
   FROM 
      DUAL;

   if l_page < 0 then  
      l_page := 0;
   end if;


  OPEN c_show;
    LOOP
        FETCH c_show into l_show;
        EXIT WHEN c_show%notfound;
        l_shows.append(JSON_OBJECT_T(l_show));
    END LOOP;
  CLOSE c_show;            

  select count(1) 
  into 
    l_count
  FROM
    mjesta mj; 


    l_obj.put('count',l_count);
    l_obj.put('data',l_shows);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 200);
       ROLLBACK;    


  end p_show_mjesta;

------------------------------------------------------------------------------------
--p_show_prijave
procedure p_show_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_show varchar2(8000);
  l_shows json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_brdoc number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number; 
  l_idprijave number; 

   

  CURSOR c_show IS
    SELECT 
        json_object('idprijave' VALUE pr.ID,
                    'idstatusprijave' VALUE pr.IDSTATUSPRIJAVE,
                    'idkorisnik' VALUE kor.ID,
                    'korisnik' VALUE kor.ime || ' ' || kor.prezime,
                    'podneseno' VALUE pr.podneseno,
                    'zvanje' VALUE zv.naziv,
                    'email' VALUE kor.email,
                    'link' VALUE kor.slika,
                    'knjiznica' VALUE knj.naziv) as izlaz
    FROM
        prijave pr INNER JOIN korisnici kor on pr.idkorisnika = kor.id INNER JOIN zvanja zv on pr.idzvanje = zv.id INNER JOIN statusprijave stp on pr.idstatusprijave = stp.id INNER JOIN knjiznice knj on kor.idknjiznica = knj.id
    --WHERE
        --stp.id = 1
    ORDER BY
        pr.ID
    OFFSET NVL(l_page, 0) ROWS FETCH NEXT nvl(l_perpage,1) ROWS ONLY;
    

    BEGIN
      l_obj := new JSON_OBJECT_T();
      l_string := in_json.TO_STRING; 

    
   SELECT 
      JSON_VALUE(l_string, '$.perpage' RETURNING NUMBER)
   INTO
      l_perpage
   FROM 
      DUAL;   

   SELECT 
      (JSON_VALUE(l_string, '$.page' RETURNING NUMBER) -1) * l_perpage  
   INTO
      l_page
   FROM 
      DUAL;

   if l_page < 0 then  
      l_page := 0;
   end if;

  OPEN c_show;
    LOOP
        FETCH c_show into l_show;
        EXIT WHEN c_show%notfound;
        l_shows.append(JSON_OBJECT_T(l_show));
    END LOOP;
  CLOSE c_show;            

  select count(1) 
  into 
    l_count
  FROM
    prijave pr; 
    

    l_obj.put('count',l_count);
    l_obj.put('data',l_shows);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       --common.p_errlog('p_show_mjesta', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 201);
       ROLLBACK;    


  end p_show_prijave;
  

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
       l_obj.put('h_errcode', 202);
       ROLLBACK;    


  end p_uzmirazmatranje;


-----------------------------------------------------------------------------------------
--p_arhivirajprijavu
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
       l_obj.put('h_errcode', 203);
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
       l_obj.put('h_errcode', 204);
       ROLLBACK;    

END p_zatvoridokument;

------------------------------------------------------------------------------------
--f_checkpovjerenik
  function f_checkpovjerenik(korid in NUMBER, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_korisnici korisnici%rowtype;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_pov number;
  BEGIN

    SELECT
        IDPOVJERENIK
    INTO
        l_pov
    FROM   
        korisnici
    WHERE
        ID = korid;
        
    if(l_pov = 1) then
        return false;
    else
        return true;
    end if;    
    
    out_json := l_obj;

    
    
  EXCEPTION
    WHEN E_IZNIMKA THEN
        out_json := l_obj;
    WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_korisnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 205); 
        l_obj.put('h_errcode', 'Dogodila se greska u obradi podataka!' || SQLERRM);
        out_json := l_obj;
        return true;
  END f_checkpovjerenik;



END ADMIN;