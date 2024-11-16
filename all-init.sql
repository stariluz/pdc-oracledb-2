DROP TABLE IF EXISTS sucursal;
DROP TABLE IF EXISTS prestamo;

CREATE TABLE sucursal (
   idsucursal     VARCHAR(5),
   nombresucursal VARCHAR(15),
   ciudadsucursal VARCHAR(15),
   activos        NUMBER,
   region         VARCHAR(2),
   PRIMARY KEY ( idsucursal )
);


CREATE TABLE prestamo (
   noprestamo VARCHAR(15),
   idsucursal VARCHAR(5),
   cantidad   NUMBER,
   PRIMARY KEY ( noprestamo )
);