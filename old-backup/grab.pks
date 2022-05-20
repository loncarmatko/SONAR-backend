create or replace NONEDITIONABLE PACKAGE GRAB AS 

  procedure p_login(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);


END GRAB;