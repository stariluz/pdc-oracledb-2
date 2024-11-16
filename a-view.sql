CREATE VIEW cantidad_total_prestamos_por_sucursal AS
SELECT 
    s.idsucursal,
    s.nombresucursal,
    s.ciudadsucursal,
    s.region,
    COALESCE(SUM(p.cantidad), 0) AS total_prestamos
FROM 
    sucursal s
LEFT JOIN 
    prestamo p ON s.idsucursal = p.idsucursal
GROUP BY 
    s.idsucursal, s.nombresucursal, s.ciudadsucursal, s.region
UNION ALL
SELECT 
    s.idsucursal,
    s.nombresucursal,
    s.ciudadsucursal,
    s.region,
    COALESCE(SUM(p.cantidad), 0) AS total_prestamos
FROM 
    sucursal@b_link s
LEFT JOIN 
    prestamo@b_link p ON s.idsucursal = p.idsucursal
GROUP BY 
    s.idsucursal, s.nombresucursal, s.ciudadsucursal, s.region;
