CREATE OR REPLACE NONEDITIONABLE PACKAGE CONTROLPRIJAVE AS

 procedure p_uzmirazmatranje(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_zatvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_zatvoridokument(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_checkotvoreno(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_podnesiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_otvoriprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_obrisiprijavu(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);

END CONTROLPRIJAVE;