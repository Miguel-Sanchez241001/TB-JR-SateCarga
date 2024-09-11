SELECT cliente.B06_TIPO_DOCUMENTO                            as tipo,
       cliente.B06_NUM_DOCUMENTO                             as numdoc,
       cliente.B06_NOMBRES || ' - ' || cliente.B06_APPATERNO AS NOMBRESCOMPLETOS,
       MC.B12_NUMERO_TARJETA                                 as tarjeta
FROM BNSATE12_RPTA_MC_TEMP mc
         join BNSATE06_CLIENTE cliente
              on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                  and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0');


-- QUERY OBTENER CLIENTES SUS TARJETAS ACTIVAS segun la entidad

SELECT empre.B00_ID_EMP                                    as idEmpre,
       empre.B00_NUM_RUC                                   as ruc,
       (SELECT B09_COD_INTERNO
        FROM BNSATE09_NOMBRE_CORTO
        WHERE B09_NUM_RUC = empre.B00_NUM_RUC)             AS CODiNTERNO,
       cliente.B06_NOMBRES || ' ' || cliente.B06_APPATERNO as NombreCompleto,
       cliente.B06_TIPO_DOCUMENTO                          as TipoDoc,
       cliente.B06_NUM_DOCUMENTO                           as NumDoc,
       tar.B05_ID_TAR,
       tar.estado,
       tar.B05_NUM_TARJETA                                 as NumTar,
       tar.B05_NUM_CUENTA                                  as NumCuenta
