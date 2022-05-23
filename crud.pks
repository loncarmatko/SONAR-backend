create or replace NONEDITIONABLE PACKAGE CRUD AS 

 procedure p_save_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END CRUD;
