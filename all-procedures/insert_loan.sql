CREATE OR REPLACE PROCEDURE insertar_prestamo(
    p_noprestamo      VARCHAR,
    p_idsucursal      VARCHAR,
    p_cantidad        NUMBER
) IS
    v_region VARCHAR(2);
BEGIN
    SELECT region
    INTO v_region
    FROM global_sucursal
    WHERE idsucursal = p_idsucursal;
    
    DBMS_OUTPUT.PUT_LINE('ID sucursal: ' || p_idsucursal);
    DBMS_OUTPUT.PUT_LINE('Region: ' || v_region);

    IF v_region = 'A' THEN
        DBMS_OUTPUT.PUT_LINE('Guardado en la region ' || v_region);
        INSERT INTO prestamo_a (noprestamo, idsucursal, cantidad)
        VALUES (p_noprestamo, p_idsucursal, p_cantidad);

    ELSIF v_region = 'B' THEN
        DBMS_OUTPUT.PUT_LINE('Guardado en la region ' || v_region);
        INSERT INTO prestamo_b (noprestamo, idsucursal, cantidad)
        VALUES (p_noprestamo, p_idsucursal, p_cantidad);

    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La región de la sucursal no es válida');
    END IF;

    COMMIT;
END;
/