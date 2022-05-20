create or replace NONEDITIONABLE PACKAGE BODY CRUD AS
e_iznimka exception;
--p_save_korisnici
-----------------------------------------------------------------------------------------
  procedure p_save_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_korisnici korisnici%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
     
     

     SELECT
        JSON_VALUE(l_string, '$.ID'),
        JSON_VALUE(l_string, '$.IDKNJIZNICA'),
        JSON_VALUE(l_string, '$.IME'),
        JSON_VALUE(l_string, '$.PREZIME'),
        JSON_VALUE(l_string, '$.EMAIL'),
        JSON_VALUE(l_string, '$.PASSWORD'),
        JSON_VALUE(l_string, '$.SPOL'),
        JSON_VALUE(l_string, '$.OIB'),
        JSON_VALUE(l_string, '$.DATROD' ),
        JSON_VALUE(l_string, '$.IDZVANJE'),
        JSON_VALUE(l_string, '$.RADNOMJ'),
        JSON_VALUE(l_string, '$.IDPOVJERENIK'),
        JSON_VALUE(l_string, '$.TITULA' ),
        JSON_VALUE(l_string, '$.ACTION')
    INTO
        l_korisnici.id,
        l_korisnici.IDKNJIZNICA,
        l_korisnici.IME,
        l_korisnici.PREZIME,
        l_korisnici.EMAIL,
        l_korisnici.PASSWORD,
        l_korisnici.SPOL,
        l_korisnici.OIB,
        l_korisnici.DATROD,
        l_korisnici.IDZVANJE,
        l_korisnici.RADNOMJ,
        l_korisnici.IDPOVJERENIK,
        l_korisnici.TITULA,
        l_action
    FROM 
       dual; 
       
    if(l_korisnici.id is null) then
        select 
            JSON_VALUE(l_string, '$.UserID')
        into
            l_korisnici.id
        from 
            dual;
    end if;
    
    --FE kontrole
   if trunc(l_action) is null then
       if (filter.f_check_korisnici(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;
    

    if (l_korisnici.id is null) then
        begin
           insert into korisnici (IDKNJIZNICA, IME, PREZIME, EMAIL, PASSWORD, SPOL, OIB, DATROD, SLIKA, IDZVANJE, RADNOMJ, IDPOVJERENIK, TITULA) values
             (l_korisnici.IDKNJIZNICA, l_korisnici.IME, l_korisnici.PREZIME,
              l_korisnici.EMAIL, hash.f_hash_pw(l_korisnici.EMAIL, l_korisnici.PASSWORD), TO_NUMBER(l_korisnici.SPOL), TO_NUMBER(l_korisnici.OIB),
              l_korisnici.DATROD, l_korisnici.SLIKA, l_korisnici.IDZVANJE, l_korisnici.RADNOMJ,
              l_korisnici.IDPOVJERENIK, l_korisnici.TITULA)
              returning id into l_korisnici.ID;
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli korisnika');
           l_obj.put('h_errcode', 0);
           l_obj.put('IDKORISNIKA', l_korisnici.ID);
           l_obj.put('IDKNJIZNICE', l_korisnici.IDKNJIZNICA);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
           l_obj.put('h_message', 'Ne uspijesno ste unijeli korisnika');
           l_obj.put('h_errcode', 2);
              
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete korisnici where id = l_korisnici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali korisnika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update korisnici 
                  set IDKNJIZNICA = l_korisnici.IDKNJIZNICA,
                      IME = l_korisnici.IME,
                      PREZIME = l_korisnici.PREZIME,
                      EMAIL = l_korisnici.EMAIL,
                      SPOL = l_korisnici.SPOL,
                      OIB = l_korisnici.OIB,
                      DATROD = l_korisnici.DATROD, 
                      IDZVANJE = l_korisnici.IDZVANJE,
                      RADNOMJ = l_korisnici.RADNOMJ,
                      IDPOVJERENIK = l_korisnici.IDPOVJERENIK,
                      TITULA = l_korisnici.TITULA
               where
                  id = l_korisnici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili korisnika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj;
     when others then
        --COMMON.p_errlog('p_save_korisnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', SQLERRM); 
        l_obj.put('h_errcode', 167 || SQLCODE);
        l_obj.put('h_error', DBMS_UTILITY.format_error_backtrace);
        out_json := l_obj;
  END p_save_korisnici;


--p_save_knjiznice
-----------------------------------------------------------------------------------------
procedure p_save_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_knjiznice knjiznice%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.ADRESA'),
        JSON_VALUE(l_string, '$.IDMJESTO'),
        JSON_VALUE(l_string, '$.EMAIL'),
        JSON_VALUE(l_string, '$.POZBRO'),
        JSON_VALUE(l_string, '$.TELBRO'),
        JSON_VALUE(l_string, '$.OIB'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_knjiznice.id,
        l_knjiznice.NAZIV,
        l_knjiznice.ADRESA,
        l_knjiznice.IDMJESTO,
        l_knjiznice.EMAIL,
        l_knjiznice.POZBRO,
        l_knjiznice.TELBRO,
        l_knjiznice.OIB,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_knjiznice(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_knjiznice.id is null) then
        begin
           insert into knjiznice(NAZIV, ADRESA, IDMJESTO, EMAIL, POZBRO, TELBRO, OIB) values
             (l_knjiznice.NAZIV, l_knjiznice.ADRESA, l_knjiznice.IDMJESTO, l_knjiznice.EMAIL,
             l_knjiznice.POZBRO, l_knjiznice.TELBRO, l_knjiznice.OIB);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli knjiznicu'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_knjiznice',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete knjiznice where id = l_knjiznice.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali knjiznicu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_knjiznice',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update knjiznice
                  set NAZIV = l_knjiznice.NAZIV,
                      ADRESA = l_knjiznice.ADRESA,
                      IDMJESTO = l_knjiznice.IDMJESTO,
                      EMAIL = l_knjiznice.EMAIL,
                      POZBRO = l_knjiznice.POZBRO,
                      TELBRO = l_knjiznice.TELBRO,
                      OIB = l_knjiznice.OIB
               where
                  id = l_knjiznice.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili knjiznicu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_knjiznice',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 168);
        out_json := l_obj;
  END p_save_knjiznice;


--p_save_mjesta
-----------------------------------------------------------------------------------------
procedure p_save_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_mjesta mjesta%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.IDZUPANIJE'),
        JSON_VALUE(l_string, '$.IDPU'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_mjesta.id,
        l_mjesta.NAZIV,
        l_mjesta.IDZUPANIJE,
        l_mjesta.IDPU,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_mjesta(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_mjesta.id is null) then
        begin
           insert into mjesta(NAZIV, IDZUPANIJE, IDPU) values
             (l_mjesta.NAZIV, l_mjesta.IDZUPANIJE, l_mjesta.IDPU);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli mjesto'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete mjesta where id = l_mjesta.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali mjesto'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update mjesta
                  set NAZIV = l_mjesta.NAZIV,
                      IDZUPANIJE = l_mjesta.IDZUPANIJE,
                      IDPU = l_mjesta.IDPU
               where
                  id = l_mjesta.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili mjesto'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_mjesta',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 169);
        out_json := l_obj;
  END p_save_mjesta;


--p_save_zupanije
-----------------------------------------------------------------------------------------
procedure p_save_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_zupanije zupanije%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.SIFRA'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_zupanije.id,
        l_zupanije.NAZIV,
        l_zupanije.SIFRA,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_zupanije(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_zupanije.id is null) then
        begin
           insert into zupanije(NAZIV, SIFRA) values
             (l_zupanije.NAZIV, l_zupanije.SIFRA);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli zupaniju'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete zupanije where id = l_zupanije.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali zupaniju'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update zupanije
                  set NAZIV = l_zupanije.NAZIV,
                      SIFRA = l_zupanije.SIFRA
               where
                  id = l_zupanije.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili naziv'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_zupanije',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 170);
        out_json := l_obj;
  END p_save_zupanije;


--p_save_pu
-----------------------------------------------------------------------------------------
procedure p_save_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_pu pu%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.BROJ'),
        JSON_VALUE(l_string, '$.NAZIV' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_pu.id,
        l_pu.BROJ,
        l_pu.NAZIV,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_pu(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_pu.id is null) then
        begin
           insert into pu(BROJ, NAZIV) values
             (l_pu.BROJ, l_pu.NAZIV);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli postanski ured'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete pu where id = l_pu.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali postanski ured'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update pu
                  set BROJ = l_pu.BROJ,
                      NAZIV = l_pu.NAZIV
               where
                  id = l_pu.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili postanski ured'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_pu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 171);
        out_json := l_obj;
  END p_save_pu;


--p_save_arhiva
-----------------------------------------------------------------------------------------
procedure p_save_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_arhiva arhiva%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.HISTORY' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_arhiva.id,
        l_arhiva.IDKORISNIKA,
        l_arhiva.HISTORY,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_arhiva(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_arhiva.id is null) then
        begin
           insert into arhiva(IDKORISNIKA, HISTORY) values
             (l_arhiva.IDKORISNIKA, l_arhiva.HISTORY);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli arhivu'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete arhiva where id = l_arhiva.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali arhivu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update arhiva
                  set IDKORISNIKA = l_arhiva.IDKORISNIKA,
                      HISTORY = l_arhiva.HISTORY
               where
                  id = l_arhiva.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili arhivu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_arhiva',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 172);
        out_json := l_obj;
  END p_save_arhiva;


--p_save_opci
-----------------------------------------------------------------------------------------
procedure p_save_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_opci opci%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.TIP'),
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.LINK' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_opci.id,
        l_opci.TIP,
        l_opci.IDKORISNIKA,
        l_opci.LINK,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_opci(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_opci.id is null) then
        begin
           insert into opci(TIP, IDKORISNIKA, LINK) values
             (l_opci.TIP, l_opci.IDKORISNIKA, l_opci.LINK);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli opci dokument'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete opci where id = l_opci.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali opci dokument'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update opci
                  set TIP = l_opci.TIP,
                      IDKORISNIKA = l_opci.IDKORISNIKA,
                      LINK = l_opci.LINK
               where
                  id = l_opci.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili opce dokumente'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_opci',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 173);
        out_json := l_obj;
  END p_save_opci;


--p_save_dokumenti
-----------------------------------------------------------------------------------------
procedure p_save_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_dokumenti dokumenti%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.UserID'),
        JSON_VALUE(l_string, '$.IDPRAVILNIK'),
        JSON_VALUE(l_string, '$.IDPRIJAVE' ),
        JSON_VALUE(l_string, '$.LINK' ),
        JSON_VALUE(l_string, '$.DATUM'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_dokumenti.id,
        l_dokumenti.IDKORISNIKA,
        l_dokumenti.IDPRAVILNIK,
        l_dokumenti.IDPRIJAVE,
        l_dokumenti.LINK,
        l_dokumenti.DATUM,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_dokumenti(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_dokumenti.id is null) then
        begin
           insert into dokumenti(IDKORISNIKA, IDPRAVILNIK, IDPRIJAVE, LINK, DATUM) values
             (l_dokumenti.IDKORISNIKA, l_dokumenti.IDPRAVILNIK, l_dokumenti.IDPRIJAVE, l_dokumenti.LINK, l_dokumenti.DATUM);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli dokument'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete dokumenti where id = l_dokumenti.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali dokument'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update dokumenti
                  set IDKORISNIKA = l_dokumenti.IDKORISNIKA,
                      IDPRAVILNIK = l_dokumenti.IDPRAVILNIK,
                      IDPRIJAVE = l_dokumenti.IDPRIJAVE,
                      LINK = l_dokumenti.LINK,
                      DATUM = l_dokumenti.DATUM
               where
                  id = l_dokumenti.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili dokument'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_dokumenti',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 174);
        out_json := l_obj;
  END p_save_dokumenti;


--p_save_pravilnici
-----------------------------------------------------------------------------------------
procedure p_save_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_pravilnici pravilnici%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.IDSKUPINE'),
        JSON_VALUE(l_string, '$.RBR'),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.BODOVI' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_pravilnici.id,
        l_pravilnici.IDSKUPINE,
        l_pravilnici.RBR,
        l_pravilnici.NAZIV,
        l_pravilnici.BODOVI,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_pravilnici(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_pravilnici.id is null) then
        begin
           insert into pravilnici(IDSKUPINE, RBR, NAZIV, BODOVI) values
             (l_pravilnici.IDSKUPINE, l_pravilnici.RBR, l_pravilnici.NAZIV, l_pravilnici.BODOVI);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli pravilnik'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete pravilnici where id = l_pravilnici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali pravilnik'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update pravilnici
                  set IDSKUPINE = l_pravilnici.IDSKUPINE,
                      RBR = l_pravilnici.RBR,
                      NAZIV = l_pravilnici.NAZIV,
                      BODOVI = l_pravilnici.BODOVI
               where
                  id = l_pravilnici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili pravilnik'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_pravilnici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 175);
        out_json := l_obj;
  END p_save_pravilnici;


--p_save_skupine
-----------------------------------------------------------------------------------------
procedure p_save_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_skupine skupine%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.NAPOMENA'),        
        JSON_VALUE(l_string, '$.MAXBODOVI' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_skupine.id,
        l_skupine.NAZIV,
        l_skupine.NAPOMENA,
        l_skupine.MAXBODOVI,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_skupine(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_skupine.id is null) then
        begin
           insert into skupine(NAZIV, NAPOMENA, MAXBODOVI) values
             (l_skupine.NAZIV, l_skupine.NAPOMENA, l_skupine.MAXBODOVI);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli skupinu'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete skupine where id = l_skupine.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali skupinu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update skupine
                  set NAZIV = l_skupine.NAZIV,
                      NAPOMENA = l_skupine.NAPOMENA,
                      MAXBODOVI = l_skupine.MAXBODOVI
               where
                  id = l_skupine.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili skupinu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_skupine',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 176);
        out_json := l_obj;
  END p_save_skupine;


--p_save_prijave
-----------------------------------------------------------------------------------------
procedure p_save_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_prijave prijave%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.IDKORISNIKA'),
        JSON_VALUE(l_string, '$.PODNESENO'),
        JSON_VALUE(l_string, '$.IDZVANJE'),
        JSON_VALUE(l_string, '$.IDSTATUSPRIJAVE'),
        JSON_VALUE(l_string, '$.IDPOVJERENIK'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_prijave.id,
        l_prijave.IDKORISNIKA,
        l_prijave.PODNESENO,
        l_prijave.IDZVANJE,
        l_prijave.IDSTATUSPRIJAVE,
        l_prijave.IDPOVJERENIK,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_prijave(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_prijave.id is null) then
        begin
           insert into prijave(IDKORISNIKA, PODNESENO, IDZVANJE, IDSTATUSPRIJAVE, IDPOVJERENIK) values
             (l_prijave.IDKORISNIKA, l_prijave.PODNESENO, l_prijave.IDZVANJE, l_prijave.IDSTATUSPRIJAVE, l_prijave.IDPOVJERENIK);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli prijavu'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete prijave where id = l_prijave.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali prijavu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update prijave
                  set IDKORISNIKA = l_prijave.IDKORISNIKA,
                      PODNESENO = l_prijave.PODNESENO,
                      IDZVANJE = l_prijave.IDZVANJE,
                      IDSTATUSPRIJAVE = l_prijave.IDSTATUSPRIJAVE,
                      IDPOVJERENIK = l_prijave.IDPOVJERENIK
               where
                  id = l_prijave.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili prijavu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_prijave',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 177);
        out_json := l_obj;
  END p_save_prijave;


--p_save_zvanja
-----------------------------------------------------------------------------------------
procedure p_save_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_zvanja zvanja%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_zvanja.id,
        l_zvanja.NAZIV,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_zvanja(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_zvanja.id is null) then
        begin
           insert into zvanja(NAZIV) values
             (l_zvanja.NAZIV);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli zvanje'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete zvanja where id = l_zvanja.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali zvanje'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update zvanja
                  set NAZIV = l_zvanja.NAZIV
               where
                  id = l_zvanja.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili zvanje'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_zvanja',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 178);
        out_json := l_obj;
  END p_save_zvanja;


--p_save_povjerenici
-----------------------------------------------------------------------------------------
procedure p_save_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_povjerenici povjerenici%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_povjerenici.id,
        l_povjerenici.NAZIV,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_povjerenici(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_povjerenici.id is null) then
        begin
           insert into povjerenici(NAZIV) values
             (l_povjerenici.NAZIV);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli razinu povjerenika'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete povjerenici where id = l_povjerenici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali razinu povjerenika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update povjerenici
                  set NAZIV = l_povjerenici.NAZIV
               where
                  id = l_povjerenici.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili povjerenika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_povjerenici',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 179);
        out_json := l_obj;
  END p_save_povjerenici;

--p_save_statusprijave
-----------------------------------------------------------------------------------------
procedure p_save_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_statusprijave statusprijave%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

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

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_statusprijave(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_statusprijave.id is null) then
        begin
           insert into statusprijave(NAZIV) values
             (l_statusprijave.NAZIV);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli status prijave'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete statusprijave where id = l_statusprijave.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali status prijave'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update statusprijave
                  set NAZIV = l_statusprijave.NAZIV
               where
                  id = l_statusprijave.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili status priajve'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_statusprijave',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 180);
        out_json := l_obj;
  END p_save_statusprijave;
  
  -- p_save_bodovizvanja

procedure p_save_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_bodovizvanja bodovizvanja%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin

     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;

     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.IDSKUPINE'),
        JSON_VALUE(l_string, '$.IDZVANJA' ),
        JSON_VALUE(l_string, '$.BODOVI' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_bodovizvanja.id,
        l_bodovizvanja.IDSKUPINE,
        l_bodovizvanja.IDZVANJA,
        l_bodovizvanja.BODOVI,
        l_action
    FROM 
       dual; 

    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_pu(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;

    if (l_bodovizvanja.id is null) then
        begin
           insert into bodovizvanja(IDSKUPINE, IDZVANJA, BODOVI) values
             (l_bodovizvanja.IDSKUPINE, l_bodovizvanja.IDZVANJA, l_bodovizvanja.BODOVI);
           commit;

           l_obj.put('h_message', 'Uspješno ste unijeli bodove zvanja'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;

        exception
           when others then 
              -- COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete bodovizvanja where id = l_bodovizvanja.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste obrisali bodove zvanja'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;

       else

           begin
               update bodovizvanja
                  set IDSKUPINE = l_bodovizvanja.IDSKUPINE,
                      IDZVANJA = l_bodovizvanja.IDZVANJA
               where
                  id = l_bodovizvanja.id;
               commit;    

               l_obj.put('h_message', 'Uspješno ste promijenili bodove zvanja'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   --COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;


  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        --COMMON.p_errlog('p_save_pu',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!' || dbms_utility.format_error_backtrace || SQLERRM); 
        l_obj.put('h_errcode', 181);
        out_json := l_obj;
  END p_save_bodovizvanja;




END CRUD;