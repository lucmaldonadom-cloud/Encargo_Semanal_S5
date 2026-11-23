SELECT
    TO_CHAR(c.numrun, 'FM999G999G999') || '-' || c.dvrun AS "RUT Cliente",
    INITCAP(
        TRIM(
            c.pnombre || ' ' ||
            NVL(c.snombre, '') ||
            CASE WHEN c.snombre IS NOT NULL THEN ' ' ELSE '' END ||
            c.appaterno || ' ' ||
            c.apmaterno
        )
    ) AS "Nombre Cliente",
    INITCAP(TRIM(p.nombre_prof_ofic)) AS "Profesión Cliente",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
    c.direccion AS "Dirección Cliente"
FROM cliente c
JOIN tipo_cliente tc
    ON c.cod_tipo_cliente = tc.cod_tipo_cliente
JOIN profesion_oficio p
    ON c.cod_prof_ofic = p.cod_prof_ofic
WHERE UPPER(TRIM(tc.nombre_tipo_cliente)) = 'TRABAJADORES DEPENDIENTES'
  AND UPPER(TRIM(p.nombre_prof_ofic)) IN ('CONTADOR', 'VENDEDOR')
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) > (
      SELECT ROUND(AVG(EXTRACT(YEAR FROM c2.fecha_inscripcion)))
      FROM cliente c2
  )
ORDER BY c.numrun ASC;


DROP TABLE clientes_cupos_compra PURGE;

CREATE TABLE clientes_cupos_compra AS
SELECT
    TO_CHAR(c.numrun, 'FM999G999G999') || '-' || c.dvrun AS rut_cliente,
    TRUNC(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12) AS edad,
    t.cupo_disp_compra AS cupodisponiblecompra,
    UPPER(TRIM(tc.nombre_tipo_cliente)) AS tipo_cliente
FROM cliente c
JOIN tipo_cliente tc
    ON c.cod_tipo_cliente = tc.cod_tipo_cliente
JOIN tarjeta_cliente t
    ON c.numrun = t.numrun
WHERE t.cupo_disp_compra >= (
    SELECT MAX(t2.cupo_disp_compra)
    FROM tarjeta_cliente t2
    WHERE EXTRACT(YEAR FROM t2.fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) - 1
)
ORDER BY edad ASC;

-- Verificar el contenido creado en la nueva tabla:
SELECT * FROM clientes_cupos_compra;