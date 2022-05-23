create or replace NONEDITIONABLE PACKAGE KORISNIK AS 

 procedure p_login(in_json in json_object_t, out_json out json_object_t);
 procedure p_widgetkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_getkorisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_promjenipassword(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_showopci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_getinfo(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);

END KORISNIK;