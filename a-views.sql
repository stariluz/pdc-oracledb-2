-- Vista global para la tabla sucursal desde ambos dblinks
CREATE OR REPLACE VIEW global_sucursal AS
SELECT * FROM sucursal
UNION ALL
SELECT * FROM "public"."sucursal"@b_link;

-- Vista global para la tabla prestamo desde ambos dblinks
CREATE OR REPLACE VIEW global_prestamo AS
SELECT * FROM prestamo
UNION ALL
SELECT * FROM "public"."prestamo"@b_link;
