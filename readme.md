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
  POSTGRES_PASSWORD=este_es_el_password_UwU
  ```

## 1. Crear red

```sh
docker network create bank-network
```

### 2. Descargar imagenes
```sh
docker pull container-registry.oracle.com/database/express:21.3.0-xe
docker pull postgres
```

## 3. Crear contenedores

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
-p 5432:5432 \
--env-file .env postgres

```

## 4. Obtener IP Address de los contenedores
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


##  5. Configurar contenedores

### oracledb container

Los comandos se ejecutarán en la consola del contenedor de oracledb
```sh
docker exec -ti bnk-branch-A-odb sh
```
Habiendo entrado ya podemos ejecutar los comandos.
```sh
su -
yum install -y postgresql-odbc
```
```sh
echo "[bankpostgres]
Description          = Bank Branch B
Driver               = PostgreSQL
Debug                = 1
CommLog              = 1
ReadOnly             = no
TextAsLongVarchar    = Yes
TraceFile            = /tmp/sql.log
UseServerSidePrepare = 1
Debug                = 1
Trace                = yes
CommLog              = 1
UseDeclareFetch      = 0
Servername           = 172.19.0.3
Port                 = 5432
Username             = postgres
Password             = my_pw_is_very_safe_yipi_1
Database             = bank
dbms_name            = PostgreSQL
" > /etc/odbc.ini
```
```sh
echo "# Example driver definitions

# Driver from the postgresql-odbc package
# Setup from the unixODBC package
[PostgreSQL]
Description     = ODBC for PostgreSQL
Driver          = /usr/lib/psqlodbcw.so
Setup           = /usr/lib/libodbcpsqlS.so
Driver64        = /usr/lib64/psqlodbcw.so
Setup64         = /usr/lib64/libodbcpsqlS.so
FileUsage       = 1

# Driver from the mysql-connector-odbc package
# Setup from the unixODBC package
[MySQL]
Description     = ODBC for MySQL
Driver          = /usr/lib/libmyodbc5.so
Setup           = /usr/lib/libodbcmyS.so
Driver64        = /usr/lib64/libmyodbc5.so
Setup64         = /usr/lib64/libodbcmyS.so
FileUsage       = 1
" > /etc/odbcinst.ini
```
```sh
echo "HS_FDS_CONNECT_INFO = bankpostgres
HS_FDS_TRACE_LEVEL = 4
HS_FDS_SQLLEN = 32767
HS_FDS_SQLCHAR = 2000
HS_FDS_TRACE_FILE_NAME=/tmp/ora_hs_trace.log
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
HS_LANGUAGE=AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini" > /opt/oracle/product/21c/dbhomeXE/hs/admin/initbankpostgres.ora
```
```sh
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

# Own OracleDB container host and port is the port of the container side, usually doesn't change.
bankpostgres =
  (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT=1521)) 
     (CONNECT_DATA = (SID = bankpostgres))
     (HS=OK)
  )
" > /opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora
```
```sh
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
```
```sh
# Si estos comandos no te funcionan, es probable que debas
# ejecutar exit primero, cuando vuelvas a ver en la
# terminal que estas en las consola sh (aun dentro
# del contenedor) entonces ejecutalos. Si no te deja
# reportalo a @stariluz
lsnrctl status listener
lsnrctl reload listener
lsnrctl status listener
```
#### Comandos para encontrar archivos

> [!IMPORTANT]
> Los comandos de arriba, no importan desde que carpeta
> los ejecutes, funcionarán. Los impedimentos pueden ser
> de permisos. Si no funcionan normal, cambia de permisos
> entre `su -` o `su - oracle`.

Estos son comandos que me ayudaron a encontrar los archivos que debía modificar, o las rutas que tenía
que utilizar dentro de los archivos que se estan
sobreescribiendo o modificando.

```sh
find / -name initbankpostgres.ora
find / -name listener.ora
find / -name odbc.ini
find / -name psqlodbc.so
find / -name initdg4odbc.ora
find / -name dg4odbc
find / -name tnsnames.ora
```

Estos son los archivos que en mi caso tuve que modificar.
Si en algun caso te dice que las carpetas no existen,
tendras que ejecutar los find para dar con los archivos
en tu caso.

```sh
/opt/oracle/product/21c/dbhomeXE/hs/admin/initdg4odbc.ora
/opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora
/opt/oracle/homes/OraDBHome21cXE/network/admin/tnsnames.ora
```

Hay archivos de nombres iguales, pero algunos son ejemplos,
y otros creo que los maneja oracle.

> [!NOTE]
> En este punto ya puedes crear el db link.
> no obstante no funcionará aún. Puedes esperar a configurar el contenedor de postgres.

### postgres container

Primero se crea la base de datos con la que se hara enlace.
```sh
docker exec -ti bnk-branch-B-odb psql -h 172.19.0.3 --username=postgres -W # Entonces escribe la contraseña
CREATE DATABASE bank;
exit
```
Ahora si, podemos configurarlo desde la consola del contenedor de postgres.
```sh
docker exec -ti bnk-branch-B-odb sh
```
Estando dentro, ejecutaremos los comandos.
```sh
cat /var/lib/postgresql/data/pg_hba.conf
```
Copia la salida que te dio cat, y agregala a un archivo auxiliar en vscode.
```sh
# ...

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

host all all all scram-sha-256
```
Tendrás que modificar 2 cosas.
1. Primero agrega el server de oracledb en `# IPv4 local connections`
  ```sh
  # ...
  # IPv4 local connections: 
  host    all             all             127.0.0.1/32            trust
  host    all             all             172.19.0.2/32           trust # Mi server de oracledb
  # IPv6 local connections:
  # ...
  ```
2. Cambia todos los `"` por `\"`. Puedes hacerlo con la herramienta find and replace all.

Ahora sí, copia el texto, y lo pegas en el siguiente comando en medio de las comillas dobles `""`.
```sh
echo "TEXTO" > /var/lib/postgresql/data/pg_hba.conf
```
Ahora para comprobar
```sh
cat /var/lib/postgresql/data/pg_hba.conf
```
Si está tu IP de oracle en donde la colocaste, entonces está bien.
Por último
```sh
su postgres
pg_ctl reload
exit
```

### 5. Conexión desde un cliente de bases de datos

Hasta ahora, solo requerimos el cliente para oracledb.
Obviaremos la configuración de la conexión.

### 6. Comprobar funcionamiento

Ejecuta el archivo de `odb-db-link.sql` si funciona, significa que ya esta la conexión y el resto de
actividades hay que replantearlas para que funcionen tambien en el servidor de postgres.

### Documentación

- Descargar imagen de Oracle Database Free [https://www.oracle.com/database/free/get-started/](https://www.oracle.com/database/free/get-started/)
- Parámetros de la imagen [https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance#how-to-build-and-run](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance#how-to-build-and-run)
- Video para conexión con postgres [https://www.youtube.com/watch?v=9nNtlcYyG3Y](https://www.youtube.com/watch?v=9nNtlcYyG3Y)

### [Licencia (GNU General Public License)](./license.md)

### Autoría
Adora González. [@stariluz](https://github.com/stariluz)