create or replace NONEDITIONABLE PACKAGE FILTER AS 

  function f_check_korisnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_knjiznice(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_zupanije(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_pu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_arhiva(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_opci(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_dokumenti(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_pravilnici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_skupine(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_zvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_povjerenici(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;  
  function f_check_statusprijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;  
  function f_check_bodovizvanja(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;  

END FILTER;