DROP MATERIALIZED VIEW IF EXISTS sucursal_global_a;
CREATE MATERIALIZED VIEW sucursal_global_a
   BUILD IMMEDIATE
   REFRESH COMPLETE ON DEMAND -- on commit, 
AS
   SELECT *
     FROM sucursal
   UNION ALL
   SELECT *
     FROM "sucursal"@b_link;