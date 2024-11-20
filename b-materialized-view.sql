DROP MATERIALIZED VIEW IF EXISTS prestamo_global_b;
CREATE MATERIALIZED VIEW prestamo_global_b
   BUILD IMMEDIATE
   REFRESH COMPLETE ON DEMAND -- on commit, 
AS
   SELECT *
     FROM prestamo
   UNION ALL
   SELECT *
     FROM "prestamo"@b_link;