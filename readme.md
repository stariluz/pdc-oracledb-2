# Oracle Database. Conexión distribuida 

Proyecto básico para la conexión de instancias de Oracle Database Free [ejecutadas en
contenedores de docker] mediante el uso de **Database Links**.

### Descripción.

El proyecto supone un banco con diversas sucursales.

### Prerequisitos
- Docker
- Necesitas un archivo `.env` en la ruta del repositorio con las siguientes variables.
  Tu asignas tus propios valores.
  ```sh
  # Password del usuario system de la base de datos a crear
  ORACLE_PWD=este_es_el_password_UwU
  ```

### 1. Crear red

```sh
docker network create bank-network
```

#### 2. Descargar imagenes
```sh
docker pull container-registry.oracle.com/database/express:21.3.0-xe
docker pull postgres
```
### 3. Crear contenedores

```sh
docker stop bnk-branch-A-odb
docker rm bnk-branch-A-odb
docker run -dti --name bnk-branch-A-odb \
--network bank-network \
-p 1521:1521 \
--env-file .env \
container-registry.oracle.com/database/express:21.3.0-xe

docker stop bnk-branch-B-odb
docker rm bnk-branch-B-odb
docker run -dti --name bnk-branch-B-odb \
--network bank-network \
-p 1522:1521 \
--env-file .env \
postgres

docker stop bnk-branch-B-odb
docker rm bnk-branch-B-odb
docker run -dti --name bnk-branch-B-odb \
--network bank-network \
-p 5432:5432 \
--env-file .env postgres

```
```sh
docker exec -ti bnk-branch-B-odb psql --username=postgres -W
CREATE DATABASE bank;
```
#### postgres container
```sh
docker exec -ti bnk-branch-B-odb sh
echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
echo "host    all    all    172.19.0.2/16    md5" >> /var/lib/postgresql/data/pg_hba.conf
cat /var/lib/postgresql/data/pg_hba.conf

su postgres
pg_ctl reload
exit
```

#### oracledb container
```sh
docker exec -ti bnk-branch-A-odb sh
yum install -y unixODBC postgresql-odbc

echo "[bankpostgres]
Description     = Bank Branch B
Driver          = /usr/lib64/psqlodbc.so
Servername      = 172.19.0.3
Port            = 5432
Database        = bank
Username        = postgres
Password        = my_pw_is_very_safe_yipi_1
[default]
Driver          = liboplodbcS.so.2
" > /etc/odbc.ini

lsnrctl stop
lsnrctl start

touch /opt/oracle/product/21c/dbhomeXE/hs/admin/initbankpostgres.ora
echo "# HS parameters that are needed for the Database Gateway for ODBC

#
# HS init parameters
#
HS_FDS_CONNECT_INFO = bankpostgres
HS_FDS_TRACE_LEVEL = on
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbc.so

#
# ODBC specific environment variables
#
set ODBCINI=/etc/odbc.ini

#
# Environment variables required for the non-Oracle system
#" > /opt/oracle/product/21c/dbhomeXE/hs/admin/initbankpostgres.ora

echo "# listener.ora Network Configuration File:

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = PLSExtProc)
      (ORACLE_HOME = /opt/oracle/product/21c/dbhomeXE)
      (PROGRAM = extproc)
    )
    (SID_DESC =
      (SID_NAME = bankpostgres)
      (ORACLE_HOME = /opt/oracle/product/21c/dbhomeXE)
      (ENV="LD_LIBRARY_PATH=/opt/oracle/product/21c/dbhomeXE/lib:/usr/lib")
      (PROGRAM = dg4odbc)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_XE))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    )
  )

DEFAULT_SERVICE_LISTENER = (XE)" > /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora

lsnrctl status listener
lsnrctl reload listener
lsnrctl status listener

echo "# tnsnames.ora Network Configuration File:

XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )

LISTENER_XE =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))

XEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XEPDB1)
    )
  )

EXTPROC_CONNECTION_DATA =
  (DESCRIPTION =
     (ADDRESS_LIST =
       (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_XE))
     )
     (CONNECT_DATA =
       (SID = PLSExtProc)
       (PRESENTATION = RO)
     )
  )
  
bankpostgres =
  (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = 172.19.0.2)(PORT=1521))
     (CONNECT_DATA =
       (SERVER = DEDICATED)
       (SID = bankpostgres)
     )
     (HS=OK)
  )
" > /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora
```
```sh
find / -name initbankpostgres.ora
find / -name listener.ora
find / -name odbc.ini
find / -name psqlodbc.so
find / -name initdg4odbc.ora
find / -name dg4odbc
find / -name tnsnames.ora
```
```sh
/opt/oracle/product/21c/dbhomeXE/hs/admin/initdg4odbc.ora
/opt/oracle/oradata/dbconfig/XE/listener.ora
/opt/oracle/product/21c/dbhomeXE/network/admin/samples/listener.ora
/opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora
/opt/oracle/oradata/dbconfig/XE/tnsnames.ora
/opt/oracle/product/21c/dbhomeXE/network/admin/samples/tnsnames.ora
/opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora
```

