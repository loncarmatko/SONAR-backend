create or replace NONEDITIONABLE PACKAGE KORISNIK AS 

 procedure p_otvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_widgetkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_checkotvoreno(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_podnesiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_dokumentiprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_getkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_promjenipassword(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_showopci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_showdokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_obrisiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_getinfo(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_updateslika(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END KORISNIK;