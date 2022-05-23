create or replace NONEDITIONABLE PACKAGE GRAB AS 

  procedure p_get_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END GRAB;