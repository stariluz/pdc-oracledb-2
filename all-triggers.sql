SELECT * FROM user_errors WHERE name = 'SINC_SUCURSAL';

DROP TRIGGER IF EXISTS SINC_SUCURSAL;
DROP TRIGGER IF EXISTS SINC_PRESTAMO;

CREATE TRIGGER SINC_SUCURSAL
AFTER INSERT ON sucursal
FOR EACH ROW
BEGIN
   BEGIN
   IF :NEW.is_replicated != 1 THEN
      IF :NEW.region = 'A' THEN
         DBMS_OUTPUT.PUT_LINE('Replicado en la region B' );
         INSERT INTO sucursal_b (idsucursal, nombresucursal, ciudadsucursal, activos, region, is_replicated)
         VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region, 1);
      ELSIF :NEW.region = 'B' THEN
         DBMS_OUTPUT.PUT_LINE('Replicado en la region A' );
         INSERT INTO sucursal_a (idsucursal, nombresucursal, ciudadsucursal, activos, region, is_replicated)
         VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region, 1);
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE('Replicacion duplicada evitada' );
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- Manejo de errores: registrar el error en una tabla de logs
         INSERT INTO log_errores (mensaje_error, fecha)
         VALUES (SQLERRM, SYSDATE);
   END;
END;
/

CREATE TRIGGER SINC_PRESTAMO
AFTER INSERT ON prestamo
FOR EACH ROW
DECLARE
   v_region VARCHAR(2);
BEGIN
   SELECT region INTO v_region
   FROM global_sucursal
   WHERE idsucursal = :NEW.idsucursal;

   IF :NEW.is_replicated != 1 THEN
      IF v_region = 'A' THEN
         DBMS_OUTPUT.PUT_LINE('Replicado en la region B' );
         INSERT INTO prestamo_b (noprestamo, idsucursal, cantidad)
         VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad, 1);
      ELSIF v_region = 'B' THEN
         DBMS_OUTPUT.PUT_LINE('Replicado en la region A' );
         INSERT INTO prestamo_a (noprestamo, idsucursal, cantidad)
         VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad, 1);
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE('Replicacion duplicada evitada' );
   END IF;
END;
/
COMMIT;