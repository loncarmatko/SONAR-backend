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
    WHEN 'p_uzmirazmatranje' THEN
        controlprijave.p_uzmirazmatranje(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_zatvoriprijavu' THEN
        controlprijave.p_zatvoriprijavu(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_zatvoridokument' THEN
        controlprijave.p_zatvoridokument(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_checkotvoreno' THEN
        controlprijave.p_checkotvoreno(JSON_OBJECT_T(p_in), l_obj); 
    WHEN 'p_podnesiprijavu' THEN
        controlprijave.p_podnesiprijavu(JSON_OBJECT_T(p_in), l_obj);     
    WHEN 'p_obrisiprijavu' THEN
        controlprijave.p_obrisiprijavu(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_korisnici' THEN
        grab.p_get_korisnici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_knjiznice' THEN
        grab.p_get_knjiznice(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_pravilnici' THEN
        grab.p_get_pravilnici(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_skupine' THEN
        grab.p_get_skupine(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_zvanja' THEN
        grab.p_get_zvanja(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_korisnici' THEN
        crud.p_save_korisnici(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_opci' THEN
        crud.p_save_opci(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_save_dokumenti' THEN
        crud.p_save_dokumenti(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_show_prijave' THEN
        povjerenik.p_show_prijave(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_login' THEN
        korisnik.p_login(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_widgetkorisnik' THEN
        korisnik.p_widgetkorisnik(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_getkorisnik' THEN
        korisnik.p_getkorisnik(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_promjenipassword' THEN
        korisnik.p_promjenipassword(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_showopci' THEN
        korisnik.p_showopci(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_getinfo' THEN
        korisnik.p_getinfo(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_procitajarhivu' THEN
        readarhiva.p_procitajarhivu(JSON_OBJECT_T(p_in), l_obj);  
    WHEN 'p_procitajstavku' THEN
        readarhiva.p_procitajstavku(JSON_OBJECT_T(p_in), l_obj);  

    ELSE
        l_obj.put('h_message', ' Nepoznata metoda ' || l_procedura);
        l_obj.put('h_errcode', 997);
    END CASE;
    p_out := l_obj.TO_STRING;
  END p_main;

END router;