DROP TRIGGER sinc_sucursal;

CREATE TRIGGER sinc_sucursal AFTER
   INSERT ON sucursal
   FOR EACH ROW
BEGIN
   IF :new.is_replicated = 0 THEN
      dbms_output.put_line('Replicado en la region B');
      INSERT INTO sucursal_b (
         idsucursal,
         nombresucursal,
         ciudadsucursal,
         activos,
         region,
         is_replicated
      ) VALUES ( :new.idsucursal,
                 :new.nombresucursal,
                 :new.ciudadsucursal,
                 :new.activos,
                 :new.region,
                 1 );
   ELSE
      dbms_output.put_line('Replicacion duplicada evitada');
   END IF;
END;
/


DROP TRIGGER sinc_prestamo;
CREATE TRIGGER sinc_prestamo AFTER
   INSERT ON prestamo
   FOR EACH ROW
DECLARE
   v_region VARCHAR(2);
BEGIN
   SELECT region
     INTO v_region
     FROM global_sucursal
    WHERE idsucursal = :new.idsucursal;

   IF :new.is_replicated = 0 THEN
      dbms_output.put_line('Replicado en la region B');
      INSERT INTO prestamo_b (
         noprestamo,
         idsucursal,
         cantidad,
         is_replicated
      ) VALUES ( :new.noprestamo,
                 :new.idsucursal,
                 :new.cantidad,
                 1 );
   ELSE
      dbms_output.put_line('Replicacion duplicada evitada');
   END IF;
END;
/