create or replace NONEDITIONABLE PACKAGE BODY router AS
    e_iznimka EXCEPTION;

  procedure p_main(p_in in varchar2, p_out out varchar2) AS
    l_obj JSON_OBJECT_T;
    l_procedura varchar2(40);
  BEGIN
    l_obj := JSON_OBJECT_T(p_in);

    SELECT
        JSON_VALUE(p_in, '$.procedura' RETURNING VARCHAR2)
    INTO
        l_procedura
    FROM DUAL;

    CASE l_procedura
    WHEN 'p_login' THEN
        grab.p_login(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_korisnici' THEN
        grab.p_get_korisnici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_knjiznice' THEN
        grab.p_get_knjiznice(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_mjesta' THEN
        grab.p_get_mjesta(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_zupanije' THEN
        grab.p_get_zupanije(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_pu' THEN
        grab.p_get_pu(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_arhiva' THEN
        grab.p_get_arhiva(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_opci' THEN
        grab.p_get_opci(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_dokumenti' THEN
        grab.p_get_dokumenti(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_pravilnici' THEN
        grab.p_get_pravilnici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_skupine' THEN
        grab.p_get_skupine(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_prijave' THEN
        grab.p_get_prijave(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_zvanja' THEN
        grab.p_get_zvanja(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_povjerenici' THEN
        grab.p_get_povjerenici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_bodovizvanja' THEN
        grab.p_get_bodovizvanja(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_korisnici' THEN
        crud.p_save_korisnici(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_knjiznice' THEN
        crud.p_save_knjiznice(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_mjesta' THEN
        crud.p_save_mjesta(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_zupanije' THEN
        crud.p_save_zupanije(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_pu' THEN
        crud.p_save_pu(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_arhiva' THEN
        crud.p_save_arhiva(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_opci' THEN
        crud.p_save_opci(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_dokumenti' THEN
        crud.p_save_dokumenti(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_pravilnici' THEN
        crud.p_save_pravilnici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_skupine' THEN
        crud.p_save_skupine(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_prijave' THEN
        crud.p_save_prijave(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_zvanja' THEN
        crud.p_save_zvanja(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_povjerenici' THEN
        crud.p_save_povjerenici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_bodovizvanja' THEN
        crud.p_save_bodovizvanja(JSON_OBJECT_T(p_in), l_obj);    
    WHEN 'p_show_mjesta' THEN
        admin.p_show_mjesta(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_show_prijave' THEN
        admin.p_show_prijave(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_uzmirazmatranje' THEN
        admin.p_uzmirazmatranje(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_zatvoriprijavu' THEN
        admin.p_zatvoriprijavu(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_zatvoridokument' THEN
        admin.p_zatvoridokument(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_otvoriprijavu' THEN
        korisnik.p_otvoriprijavu(JSON_OBJECT_T(p_in), l_obj); 
    WHEN 'p_checkotvoreno' THEN
        korisnik.p_checkotvoreno(JSON_OBJECT_T(p_in), l_obj); 
    WHEN 'p_podnesiprijavu' THEN
        korisnik.p_podnesiprijavu(JSON_OBJECT_T(p_in), l_obj); 
    WHEN 'p_widgetkorisnik' THEN
        korisnik.p_widgetkorisnik(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_dokumentiprijave' THEN
        korisnik.p_dokumentiprijave(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_getkorisnik' THEN
        korisnik.p_getkorisnik(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_promjenipassword' THEN
        korisnik.p_promjenipassword(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_showopci' THEN
        korisnik.p_showopci(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_showdokumenti' THEN
        korisnik.p_showdokumenti(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_obrisiprijavu' THEN
        korisnik.p_obrisiprijavu(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_getinfo' THEN
        korisnik.p_getinfo(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_arhivirajprijavu' THEN
        prijavearhiva.p_arhivirajprijavu(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_procitajarhivu' THEN
        prijavearhiva.p_procitajarhivu(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_procitajstavku' THEN
        prijavearhiva.p_procitajstavku(JSON_OBJECT_T(p_in), l_obj);  

    ELSE
        l_obj.put('h_message', ' Nepoznata metoda ' || l_procedura);
        l_obj.put('h_errcode', 997);
    END CASE;
    p_out := l_obj.TO_STRING;
  END p_main;

END router;