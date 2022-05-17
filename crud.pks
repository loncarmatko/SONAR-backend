create or replace NONEDITIONABLE PACKAGE CRUD AS 

 procedure p_save_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END CRUD;
