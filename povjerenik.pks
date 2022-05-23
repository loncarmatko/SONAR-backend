create or replace NONEDITIONABLE PACKAGE POVJERENIK AS

 function f_checkpovjerenik(korid in NUMBER, out_json out JSON_OBJECT_T) return boolean;
 procedure p_show_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END POVJERENIK;