CREATE OR REPLACE PROCEDURE insertar_prestamo(
    p_noprestamo      VARCHAR,
    p_idsucursal      VARCHAR,
    p_cantidad        NUMBER
) IS
    v_region VARCHAR(2);
BEGIN
    SELECT region
    INTO v_region
    FROM sucursal
    WHERE idsucursal = p_idsucursal;

    IF v_region = 'A' THEN
        INSERT INTO prestamo@a_link (noprestamo, idsucursal, cantidad)
        VALUES (p_noprestamo, p_idsucursal, p_cantidad);

    ELSIF v_region = 'B' THEN
        INSERT INTO prestamo@b_link (noprestamo, idsucursal, cantidad)
        VALUES (p_noprestamo, p_idsucursal, p_cantidad);

    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La región de la sucursal no es válida');
    END IF;

    COMMIT;
END;
