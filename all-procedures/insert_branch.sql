CREATE OR REPLACE PROCEDURE insertar_sucursal(
    p_idsucursal      VARCHAR,
    p_nombresucursal  VARCHAR,
    p_ciudadsucursal  VARCHAR,
    p_activos         NUMBER,
    p_region          VARCHAR
) IS
BEGIN
    IF p_region = 'A' THEN
        INSERT INTO sucursal@a_link (idsucursal, nombresucursal, ciudadsucursal, activos, region)
        VALUES (p_idsucursal, p_nombresucursal, p_ciudadsucursal, p_activos, p_region);

    ELSIF p_region = 'B' THEN
        INSERT INTO sucursal@b_link (idsucursal, nombresucursal, ciudadsucursal, activos, region)
        VALUES (p_idsucursal, p_nombresucursal, p_ciudadsucursal, p_activos, p_region);

    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'El valor de p_region debe ser "A" o "B"');
    END IF;

    COMMIT;
END;