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
        l_obj.put('h_errcode', 150);
        out_json := l_obj;
  END p_save_korisnici;


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
        l_obj.put('h_errcode', 151);
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
        l_obj.put('h_errcode', 152);
        out_json := l_obj;
  END p_save_dokumenti;

END CRUD;