### 4. Obtener IP Address de los contenedores

Al ejecutar

```sh
docker network inspect bank-network
```

Se obtiene la respuesta de la red con las ips que asignó a sus contenedores.

```json
[
    {
        "Name": "bank-network",
        // ...
        "Containers": {
            "5134958dd00c79c0c0c7afd21bcddd19562bfe8a422307c664f91fcb2981575e": {
                "Name": "bnk-branch-B-odb",
                // ...
                "IPv4Address": "172.19.0.3/16",
                // ...
            },
            "6c7a480c2f6d0cfc471a027e842c0cfeee9a1d8c0f218d2f60ed13b6575e1aff": {
                "Name": "bnk-branch-A-odb",
                // ...
                "IPv4Address": "172.19.0.2/16",
                // ...
            }
        },
    }
]
```

Estas IPs nos ayudarán en seguida para crear los database links.

### 5. Conexiones desde un cliente de bases de datos

> [!TIP]
> Puedes usar `sqlplus` desde la consola del contenedor si así deseas.
> Para ejecutarlo deberás hacer lo siguiente:
> `docker exec -ti chihuahua sh`
> Dentro de la consola del contenedor puedes ejecutar:
> `sqlplus`
> Ahora puedes ejecutar cualquier sentencia de sql.

Necesitas un cliente para visualizar los datos de la oracle database.

En este caso se utilizó la [Oracle SQL Developer Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer).

Seleccionas el ícono de la extensión:
![Imagen 1](img/image-1.png)

Una conexión se realizaría de la siguiente manera:
![Imagen 2](img/image-2.png)

Llenas los datos, recordando cambiar el nombre de la conexión y el puerto del contenedor.
![Imagen 3](img/image-3.png)

Y listo, ya puedes usarlo como un cliente de sql. Recuerda crear una conexión para
cada contenedor.

### 6. Crear database links

> [!IMPORTANT]
> Los scripts aquí mencionados están en la carpeta [scripts](./scripts/).
> Son todos aquellos con la terminación *-db-links.sql

Para conectar `chihuahua-odb` a las otras bases de datos, ejecuta el script `chihuahua-db-links.sql` o:
```sql
drop database link if exists chihuahua_juarez;
create database link chihuahua_juarez
   connect to system identified by my_pw_is_very_safe_yipi_1
using '(DESCRIPTION =
         (ADDRESS=
            (PROTOCOL = TCP)
            (HOST = 172.18.0.3)
            (PORT = 1521)
         )
         (CONNECT_DATA =
            (SERVICE_NAME = FREE)
         )
      )';
select *
  from dual@chihuahua_juarez;


drop database link if exists chihuahua_cuauhtemoc;
create database link chihuahua_cuauhtemoc
   connect to system identified by my_pw_is_very_safe_yipi_1
using '(DESCRIPTION =
         (ADDRESS=
            (PROTOCOL = TCP)
            (HOST = 172.18.0.4)
            (PORT = 1521)
         )
         (CONNECT_DATA =
            (SERVICE_NAME = FREE)
         )
      )';
select *
  from dual@chihuahua_cuauhtemoc;
```

Si el último resultado regresa lo siguiente:
![Imagen 4](./img/image-4.png)

Significa que funcionó.

### 7. Crear tablas de prueba

> [!IMPORTANT]
> Los scripts aquí mencionados están en la carpeta [scripts](./scripts/).
> Son todos aquellos con la terminación *-init.sql

Ejecuta los scripts de creación de tablas para cada una de las conexiones según correspondan.

### 8. Insertar datos de prueba

> [!IMPORTANT]
> Los scripts aquí mencionados están en la carpeta [scripts](./scripts/).
> Son todos aquellos con la terminación *-insert.sql

Ejecuta los scripts de inserción de datos para cada una de las conexiones según correspondan.

### 9. Probar funcionamiento de las conexiones

Si seguíste los pasos explicados en este tutorial hasta este punto, ya podrás obtendrer los datos de los demás contenedores, desde la base de datos de la conexión actual.

Ejecutando esto desde `chihuahua-odb`:

```sql
SELECT * FROM apple_orchard_sales
UNION
SELECT * FROM apple_orchard_sales@chihuahua_juarez
UNION
SELECT * FROM apple_orchard_sales@chihuahua_cuauhtemoc;
```

Obtenemos las datos combinados de los 3 contenedores.

### Otra documentación

- Descargar imagen de Oracle Database Free [https://www.oracle.com/database/free/get-started/](https://www.oracle.com/database/free/get-started/)
- Parámetros del contenedor [https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance#how-to-build-and-run](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance#how-to-build-and-run)

### [Licencia (GNU General Public License)](./license.md)

### Autoría
Adora González. [@stariluz](https://github.com/stariluz)