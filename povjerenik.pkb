create or replace NONEDITIONABLE PACKAGE BODY POVJERENIK AS
e_iznimka exception;

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
        l_obj.put('h_message', 400); 
        l_obj.put('h_errcode', 'Dogodila se greska u obradi podataka!' || SQLERRM);
        out_json := l_obj;
        return true;
  END f_checkpovjerenik;

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
       l_obj.put('h_errcode', 401);
       ROLLBACK;    


  end p_show_prijave;
  

END POVJERENIK;