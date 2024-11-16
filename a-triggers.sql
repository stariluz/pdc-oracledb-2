CREATE OR REPLACE TRIGGER SINC_A_SUCURSAL
AFTER INSERT ON sucursal
FOR EACH ROW
BEGIN
   IF :NEW.is_replicated = 0 THEN
      IF :NEW.region = 'A' THEN
         INSERT INTO sucursal@b_link (idsucursal, nombresucursal, ciudadsucursal, activos, region, is_replicated)
         VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region, 1);
      ELSIF :NEW.region = 'B' THEN
         INSERT INTO sucursal@a_link (idsucursal, nombresucursal, ciudadsucursal, activos, region, is_replicated)
         VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region, 1);
      END IF;
   END IF;
END;
/


CREATE OR REPLACE TRIGGER SINC_A_PRESTAMO
AFTER INSERT ON prestamo
FOR EACH ROW
DECLARE
   v_region VARCHAR(2);
BEGIN
   SELECT region INTO v_region
   FROM sucursal
   WHERE idsucursal = :NEW.idsucursal;

   IF v_region = 'A' THEN
      INSERT INTO prestamo@b_link (noprestamo, idsucursal, cantidad)
      VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad);
   ELSIF v_region = 'B' THEN
      INSERT INTO prestamo@a_link (noprestamo, idsucursal, cantidad)
      VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad);
   END IF;
END;
/
