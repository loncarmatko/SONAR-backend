create or replace NONEDITIONABLE PACKAGE BODY FILTER AS
e_iznimka exception;
------------------------------------------------------------------------------------
--f_check_korisnici
  function f_check_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_korisnici korisnici%rowtype;
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
        JSON_VALUE(l_string, '$.ID' RETURNING NUMBER),
        JSON_VALUE(l_string, '$.IDKNJIZNICA' RETURNING NUMBER),
        JSON_VALUE(l_string, '$.IME' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.PREZIME' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.EMAIL' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.SPOL' RETURNING NUMBER),
        JSON_VALUE(l_string, '$.OIB' RETURNING NUMBER),
        JSON_VALUE(l_string, '$.DATROD' RETURNING varchar2),
        JSON_VALUE(l_string, '$.SLIKA' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.IDZVANJE' RETURNING NUMBER),
        JSON_VALUE(l_string, '$.RADNOMJ' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.IDPOVJERENIK' RETURNING NUMBER)
    INTO
        l_korisnici.id,
        l_korisnici.IDKNJIZNICA,
        l_korisnici.IME,
        l_korisnici.PREZIME,
        l_korisnici.EMAIL, 
        l_korisnici.SPOL,
        l_korisnici.OIB,
        l_korisnici.DATROD,
        l_korisnici.SLIKA,
        l_korisnici.IDZVANJE,
        l_korisnici.RADNOMJ,
        l_korisnici.IDPOVJERENIK
    FROM 
       dual; 

    if (nvl(l_korisnici.IDKNJIZNICA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite knjižnicu'); 
       l_obj.put('h_errcode', 101);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.IME, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite ime'); 
       l_obj.put('h_errcode', 102);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.PREZIME, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite prezime'); 
       l_obj.put('h_errcode', 103);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.EMAIL, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite email'); 
       l_obj.put('h_errcode', 104);
       raise e_iznimka;
    end if;

  /*  if (nvl(l_korisnici.PASSWORD, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite password'); 
       l_obj.put('h_errcode', 105);
       raise e_iznimka;
    end if;
*/
    if (nvl(l_korisnici.OIB, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite OIB'); 
       l_obj.put('h_errcode', 106);
       raise e_iznimka;
    end if;

    if TO_DATE(l_korisnici.DATROD) is null  then   
       l_obj.put('h_message', 'Molimo unesite datum rođenja'); 
       l_obj.put('h_errcode', 107);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.IDZVANJE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite zvanje'); 
       l_obj.put('h_errcode', 108);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.RADNOMJ, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite radno mjesto'); 
       l_obj.put('h_errcode', 109);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.IDPOVJERENIK, 0) =0) then   
       l_obj.put('h_message', 'Molimo odaberite razinu povjerenika'); 
       l_obj.put('h_errcode', 110);
       raise e_iznimka;
    end if;


    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_korisnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 111); 
        l_obj.put('h_errcode', 'Dogodila se greska u obradi podataka!' || SQLERRM);
        out_json := l_obj;
        return true;
  END f_check_korisnici;


------------------------------------------------------------------------------------
--f_check_opci
function f_check_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_opci opci%rowtype;
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
        JSON_VALUE(l_string, '$.TIP'),
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.LINK' )
        
    INTO
        l_opci.id,
        l_opci.TIP,
        l_opci.IDKORISNIKA,
        l_opci.LINK
       
    FROM 
       dual; 

    if (nvl(l_opci.TIP, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite tip opceg dokumenta'); 
       l_obj.put('h_errcode', 112);
       raise e_iznimka;
    end if;

    if (nvl(l_opci.IDKORISNIKA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite korisnika'); 
       l_obj.put('h_errcode', 113);
       raise e_iznimka;
    end if;

    if (nvl(l_opci.LINK, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite link za dokument'); 
       l_obj.put('h_errcode', 114);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_opci',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 115);
        out_json := l_obj;
        return true;
  END f_check_opci;


------------------------------------------------------------------------------------
--f_check_dokumenti
function f_check_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_dokumenti dokumenti%rowtype;
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
        JSON_VALUE(l_string, '$.UserID'),
        JSON_VALUE(l_string, '$.IDPRAVILNIK'),
        JSON_VALUE(l_string, '$.IDPRIJAVE' ),
        JSON_VALUE(l_string, '$.LINK' ),
        JSON_VALUE(l_string, '$.DATUM' RETURNING VARCHAR2)
    INTO
        l_dokumenti.id,
        l_dokumenti.IDKORISNIKA,
        l_dokumenti.IDPRAVILNIK,
        l_dokumenti.IDPRIJAVE,
        l_dokumenti.LINK,
        l_dokumenti.DATUM
    FROM 
       dual; 

    if (nvl(l_dokumenti.IDKORISNIKA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite korisnika'); 
       l_obj.put('h_errcode', 116);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.IDPRAVILNIK, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite pravilnik'); 
       l_obj.put('h_errcode', 117);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.LINK, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite link dokumenta'); 
       l_obj.put('h_errcode', 118);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.IDPRIJAVE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite prijavu'); 
       l_obj.put('h_errcode', 119);
       raise e_iznimka;
    end if;
    
    if trunc(l_dokumenti.DATUM) is null then   
       l_obj.put('h_message', 'Molimo unesite datum dokumenta'); 
       l_obj.put('h_errcode', 120);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_dokumenti',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 121);
        out_json := l_obj;
        return true;
  END f_check_dokumenti;


END FILTER;