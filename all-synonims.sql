-- Sinónimos para la tabla sucursal en ambos db links
CREATE OR REPLACE SYNONYM sucursal_a FOR sucursal;
CREATE OR REPLACE SYNONYM sucursal_b FOR sucursal@b_link;

-- Sinónimos para la tabla prestamo en ambos db links
CREATE OR REPLACE SYNONYM prestamo_a FOR prestamo;
CREATE OR REPLACE SYNONYM prestamo_b FOR prestamo@b_link;


-- Sinónimos para la tabla sucursal en ambos db links
CREATE OR REPLACE SYNONYM sucursal_a FOR sucursal@a_link;
CREATE OR REPLACE SYNONYM sucursal_b FOR sucursal;

-- Sinónimos para la tabla prestamo en ambos db links
CREATE OR REPLACE SYNONYM prestamo_a FOR prestamo@a_link;
CREATE OR REPLACE SYNONYM prestamo_b FOR prestamo;
