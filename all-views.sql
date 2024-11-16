-- Vista global para la tabla sucursal desde ambos dblinks
CREATE OR REPLACE VIEW global_sucursal AS
SELECT * FROM sucursal@a_link
UNION ALL
SELECT * FROM sucursal@b_link;

-- Vista global para la tabla prestamo desde ambos dblinks
CREATE OR REPLACE VIEW global_prestamo AS
SELECT * FROM prestamo@a_link
UNION ALL
SELECT * FROM prestamo@b_link;
