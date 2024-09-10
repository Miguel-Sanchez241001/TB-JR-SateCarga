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





