create or replace NONEDITIONABLE PACKAGE BODY KORISNIK AS 
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
       l_obj.put('h_errcod', 300);
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
                l_obj.put('h_errcod', 299);
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
       l_obj.put('h_errcode', 301);
       ROLLBACK;
 END p_login;



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
       
    if (l_id is null) then
        SELECT
            JSON_VALUE(l_string, '$.UserID')
        INTO
            l_id
        FROM 
            dual;     
    END IF;


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
       l_obj.put('h_errcode', 302);
       ROLLBACK;    


  end p_widgetkorisnik;


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
        JSON_VALUE(l_string, '$.UserID')
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
       l_obj.put('h_errcode', 303);
       ROLLBACK;    


  end p_getkorisnik;


------------------------------------------------------------------------------------
--p_promjenipassword
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
        JSON_VALUE(l_string, '$.UserID'),
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
       l_obj.put('h_errcode', 304);
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
      l_obj.put('h_errcode', 305);
      out_json := l_obj;

END p_showopci;

-----------------------------------------------------------------------------------------
--p_getinfo
procedure p_getinfo(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_korisnik korisnici%rowtype;
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
            json_object('IDKORISNIKA' VALUE ID,
                        'IDKNJIZNICE' VALUE IDKNJIZNICA) as izlaz
                        --'NEXTID' VALUE KORISNICI_ID_SEQ.nextval
        FROM
            korisnici
        WHERE
            ID = l_korisnik.ID;
      

    BEGIN  
    l_obj := JSON_OBJECT_T(in_json);  
    l_string := in_json.TO_STRING;

    SELECT
        JSON_VALUE(l_string, '$.UserID')
    INTO
        l_korisnik.ID
    FROM 
       dual;     

    OPEN c_show;
        FETCH c_show into l_show;
        l_shows.append(JSON_OBJECT_T(l_show));
    CLOSE c_show;

    l_obj.put('povjerenik', povjerenik.f_checkpovjerenik(l_korisnik.ID, out_json));
    l_obj.put('data', l_shows);
    out_json := l_obj;

exception
      when e_iznimka then
      out_json := l_obj; 
  when others then
      --COMMON.p_errlog('p_otvoriprijavu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
      l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
      l_obj.put('h_errcode', 306);
      out_json := l_obj;

END p_getinfo;



END KORISNIK;