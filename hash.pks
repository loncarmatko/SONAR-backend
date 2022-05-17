create or replace NONEDITIONABLE PACKAGE HASH AS 

  function f_hash_pw(p_username in varchar2, p_password in varchar2) return varchar2;

END HASH;