define db_password = 'my_pw_is_very_safe_yipi_1';
DROP DATABASE LINK IF EXISTS a_link;

CREATE DATABASE LINK a_link
   CONNECT TO system IDENTIFIED BY &db_password
USING '(DESCRIPTION =
         (ADDRESS =
            (PROTOCOL = TCP)
            (HOST = 172.19.0.2)
            (PORT = 1521)
         )
         (CONNECT_DATA =
            (SERVICE_NAME = FREE)
         )
      )';

-- Verificación de la conexión
SELECT *
  FROM dual@a_link;


DROP DATABASE LINK IF EXISTS b_link;

CREATE DATABASE LINK b_link
   CONNECT TO system IDENTIFIED BY &db_password
USING '(DESCRIPTION =
         (ADDRESS =
            (PROTOCOL = TCP)
            (HOST = 172.19.0.3)
            (PORT = 1521)
         )
         (CONNECT_DATA =
            (SERVICE_NAME = FREE)
         )
      )';

-- Verificación de la conexión
SELECT *
  FROM dual@b_link;

COMMIT;