DROP PUBLIC DATABASE LINK b_link;
CREATE PUBLIC DATABASE LINK b_link
   CONNECT TO "postgres" IDENTIFIED BY "my_pw_is_very_safe_yipi_1"
   USING 'bankpostgres';

-- Verificación de la conexión
SELECT *
  FROM sucursal@b_link;

COMMIT;