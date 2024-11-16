EXEC insertar_sucursal('S0001', 'Downtown', 'Brooklyn', 900000, 'A');
EXEC insertar_sucursal('S0002', 'Redwood', 'Palo Alto', 2100000, 'A');
EXEC insertar_sucursal('S0003', 'Perryridge', 'Horseneck', 1700000, 'A');
EXEC insertar_sucursal('S0004', 'Mianus', 'Horseneck', 400200, 'A');
EXEC insertar_sucursal('S0005', 'Round Hill', 'Horseneck', 8000000, 'B');
EXEC insertar_sucursal('S0006', 'Pownal', 'Bennington', 400000, 'B');
EXEC insertar_sucursal('S0007', 'North Town', 'Rye', 3700000, 'B');
EXEC insertar_sucursal('S0008', 'Brighton', 'Brooklyn', 7000000, 'B');
EXEC insertar_sucursal('S0009', 'Central', 'Rye', 400280, 'B');

EXEC insertar_prestamo('L-17', 'S0001', 1000);
EXEC insertar_prestamo('L-23', 'S0002', 2000);
EXEC insertar_prestamo('L-15', 'S0003', 1500);
EXEC insertar_prestamo('L-14', 'S0001', 1500);
EXEC insertar_prestamo('L-93', 'S0004', 500);
EXEC insertar_prestamo('L-11', 'S0005', 900);
EXEC insertar_prestamo('L-16', 'S0003', 1300);
EXEC insertar_prestamo('L-20', 'S0007', 7500);
EXEC insertar_prestamo('L-21', 'S0009', 570);