FROM BNSATE06_CLIENTE cliente
         join (SELECT tar1.*, ETA.B07_ESTADO as estado
               from BNSATE05_TARJETA tar1
                        join (SELECT t1.*
                              FROM BNSATE07_EST_TARJETA t1
                              WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                        FROM BNSATE07_EST_TARJETA t2
                                                        WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                             on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
              on cliente.B06_ID_CLI = tar.B06_ID_CLI
         join BNSATE00_EMPRESA empre
              on tar.B00_ID_EMP = empre.B00_ID_EMP
where empre.B00_NUM_RUC = (select B09_NUM_RUC from BNSATE09_NOMBRE_CORTO where B09_COD_INTERNO = '6001');
--cliente.B06_NUM_DOCUMENTO  IN ('15743653','10135089','16727214');


SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
        FROM BNSATE00_EMPRESA
        WHERE B00_NUM_RUC = (select B09_NUM_RUC
                             from BNSATE09_NOMBRE_CORTO
                             where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
       cliente.B06_ID_CLI,
       tar.B05_ID_TAR,
       tar.ESTADO,
       mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
       mc.B12_NUMERO_TARJETA,
       mc.B12_FECHA_APERTURA_TARJETA,
       mc.B12_FECHA_VENCIMIENTO_TARJETA,
       mc.B12_CODIGO_PRODUCTO,
       mc.B12_COD_INTERNO_TEMP
FROM BNSATE12_RPTA_MC_TEMP mc
         join BNSATE06_CLIENTE cliente
              on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                  and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
         join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
               from BNSATE05_TARJETA tar1
                        join (SELECT t1.*
                              FROM BNSATE07_EST_TARJETA t1
                              WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                        FROM BNSATE07_EST_TARJETA t2
                                                        WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                             on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
              on cliente.B06_ID_CLI = tar.B06_ID_CLI;



SELECT tar1.*
from BNSATE05_TARJETA tar1
         join (SELECT t1.*
               FROM BNSATE07_EST_TARJETA t1
               WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                         FROM BNSATE07_EST_TARJETA t2
                                         WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
              on tar1.B05_ID_TAR = eta.B05_ID_TAR
WHERE eta.B07_ESTADO = '3';


-- 1 : Actualizacion del numeor de tarjetas
MERGE INTO BNSATE05_TARJETA tar
    USING (SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
                   FROM BNSATE00_EMPRESA
                   WHERE B00_NUM_RUC = (select B09_NUM_RUC
                                        from BNSATE09_NOMBRE_CORTO
                                        where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
                  cliente.B06_ID_CLI,
                  tar.B05_ID_TAR,
                  tar.ESTADO,
                  mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
                  mc.B12_NUMERO_TARJETA,
                  mc.B12_FECHA_VENCIMIENTO_TARJETA,
                  mc.B12_NUMERO_CUENTA,
                  mc,B12_BLOQUEO_1_CUENTA


               mc.B12_COD_INTERNO_TEMP
           FROM BNSATE12_RPTA_MC_TEMP mc
                    join BNSATE06_CLIENTE cliente
                         on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                             and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
                    join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
                          from BNSATE05_TARJETA tar1
                                   join (SELECT t1.*
                                         FROM BNSATE07_EST_TARJETA t1
                                         WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                                   FROM BNSATE07_EST_TARJETA t2
                                                                   WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                                        on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
                         on cliente.B06_ID_CLI = tar.B06_ID_CLI
           WHERE mc.B12_TIPO_RESPUESTA = '0') rptMC -- FITAR
    ON (tar.B00_ID_EMP = rptMC.idEmpre
        and tar.B06_ID_CLI = rptMC.B06_ID_CLI
        and tar.B05_ID_TAR = rptMC.B05_ID_TAR
        and tar.B05_DISENO = substr(rptMC.LOGO, -1)
        and rptMC.ESTADO = '3') -- Estado enviadas
    WHEN MATCHED THEN
        UPDATE
            SET tar.B05_NUM_TARJETA     = rptMC.B12_NUMERO_TARJETA,
                tar.B05_FEC_VENCIMIENTO = rptMC.B12_FECHA_VENCIMIENTO_TARJETA;


-- 2 : Actualizacion del cuentas de tarjetas
MERGE INTO BNSATE05_TARJETA tar
    USING (SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
                   FROM BNSATE00_EMPRESA
                   WHERE B00_NUM_RUC = (select B09_NUM_RUC
                                        from BNSATE09_NOMBRE_CORTO
                                        where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
                  cliente.B06_ID_CLI,
                  tar.B05_ID_TAR,
                  tar.ESTADO,
                  mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
                  mc.B12_NUMERO_CUENTA,
                  mc.B12_BLOQUEO_1_CUENTA,
                  mc.B12_FECHA_APERTURA_CUENTA,
                  mc.B12_FECHA_VENCIMIENTO_TARJETA,
                  mc.B12_CODIGO_PRODUCTO,
                  mc.B12_COD_INTERNO_TEMP
           FROM BNSATE12_RPTA_MC_TEMP mc
                    join BNSATE06_CLIENTE cliente
                         on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                             and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
                    join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
                          from BNSATE05_TARJETA tar1
                                   join (SELECT t1.*
                                         FROM BNSATE07_EST_TARJETA t1
                                         WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                                   FROM BNSATE07_EST_TARJETA t2
                                                                   WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                                        on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
                         on cliente.B06_ID_CLI = tar.B06_ID_CLI
           WHERE mc.B12_TIPO_RESPUESTA = '1') rptMC -- FITAR
    ON (tar.B00_ID_EMP = rptMC.idEmpre
        and tar.B06_ID_CLI = rptMC.B06_ID_CLI
        and tar.B05_ID_TAR = rptMC.B05_ID_TAR
        and tar.B05_DISENO = substr(rptMC.LOGO, -1)
        and rptMC.ESTADO = '3') -- Estado enviadas
    WHEN MATCHED THEN
        UPDATE
            SET tar.B05_NUM_CUENTA     = rptMC.,
                tar.B05_FEC_VENCIMIENTO = rptMC.B12_FECHA_VENCIMIENTO_TARJETA;





--20131380101,1,MINISTERIO DE RELACIONES EXTERIORES
--20131312955,1,SUPERINTENDENCIA NACIONAL DE ADUANAS Y ADMINISTRACION TRIBUTARIA
--20307167442,1,COMISION DE PROMOCION DEL PERU PARA LA EXPORTACION Y EL TURISMO-PROMPERU
--20131370645,1,MEF ADMINISTRACION DE LA DEUDA

SELECT t1.*
FROM BNSATE07_EST_TARJETA t1
WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                          FROM BNSATE07_EST_TARJETA t2
                          WHERE t1.B05_ID_TAR = t2.B05_ID_TAR);

SELECT tar1.B05_ID_TAR,
       MAX(eta1.B07_FEC_REGISTRO) AS B07_FEC_REGISTRO
FROM BN_SATE.BNSATE05_TARJETA tar1
         JOIN
     BN_SATE.BNSATE07_EST_TARJETA eta1
     ON
         eta1.B05_ID_TAR = tar1.B05_ID_TAR
GROUP BY tar1.B05_ID_TAR;



ALTER TABLE BNSATE12_RPTA_MC_TEMP
    add (hola varchar2(10));

ALTER TABLE BNSATE12_RPTA_MC_TEMP
    ADD B12_COD_INTERNO_TEMP VARCHAR2(4);

ALTER TABLE BNSATE12_RPTA_MC_TEMP
DROP COLUMN hola;





SELECT cliente.B06_TIPO_DOCUMENTO                            as tipo,
       cliente.B06_NUM_DOCUMENTO                             as numdoc,
       cliente.B06_NOMBRES || ' - ' || cliente.B06_APPATERNO AS NOMBRESCOMPLETOS,
       MC.B12_NUMERO_TARJETA                                 as tarjeta
FROM BNSATE12_RPTA_MC_TEMP mc
         join BNSATE06_CLIENTE cliente
              on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                  and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0');


-- QUERY OBTENER CLIENTES SUS TARJETAS ACTIVAS segun la entidad

SELECT empre.B00_ID_EMP                                    as idEmpre,
       empre.B00_NUM_RUC                                   as ruc,
       (SELECT B09_COD_INTERNO
        FROM BNSATE09_NOMBRE_CORTO
        WHERE B09_NUM_RUC = empre.B00_NUM_RUC)             AS CODiNTERNO,
       cliente.B06_NOMBRES || ' ' || cliente.B06_APPATERNO as NombreCompleto,
       cliente.B06_TIPO_DOCUMENTO                          as TipoDoc,
       cliente.B06_NUM_DOCUMENTO                           as NumDoc,
       tar.B05_ID_TAR,
       tar.estado,
       tar.B05_NUM_TARJETA                                 as NumTar,
       tar.B05_NUM_CUENTA                                  as NumCuenta
FROM BNSATE06_CLIENTE cliente
         join (SELECT tar1.*, ETA.B07_ESTADO as estado
               from BNSATE05_TARJETA tar1
                        join (SELECT t1.*
                              FROM BNSATE07_EST_TARJETA t1
                              WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                        FROM BNSATE07_EST_TARJETA t2
                                                        WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                             on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
              on cliente.B06_ID_CLI = tar.B06_ID_CLI
         join BNSATE00_EMPRESA empre
              on tar.B00_ID_EMP = empre.B00_ID_EMP
where empre.B00_NUM_RUC = (select B09_NUM_RUC from BNSATE09_NOMBRE_CORTO where B09_COD_INTERNO = '6001');
--cliente.B06_NUM_DOCUMENTO  IN ('15743653','10135089','16727214');


SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
        FROM BNSATE00_EMPRESA
        WHERE B00_NUM_RUC = (select B09_NUM_RUC
                             from BNSATE09_NOMBRE_CORTO
                             where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
       cliente.B06_ID_CLI,
       tar.B05_ID_TAR,
       tar.ESTADO,
       mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
       mc.B12_NUMERO_TARJETA,
       mc.B12_FECHA_APERTURA_TARJETA,
       mc.B12_FECHA_VENCIMIENTO_TARJETA,
       mc.B12_CODIGO_PRODUCTO,
       mc.B12_COD_INTERNO_TEMP
FROM BNSATE12_RPTA_MC_TEMP mc
         join BNSATE06_CLIENTE cliente
              on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                  and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
         join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
               from BNSATE05_TARJETA tar1
                        join (SELECT t1.*
                              FROM BNSATE07_EST_TARJETA t1
                              WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                        FROM BNSATE07_EST_TARJETA t2
                                                        WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                             on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
              on cliente.B06_ID_CLI = tar.B06_ID_CLI;



SELECT tar1.*
from BNSATE05_TARJETA tar1
         join (SELECT t1.*
               FROM BNSATE07_EST_TARJETA t1
               WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                         FROM BNSATE07_EST_TARJETA t2
                                         WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
              on tar1.B05_ID_TAR = eta.B05_ID_TAR
WHERE eta.B07_ESTADO = '3';


-- 1 : Actualizacion del numeor de tarjetas
MERGE INTO BNSATE05_TARJETA tar
    USING (SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
                   FROM BNSATE00_EMPRESA
                   WHERE B00_NUM_RUC = (select B09_NUM_RUC
                                        from BNSATE09_NOMBRE_CORTO
                                        where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
                  cliente.B06_ID_CLI,
                  tar.B05_ID_TAR,
                  tar.ESTADO,
                  mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
                  mc.B12_NUMERO_TARJETA,
                  mc.B12_FECHA_VENCIMIENTO_TARJETA,
                  mc.B12_NUMERO_CUENTA,
                  mc.B12_BLOQUEO_1_CUENTA,
                  mc.B12_FECHA_APERTURA_CUENTA,
                  mc.B12_COD_INTERNO_TEMP
           FROM BNSATE12_RPTA_MC_TEMP mc
                    join BNSATE06_CLIENTE cliente
                         on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO

                             and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
                    join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
                          from BNSATE05_TARJETA tar1
                                   join (SELECT t1.*
                                         FROM BNSATE07_EST_TARJETA t1
                                         WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                                   FROM BNSATE07_EST_TARJETA t2
                                                                   WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                                        on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
                         on cliente.B06_ID_CLI = tar.B06_ID_CLI
           WHERE mc.B12_TIPO_RESPUESTA = '0') rptMC -- FITAR
    ON (tar.B00_ID_EMP = rptMC.idEmpre
        and tar.B06_ID_CLI = rptMC.B06_ID_CLI
        and tar.B05_ID_TAR = rptMC.B05_ID_TAR
        and tar.B05_DISENO = ObtenerDisenoTipo(rptMC.LOGO, 1)
        and tar.B05_TIPO_TARJETA =  ObtenerDisenoTipo(rptMC.LOGO, 2)
        and rptMC.ESTADO = '3') -- Estado enviadas
    WHEN MATCHED THEN
        UPDATE
            SET tar.B05_NUM_TARJETA     = rptMC.B12_NUMERO_TARJETA,
                tar.B05_FEC_VENCIMIENTO = rptMC.B12_FECHA_VENCIMIENTO_TARJETA,
                tar.B05_NUM_CUENTA = rptMC.B12_NUMERO_CUENTA,
                tar.B05_FEC_APERTURA_CUENTA = rptMC.B12_FECHA_APERTURA_CUENTA,
                tar.B05_EST_CUENTA = rptMC.B12_BLOQUEO_1_CUENTA;



CREATE OR REPLACE TRIGGER BT_ESTADO_TAR
AFTER UPDATE ON BNSATE05_TARJETA
                 FOR EACH ROW
BEGIN
    -- Validamos que ninguno de los campos a actualizar sea NULL
    IF :NEW.B05_NUM_TARJETA IS NOT NULL
       AND :NEW.B05_FEC_VENCIMIENTO IS NOT NULL
       AND :NEW.B05_NUM_CUENTA IS NOT NULL
       AND :NEW.B05_FEC_APERTURA_CUENTA IS NOT NULL
       AND :NEW.B05_EST_CUENTA IS NOT NULL THEN

           INSERT INTO BNSATE07_EST_TARJETA (
            B05_ID_TAR,
            B07_ESTADO,
            B07_MOTIVO,
            B07_FEC_REGISTRO,
            B07_USUARIO_CREA
        ) VALUES (
             :OLD.B05_ID_TAR,
            '5',
            'Activada',
            SYSDATE,
            ''
        );
END IF;
END;
/











SELECT tar1.*, eta.B07_ESTADO AS ESTADO
from BNSATE05_TARJETA tar1
         join (SELECT t1.*
               FROM BNSATE07_EST_TARJETA t1
               WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                         FROM BNSATE07_EST_TARJETA t2
                                         WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
              on tar1.B05_ID_TAR = eta.B05_ID_TAR










    INSERT INTO BN_SATE.BNSATE07_EST_TARJETA (
    B05_ID_TAR,  -- Identificador de tarjeta
    B07_ESTADO,  -- Estado de la tarjeta
    B07_MOTIVO,  -- Motivo del estado
    B07_FEC_REGISTRO -- Fecha de registro
)
-- Paso 2: Selecciona datos para la inserción
SELECT
    tar.B05_ID_TAR,  -- Identificador de tarjeta
    '5',            -- Estado '3' Enviadas IZIPAY
    NULL,           -- Motivo se establece como NULL
    SYSDATE         -- Fecha de registro actual
FROM
    BNSATE05_TARJETA tar
        -- Paso 3: Une la tabla BNSATE05_TARJETA con BNSATE07_EST_TARJETA usando una combinación de unión
        JOIN
    BN_SATE.BNSATE07_EST_TARJETA eta
    ON
        eta.B05_ID_TAR = tar.B05_ID_TAR
        -- Paso 4: Realiza una unión interna con una subconsulta que encuentra la fecha de registro más reciente
        INNER JOIN
    (
        SELECT
            tar1.B05_ID_TAR,
            MAX(eta1.B07_FEC_REGISTRO) AS B07_FEC_REGISTRO
        FROM
            BN_SATE.BNSATE05_TARJETA tar1
                JOIN
            BN_SATE.BNSATE07_EST_TARJETA eta1
            ON
                eta1.B05_ID_TAR = tar1.B05_ID_TAR
        GROUP BY
            tar1.B05_ID_TAR
    ) q
    ON
        tar.B05_ID_TAR = q.B05_ID_TAR
            AND
        eta.B07_FEC_REGISTRO = q.B07_FEC_REGISTRO
-- Paso 5: Filtra los registros donde el estado es igual a 2
WHERE
    eta.B07_ESTADO = 3 AND tar.B05_NUM_TARJETA ;


CREATE OR REPLACE TRIGGER trg_update_to_insert
AFTER UPDATE ON BNSATE05_TARJETA
                 FOR EACH ROW
BEGIN
    -- Verificamos si el campo que te interesa no es NULL
    IF :NEW.campo_actualizado IS NOT NULL THEN
        -- Insertamos en la tabla destino utilizando el ID original (que no ha cambiado)
        INSERT INTO tabla_destino (id_col_destino, otra_columna_destino)
        VALUES (:OLD.ID, :NEW.campo_actualizado);
END IF;
END;
/

CREATE OR REPLACE FUNCTION ObtenerDisenoTipo (
    codigo VARCHAR2,   -- Primer parámetro que recibe el código como '001', '002', etc.
    tipo  NUMBER       -- Segundo parámetro que define qué retornar: 1 para diseño, 2 para tipo de tarjeta
)
RETURN VARCHAR2          -- Tipo de dato que devuelve la función
IS
    resultado VARCHAR2(4000);  -- Variable para almacenar el resultado
BEGIN
    -- Usamos un CASE para verificar el código y devolver según el parámetro tipo
CASE
        WHEN codigo = '001' THEN
            IF tipo = 1 THEN
                resultado := '1';     -- Devolver solo el diseño
            ELSIF tipo = 2 THEN
                resultado := '530927'; -- Devolver solo el tipo de tarjeta
END IF;
WHEN codigo = '002' THEN
            IF tipo = 1 THEN
                resultado := '2';
            ELSIF tipo = 2 THEN
                resultado := '530927';
END IF;
WHEN codigo = '003' THEN
            IF tipo = 1 THEN
                resultado := '3';
            ELSIF tipo = 2 THEN
                resultado := '530927';
END IF;
WHEN codigo = '011' THEN
            IF tipo = 1 THEN
                resultado := '1';
            ELSIF tipo = 2 THEN
                resultado := '531013';
END IF;
WHEN codigo = '012' THEN
            IF tipo = 1 THEN
                resultado := '2';
            ELSIF tipo = 2 THEN
                resultado := '531013';
END IF;
WHEN codigo = '013' THEN
            IF tipo = 1 THEN
                resultado := '3';
            ELSIF tipo = 2 THEN
                resultado := '531013';
END IF;
ELSE
            resultado := 'Código inválido';  -- Si el código no es válido
END CASE;

    -- Devolvemos el resultado
RETURN resultado;
END;
/












-- 2 : Actualizacion del cuentas de tarjetas
  MERGE INTO BNSATE05_TARJETA tar
USING (SELECT (SELECT BNSATE00_EMPRESA.B00_ID_EMP
               FROM BNSATE00_EMPRESA
               WHERE B00_NUM_RUC = (select B09_NUM_RUC
                                    from BNSATE09_NOMBRE_CORTO
                                    where B09_COD_INTERNO = mc.B12_COD_INTERNO_TEMP)) as idEmpre,
              cliente.B06_ID_CLI,
              tar.B05_ID_TAR,
              tar.ESTADO,
              mc.B12_CODIGO_PRODUCTO                                                  AS LOGO,
              mc.B12_NUMERO_CUENTA,
              mc.B12_BLOQUEO_1_CUENTA,
              mc.B12_FECHA_APERTURA_CUENTA,
              mc.B12_FECHA_VENCIMIENTO_TARJETA,
              mc.B12_CODIGO_PRODUCTO,
              mc.B12_COD_INTERNO_TEMP
       FROM BNSATE12_RPTA_MC_TEMP mc
                join BNSATE06_CLIENTE cliente
                     on mc.B12_TIPO_DOCUMENTO = cliente.B06_TIPO_DOCUMENTO
                         and mc.B12_NUMERO_DOCUMENTO = LPAD(cliente.B06_NUM_DOCUMENTO, 12, '0')
                join (SELECT tar1.*, eta.B07_ESTADO AS ESTADO
                      from BNSATE05_TARJETA tar1
                               join (SELECT t1.*
                                     FROM BNSATE07_EST_TARJETA t1
                                     WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                                                               FROM BNSATE07_EST_TARJETA t2
                                                               WHERE t1.B05_ID_TAR = t2.B05_ID_TAR)) eta
                                    on tar1.B05_ID_TAR = eta.B05_ID_TAR) tar
                     on cliente.B06_ID_CLI = tar.B06_ID_CLI
       WHERE mc.B12_TIPO_RESPUESTA = '1') rptMC -- FITAR
ON (tar.B00_ID_EMP = rptMC.idEmpre
    and tar.B06_ID_CLI = rptMC.B06_ID_CLI
    and tar.B05_ID_TAR = rptMC.B05_ID_TAR
    and tar.B05_DISENO = substr(rptMC.LOGO, -1)
    and rptMC.ESTADO = '3') -- Estado enviadas
WHEN MATCHED THEN
UPDATE
    SET tar.B05_NUM_CUENTA     = rptMC.,
    tar.B05_FEC_VENCIMIENTO = rptMC.B12_FECHA_VENCIMIENTO_TARJETA;





--20131380101,1,MINISTERIO DE RELACIONES EXTERIORES
--20131312955,1,SUPERINTENDENCIA NACIONAL DE ADUANAS Y ADMINISTRACION TRIBUTARIA
--20307167442,1,COMISION DE PROMOCION DEL PERU PARA LA EXPORTACION Y EL TURISMO-PROMPERU
--20131370645,1,MEF ADMINISTRACION DE LA DEUDA

SELECT t1.*
FROM BNSATE07_EST_TARJETA t1
WHERE B07_FEC_REGISTRO = (SELECT MAX(B07_FEC_REGISTRO)
                          FROM BNSATE07_EST_TARJETA t2
                          WHERE t1.B05_ID_TAR = t2.B05_ID_TAR);

SELECT tar1.B05_ID_TAR,
       MAX(eta1.B07_FEC_REGISTRO) AS B07_FEC_REGISTRO
FROM BN_SATE.BNSATE05_TARJETA tar1
         JOIN
     BN_SATE.BNSATE07_EST_TARJETA eta1
     ON
         eta1.B05_ID_TAR = tar1.B05_ID_TAR
GROUP BY tar1.B05_ID_TAR;



ALTER TABLE BNSATE12_RPTA_MC_TEMP
    add (hola varchar2(10));

ALTER TABLE BNSATE12_RPTA_MC_TEMP
    ADD B12_COD_INTERNO_TEMP VARCHAR2(4);

ALTER TABLE BNSATE12_RPTA_MC_TEMP
DROP COLUMN hola;




select LPAD(
               nvl((SELECT b18_trace_code
                    FROM bnsate18_trace_trama WHERE b05_num_tarjeta = '000530927001110'),'0'), 6, '0') as trace from dual;
