create or replace NONEDITIONABLE PACKAGE BODY HASH AS 
e_iznimka exception;
--------------------------------------------
  FUNCTION f_hash_pw (p_username in VARCHAR2,
                       p_password in VARCHAR2)
    RETURN VARCHAR2 AS
    l_salt VARCHAR2(30) := '!#$%&jhdfISJDF/()=?*12356890';
  BEGIN
    RETURN DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(UPPER(p_username) || l_salt || UPPER(p_password)),DBMS_CRYPTO.HASH_SH1);
  END;

    
END HASH;