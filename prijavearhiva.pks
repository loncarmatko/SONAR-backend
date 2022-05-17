create or replace NONEDITIONABLE PACKAGE PRIJAVEARHIVA AS 

 procedure p_arhivirajprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_procitajstavku(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_procitajarhivu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);

END PRIJAVEARHIVA;