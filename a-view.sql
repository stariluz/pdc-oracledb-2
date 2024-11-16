CREATE VIEW cantidad_total_prestamos_por_sucursal AS
SELECT 
    s.idsucursal,
    s.nombresucursal,
    s.ciudadsucursal,
    s.region,
    COALESCE(SUM(p.cantidad), 0) AS total_prestamos
FROM 
    global_sucursal s
LEFT JOIN 
    global_prestamo p ON s.idsucursal = p.idsucursal
GROUP BY 
    s.idsucursal, s.nombresucursal, s.ciudadsucursal, s.region;
    