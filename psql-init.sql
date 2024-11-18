CREATE TABLE sucursal (
   idsucursal     VARCHAR(5),
   nombresucursal VARCHAR(15),
   ciudadsucursal VARCHAR(15),
   activos        INTEGER,
   region         VARCHAR(2),
   is_replicated  BOOLEAN DEFAULT FALSE,
   PRIMARY KEY (idsucursal)
);

CREATE TABLE prestamo (
   noprestamo    VARCHAR(15),
   idsucursal    VARCHAR(5),
   cantidad      NUMERIC,
   is_replicated BOOLEAN DEFAULT FALSE,
   PRIMARY KEY (noprestamo)
);
