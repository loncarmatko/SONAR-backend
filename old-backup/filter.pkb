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
/*    if (nvl(l_korisnici.SPOL, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite šta ste'); 
       l_obj.put('h_errcode', 106);
       raise e_iznimka;
    end if;
*/
    if (nvl(l_korisnici.OIB, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite OIB'); 
       l_obj.put('h_errcode', 107);
       raise e_iznimka;
    end if;

    if TO_DATE(l_korisnici.DATROD) is null  then   
       l_obj.put('h_message', 'Molimo unesite datum rođenja'); 
       l_obj.put('h_errcode', 108);
       raise e_iznimka;
    end if;

/*    if (nvl(l_korisnici.SLIKA, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo odaberite sliku'); 
       l_obj.put('h_errcode', 109);
       raise e_iznimka;
    end if;
*/
    if (nvl(l_korisnici.IDZVANJE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite zvanje'); 
       l_obj.put('h_errcode', 110);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.RADNOMJ, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite radno mjesto'); 
       l_obj.put('h_errcode', 111);
       raise e_iznimka;
    end if;

    if (nvl(l_korisnici.IDPOVJERENIK, 0) =0) then   
       l_obj.put('h_message', 'Molimo odaberite razinu povjerenika'); 
       l_obj.put('h_errcode', 112);
       raise e_iznimka;
    end if;


    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_korisnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 114); 
        l_obj.put('h_errcode', 'Dogodila se greska u obradi podataka!' || SQLERRM);
        out_json := l_obj;
        return true;
  END f_check_korisnici;


------------------------------------------------------------------------------------
--f_check_knjiznice
function f_check_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_knjiznice knjiznice%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.ADRESA'),
        JSON_VALUE(l_string, '$.IDMJESTO'),
        JSON_VALUE(l_string, '$.EMAIL'),
        JSON_VALUE(l_string, '$.POZBRO'),
        JSON_VALUE(l_string, '$.TELBRO' ),
        JSON_VALUE(l_string, '$.OIB' )
    INTO
        l_knjiznice.id,
        l_knjiznice.NAZIV,
        l_knjiznice.ADRESA,
        l_knjiznice.IDMJESTO,
        l_knjiznice.EMAIL,
        l_knjiznice.POZBRO,
        l_knjiznice.TELBRO,
        l_knjiznice.OIB
    FROM 
       dual; 

    if (nvl(l_knjiznice.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv knjižnice'); 
       l_obj.put('h_errcode', 115);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.ADRESA, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite adresu knjižnice'); 
       l_obj.put('h_errcode', 116);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.IDMJESTO, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite mjesto knjižnice'); 
       l_obj.put('h_errcode', 117);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.EMAIL, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite email knjižnice'); 
       l_obj.put('h_errcode', 118);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.POZBRO, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite pozivni broj knjižnice'); 
       l_obj.put('h_errcode', 119);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.TELBRO, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite telefonski broj knjižnice'); 
       l_obj.put('h_errcode', 120);
       raise e_iznimka;
    end if;

    if (nvl(l_knjiznice.OIB, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite OIB knjižnice'); 
       l_obj.put('h_errcode', 121);
       raise e_iznimka;
    end if;
    
    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_knjiznice',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 122);
        out_json := l_obj;
        return true;
  END f_check_knjiznice;


------------------------------------------------------------------------------------
--f_check_mjesta
function f_check_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_mjesta mjesta%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.IDZUPANIJE'),
        JSON_VALUE(l_string, '$.IDPU')
    INTO
        l_mjesta.id,
        l_mjesta.NAZIV,
        l_mjesta.IDZUPANIJE,
        l_mjesta.IDPU
    FROM 
       dual; 

    if (nvl(l_mjesta.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv mjesta'); 
       l_obj.put('h_errcode', 123);
       raise e_iznimka;
    end if;

    if (nvl(l_mjesta.IDZUPANIJE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite županiju mjesta'); 
       l_obj.put('h_errcode', 124);
       raise e_iznimka;
    end if;

    if (nvl(l_mjesta.IDPU, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite poštanski ured mjesta'); 
       l_obj.put('h_errcode', 125);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_mjesta',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 126);
        out_json := l_obj;
        return true;
  END f_check_mjesta;


------------------------------------------------------------------------------------
--f_check_zupanije 
function f_check_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_zupanije zupanije%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.SIFRA')
    INTO
        l_zupanije.id,
        l_zupanije.NAZIV,
        l_zupanije.SIFRA
    FROM 
       dual; 

    if (nvl(l_zupanije.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv županije'); 
       l_obj.put('h_errcode', 127);
       raise e_iznimka;
    end if;

    if (nvl(l_zupanije.SIFRA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite šifru poštanskog ureda'); 
       l_obj.put('h_errcode', 128);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_zupanije',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 129);
        out_json := l_obj;
        return true;
  END f_check_zupanije;


------------------------------------------------------------------------------------
--f_check_pu
function f_check_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_pu pu%rowtype;
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
        JSON_VALUE(l_string, '$.BROJ'),
        JSON_VALUE(l_string, '$.NAZIV' )
    INTO
        l_pu.id,
        l_pu.BROJ,
        l_pu.NAZIV
    FROM 
       dual; 

    if (nvl(l_pu.BROJ, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite broj poštanskog ureda'); 
       l_obj.put('h_errcode', 130);
       raise e_iznimka;
    end if;

    if (nvl(l_pu.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv poštanskog ureda'); 
       l_obj.put('h_errcode', 131);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_pu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 132);
        out_json := l_obj;
        return true;
  END f_check_pu;


------------------------------------------------------------------------------------
--f_check_arhiva
function f_check_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_arhiva arhiva%rowtype;
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
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.HISTORY' )
    INTO
        l_arhiva.id,
        l_arhiva.IDKORISNIKA,
        l_arhiva.HISTORY
    FROM 
       dual; 

    if (nvl(l_arhiva.IDKORISNIKA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite korisnika'); 
       l_obj.put('h_errcode', 133);
       raise e_iznimka;
    end if;

    if (nvl(l_arhiva.HISTORY, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite arhivu'); 
       l_obj.put('h_errcode', 134);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_arhiva',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 135);
        out_json := l_obj;
        return true;
  END f_check_arhiva;


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
       l_obj.put('h_errcode', 136);
       raise e_iznimka;
    end if;

    if (nvl(l_opci.IDKORISNIKA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite korisnika'); 
       l_obj.put('h_errcode', 137);
       raise e_iznimka;
    end if;

    if (nvl(l_opci.LINK, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite link za dokument'); 
       l_obj.put('h_errcode', 138);
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
        l_obj.put('h_errcode', 140);
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
       l_obj.put('h_errcode', 141);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.IDPRAVILNIK, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite pravilnik'); 
       l_obj.put('h_errcode', 142);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.LINK, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite link dokumenta'); 
       l_obj.put('h_errcode', 143);
       raise e_iznimka;
    end if;

    if (nvl(l_dokumenti.IDPRIJAVE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite prijavu'); 
       l_obj.put('h_errcode', 144);
       raise e_iznimka;
    end if;
    
    if trunc(l_dokumenti.DATUM) is null then   
       l_obj.put('h_message', 'Molimo unesite datum dokumenta'); 
       l_obj.put('h_errcode', 145);
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
        l_obj.put('h_errcode', 146);
        out_json := l_obj;
        return true;
  END f_check_dokumenti;


------------------------------------------------------------------------------------
--f_check_pravilnici
function f_check_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_pravilnici pravilnici%rowtype;
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
        JSON_VALUE(l_string, '$.IDSKUPINE'),
        JSON_VALUE(l_string, '$.RBR'),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.BODOVI' )
    INTO
        l_pravilnici.id,
        l_pravilnici.IDSKUPINE,
        l_pravilnici.RBR,
        l_pravilnici.NAZIV,
        l_pravilnici.BODOVI
    FROM 
       dual; 

    if (nvl(l_pravilnici.IDSKUPINE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite skupina pravilnika'); 
       l_obj.put('h_errcode', 147);
       raise e_iznimka;
    end if;

    if (nvl(l_pravilnici.RBR, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite redni broj pravilnika'); 
       l_obj.put('h_errcode', 148);
       raise e_iznimka;
    end if;

    if (nvl(l_pravilnici.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv pravilnika'); 
       l_obj.put('h_errcode', 149);
       raise e_iznimka;
    end if;

    if (nvl(l_pravilnici.BODOVI, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite bodove pravilnika'); 
       l_obj.put('h_errcode', 150);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_pravilnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 151);
        out_json := l_obj;
        return true;
  END f_check_pravilnici;


------------------------------------------------------------------------------------
--f_check_skupine
function f_check_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_skupine skupine%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.NAPOMENA'),        
        JSON_VALUE(l_string, '$.MAXBODOVI' )
    INTO
        l_skupine.id,
        l_skupine.NAZIV,
        l_skupine.NAPOMENA,
        l_skupine.MAXBODOVI
    FROM 
       dual; 

    if (nvl(l_skupine.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv skupine'); 
       l_obj.put('h_errcode', 152);
       raise e_iznimka;
    end if;

    if (nvl(l_skupine.NAPOMENA, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite napomenu za skupinu'); 
       l_obj.put('h_errcode', 153);
       raise e_iznimka;
    end if;

    if (nvl(l_skupine.MAXBODOVI, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite maksimalan broj bodova za skupinu'); 
       l_obj.put('h_errcode', 154);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_skupine',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 155);
        out_json := l_obj;
        return true;
  END f_check_skupine;


------------------------------------------------------------------------------------
--f_check_prijave
function f_check_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
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
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.PODNESENO'),
        JSON_VALUE(l_string, '$.IDZVANJE'),
        JSON_VALUE(l_string, '$.IDSTATUSPRIJAVE')
    INTO
        l_prijave.id,
        l_prijave.IDKORISNIKA,
        l_prijave.PODNESENO,
        l_prijave.IDZVANJE,
        l_prijave.IDSTATUSPRIJAVE
    FROM 
       dual; 

    if (nvl(l_prijave.IDKORISNIKA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite korisnika koji podnosi prijavu'); 
       l_obj.put('h_errcode', 156);
       raise e_iznimka;
    end if;

    if trunc(l_prijave.PODNESENO) is null then   
       l_obj.put('h_message', 'Molimo unesite datum podnosenja prijave'); 
       l_obj.put('h_errcode', 157);
       raise e_iznimka;
    end if;

    if (nvl(l_prijave.IDZVANJE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite zvanje'); 
       l_obj.put('h_errcode', 158);
       raise e_iznimka;
    end if;

    if (nvl(l_prijave.IDSTATUSPRIJAVE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo odaberite status prijave'); 
       l_obj.put('h_errcode', 159);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_prijave',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 160);
        out_json := l_obj;
        return true;
  END f_check_prijave;


------------------------------------------------------------------------------------
--f_check_zvanja
function f_check_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_zvanja zvanja%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV')
    INTO
        l_zvanja.id,
        l_zvanja.NAZIV
    FROM 
       dual; 

    if (nvl(l_zvanja.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite zvanje'); 
       l_obj.put('h_errcode', 161);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_zvanja',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 162);
        out_json := l_obj;
        return true;
  END f_check_zvanja;


------------------------------------------------------------------------------------
--f_check_povjerenici
function f_check_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_povjerenici povjerenici%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV')
    INTO
        l_povjerenici.id,
        l_povjerenici.NAZIV
    FROM 
       dual; 

    if (nvl(l_povjerenici.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite razinu povjerenika'); 
       l_obj.put('h_errcode', 163);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_povjerenici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 164);
        out_json := l_obj;
        return true;
  END f_check_povjerenici;

------------------------------------------------------------------------------------
--f_check_statusprijave
function f_check_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_statusprijave statusprijave%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV')
    INTO
        l_statusprijave.id,
        l_statusprijave.NAZIV
    FROM 
       dual; 

    if (nvl(l_statusprijave.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite status prijave'); 
       l_obj.put('h_errcode', 165);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_statusprijave',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 166);
        out_json := l_obj;
        return true;
  END f_check_statusprijave;
  
  --f_check_bodovizvanja
function f_check_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_bodovizvanja bodovizvanja%rowtype;
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
        JSON_VALUE(l_string, '$.IDSKUPINE'),
        JSON_VALUE(l_string, '$.IDZVANJA' ),
        JSON_VALUE(l_string, '$.BODOVI' )
    INTO
        l_bodovizvanja.id,
        l_bodovizvanja.IDSKUPINE,
        l_bodovizvanja.IDZVANJA,
        l_bodovizvanja.BODOVI
    FROM 
       dual; 

    if (nvl(l_bodovizvanja.IDSKUPINE, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite id skupine'); 
       l_obj.put('h_errcode', 167);
       raise e_iznimka;
    end if;

    if (nvl(l_bodovizvanja.IDZVANJA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite id zvanja'); 
       l_obj.put('h_errcode', 168);
       raise e_iznimka;
    end if;

    if (nvl(l_bodovizvanja.BODOVI, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite broj bodova'); 
       l_obj.put('h_errcode', 169);
       raise e_iznimka;
    end if;

    out_json := l_obj;
    return false;

  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        --COMMON.p_errlog('p_check_bodovizvanja',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greska u obradi podataka!'); 
        l_obj.put('h_errcode', 170);
        out_json := l_obj;
        return true;
  END f_check_bodovizvanja;


END FILTER;