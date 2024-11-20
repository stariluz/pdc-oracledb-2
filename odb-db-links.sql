drop database link b_link;
create database link b_link
   connect to "postgres" identified by "my_pw_is_very_safe_yipi_1"
using 'bankpostgres';

-- Verificación de la conexión
SELECT * FROM "public"."dual"@B_LINK;

SELECT * FROM all_db_links WHERE db_link = 'B_LINK';
