create or replace NONEDITIONABLE PACKAGE ADMIN AS

 procedure p_show_mjesta(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_show_prijave(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_uzmirazmatranje(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_zatvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_zatvoridokument(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 
END ADMIN;