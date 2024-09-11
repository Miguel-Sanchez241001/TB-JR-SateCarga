-- ========================================
-- Actualización de BNSATE09_NOMBRE_CORTO
-- ========================================

UPDATE BNSATE09_NOMBRE_CORTO
SET B09_NOMBRE = 'PROMPERU'
WHERE B09_NUM_RUC = '20307167442';

-- ========================================
-- Actualización de BNSATE12_RPTA_MC_TEMP nueva columna B12_COD_INTERNO_TEMP
-- ========================================

ALTER TABLE BNSATE12_RPTA_MC_TEMP
    ADD B12_COD_INTERNO_TEMP VARCHAR2(4);

-- ========================================
-- Procedimiento: BNPD_00_SOLICITUD_GEN_1
-- Descripción: Genera una trama de solicitud con información de clientes, tarjetas y empresas.
-- 
-- Este procedimiento realiza las siguientes acciones:
-- 1. Consulta información de clientes, tarjetas y empresas.
-- 2. Genera tres partes de trama: TRAMA1 (cabecera), TRAMA2 (código de trazabilidad) y TRAMA3 (detalles).
-- 3. Inserta el resultado en la tabla BNSATE18_TRACE_TRAMA.
-- 4. Imprime la trama generada en la salida.
-- ========================================

create or replace PROCEDURE BNPD_00_SOLICITUD_GEN_1
    IS
    -- Declaración de variables
    CURSOR c_solicitudes IS
        SELECT
-- CABECERA DE CADA TRAMA   -- 74
LPAD(
        LPAD(UPPER('B'), 1, '0') || -- Tipo de Registro
        LPAD(UPPER('0302'), 4, '0') || -- solicitud
        LPAD(UPPER('0'), 16, '0') || -- Bit map de campos
        LPAD(UPPER('19'), 2, '0') || -- long DE02
        LPAD(UPPER('0'), 19, '0') || -- DE02 - Numero de Cuenta
        TO_CHAR(SYSDATE, 'MMDDHHMISS') -- DE07 - Fecha y Hora:
    , 52, '0')  AS TRAMA1,

LPAD(UPPER(GENERAR_TRACE()), 6, '0') -- DE11 - Trace
                AS TRAMA2,

RPAD(
        LPAD(UPPER('11'), 2, '0') || -- long DE33 valor = "11"
        LPAD(UPPER('00000000000'), 11, '0') || -- DE33 valor = "00000000000"
        -- LPAD(UPPER('926'), 3, '0') || -- long DE48 valor = "926"
        LPAD(UPPER('947'), 3, '0') || -- long DE48 valor = "947"
        -- ESTRUCTURA   TRAMA
        LPAD(UPPER('0101'), 4, '0') || -- Transaccion-type = "0101"
        LPAD(UPPER('0'), 1, '0') || -- Data compres = "0"
        LPAD(UPPER('0000'), 4, '0') || -- Data sequent = "0000"
        LPAD(UPPER('N'), 1, '0') || -- more data = "N"
        LPAD(UPPER('0'), 15, '0') || -- Código BT = 000000000000000
        -- CLIENTE
        LPAD(UPPER(NVL(cli.B06_TIPO_DOCUMENTO, 0)), 1, '0') || -- Tipo de documento
        LPAD(UPPER(NVL(cli.B06_NUM_DOCUMENTO, 0)), 12, '0') || -- Numero de documento
        RPAD(UPPER(NVL(TRIM(cli.B06_APPATERNO) || ' ' ||
                       TRIM(cli.B06_APMATERNO), '0')), 30, ' ') || -- Apellidos funcionario
        RPAD(UPPER(NVL(cli.B06_NOMBRES, '0')), 30, ' ') || -- Nombre funcionario
        UPPER(NVL(cli.B06_EST_CIVIL, ' ')) || -- Estado Civil
        UPPER(NVL(cli.B06_SEXO, ' ')) || -- Sexo
        RPAD(UPPER(NVL(tar.B05_EMAIL, '0')), 57, ' ') || -- E-Mail
        -- CLIENTE DOMICILIO
        LPAD(UPPER(' '), 5, ' ') || -- Dirección domicilio: Tipo de Via
        LPAD(UPPER(NVL(cli.B06_DIRECCION, ' ')), 30, ' ') || -- Dirección domicilio: Nombre de Via
        LPAD(UPPER(' '), 6, ' ') || -- Dirección domicilio: Número de Via/Calle
        LPAD(UPPER(' '), 6, ' ') || -- Dirección domicilio: Departamento
        LPAD(UPPER('0'), 5, '0') || -- Dirección domicilio: Oficina
        LPAD(UPPER('0'), 3, '0') || -- Dirección domicilio: Piso
        LPAD(UPPER('0'), 3, '0') || -- Dirección domicilio: Manzana
        LPAD(UPPER(' '), 3, ' ') || -- Dirección domicilio: Lote
        LPAD(UPPER(' '), 3, ' ') || -- Dirección domicilio: Interior
        LPAD(UPPER(' '), 3, ' ') || -- Dirección domicilio: Sector
        LPAD(UPPER(' '), 5, ' ') || -- Dirección domicilio: Kilometro
        LPAD(UPPER(' '), 5, ' ') || -- Dirección domicilio: Código de zona
        LPAD(UPPER(NVL(cli.B06_DIRECCION_MC, ' ')), 30, ' ') || -- Dirección domicilio: Nombre de zona
        LPAD(UPPER(NVL(cli.B06_UBIGEO, 0)), 9, '0') || -- UBIGEO
        RPAD(UPPER(NVL(cli.B06_REFERENCIA, ' ')), 55, ' ') || -- REFERENCIA
        LPAD(REPLACE(NVL(cli.B06_TELEF_CASA, 0), '-', ''), 10, '0') || -- TELEFONO
        LPAD(UPPER(NVL(tar.B05_NUM_CELULAR, 0)), 10, '0') || -- NUMERO
        -- EMPRESA
        RPAD(UPPER(NVL(emp.B00_RAZON_SOCIAL, ' ')), 30, ' ') || -- Nombre empresa
        RPAD(UPPER(NVL(codeje.B09_NOMBRE, ' ')), 26, ' ') || -- Nombre empresa CORTO
        -- EMPRESA DIRECCION
        LPAD(UPPER('0'), 5, '0') || -- Dirección trabajo: Tipo de Via
        RPAD(UPPER(NVL(emp.B00_DIRECCION, ' ')), 30, ' ') || -- Dirección trabajo: Nombre de Via
        LPAD(UPPER(' '), 6, ' ') || -- Dirección trabajo: Número de Via/Calle
        LPAD(UPPER(' '), 6, ' ') || -- Dirección trabajo: Departamento
        LPAD(UPPER('0'), 5, '0') || -- Dirección trabajo: Oficina
        LPAD(UPPER('0'), 3, '0') || -- Dirección trabajo: Piso
        LPAD(UPPER('0'), 3, '0') || -- Dirección trabajo: Manzana
        LPAD(UPPER(' '), 3, ' ') || -- Dirección trabajo: Lote
        LPAD(UPPER(' '), 3, ' ') || -- Dirección trabajo: Interior
        LPAD(UPPER(' '), 3, ' ') || -- Dirección trabajo: Sector
        LPAD(UPPER(' '), 5, ' ') || -- Dirección trabajo: Kilometro
        LPAD(UPPER(' '), 5, ' ') || -- Dirección trabajo: Código de zona
        LPAD(UPPER(NVL(emp.B00_DIRECCION_MC, ' ')), 30, ' ') || -- Dirección trabajo: Nombre de zona
        LPAD(NVL(emp.B00_UBIGEO, 0), 9, '0') || -- Dirección trabajo: Ubigeo
        RPAD(UPPER(NVL(emp.B00_REFERENCIA, ' ')), 55, ' ') || -- Dirección trabajo: referencia
        LPAD(REPLACE(NVL(emp.B00_TELEFONO, 0), '-', ''), 10, '0') || -- Dirección trabajo: TELEFONO
        LPAD(UPPER(' '), 4, ' ') || -- Dirección trabajo: Telefono Anexo
        LPAD(UPPER(' '), 30, ' ') || -- Nombre conyuge
        LPAD(UPPER(' '), 30, ' ') || -- Nombre trabajo de conyugue
        LPAD(UPPER('0'), 10, '0') || -- Nombre telefono de conyugue
        LPAD(UPPER(' '), 4, ' ') || -- Nombre anexo de telefono de conyugue
        LPAD(UPPER(' '), 55, ' ') || -- Nombre referencia personal
        LPAD(UPPER('3'), 1, ' ') || -- Indicador de envio de correo (Carrier Route)          
        LPAD(UPPER(
                     CASE
                         WHEN tar.B05_TIPO_TARJETA = '530927' and tar.B05_DISENO = '1'
                             THEN '001' -- Logo 001 MC CORP VIATICOS     000530927-01-XXXXXXX-X
                         WHEN tar.B05_TIPO_TARJETA = '530927' and tar.B05_DISENO = '2'
                             THEN '002' -- Logo 002 MC CORP CAJA         000530927-02-XXXXXXX-X
                         WHEN tar.B05_TIPO_TARJETA = '530927' and tar.B05_DISENO = '3'
                             THEN '003' -- Logo 003 MC CORP ENCARGOS     000530927-03-XXXXXXX-X
                         WHEN tar.B05_TIPO_TARJETA = '531013' and tar.B05_DISENO = '1'
                             THEN '011' -- Logo 011 MC CORP BLK VIATICOS 000531013-01-XXXXXXX-X
                         WHEN tar.B05_TIPO_TARJETA = '531013' and tar.B05_DISENO = '2'
                             THEN '012' -- Logo 012 MC CORP BLK CAJA     000531013-02-XXXXXXX-X
                         WHEN tar.B05_TIPO_TARJETA = '531013' and tar.B05_DISENO = '3'
                             THEN '013' -- Logo 013 MC CORP BLK ENCARGOS 000531013-03-XXXXXXX-X
                         ELSE '000'
                         END), 3, ' ')
            || -- Logo tipo tarjeta 
        LPAD(UPPER('000000000'), 9, '0') || -- Línea de crédito
        LPAD(UPPER('604'), 3, '0') || -- Moneda de cuenta
        LPAD(UPPER('00'), 2, '0') || -- Ciclo de cuenta
        RPAD(UPPER(NVL(TO_CHAR(cli.B06_FEC_NACIMIENTO, 'YYYYMMDD'), ' ')), 8, ' ') || -- Fecha de nacimiento
        LPAD(UPPER('0'), 9, '0') || -- Sueldo
        LPAD(UPPER('STD'), 3, '0') || -- PCT
        LPAD(UPPER('0000'), 4, ' ') || -- CDR origen
        LPAD(UPPER('00000'), 5, ' ') || -- Código de funcionario
        LPAD(UPPER('Y'), 1, ' ') || -- Limite de disposición de efectivo
        LPAD(UPPER('3'), 1, ' ') || -- Indicador de envio de EECC
        LPAD(NVL(codeje.B09_COD_INTERNO, '0'), 4, '0') || -- Código de unidad ejecutora
        LPAD(UPPER(' '), 5, ' ') || -- Dirección envío de EECC: Tipo de Via
        LPAD(UPPER(' '), 30, ' ') || -- Dirección envío de EECC: Nombre de Via
        LPAD(UPPER(' '), 6, ' ') || -- Dirección envío de EECC: Número de Via/Calle
        LPAD(UPPER(' '), 6, ' ') || -- Dirección envío de EECC: Departamento
        LPAD(UPPER(' '), 5, ' ') || -- Dirección envío de EECC: Oficina
        LPAD(UPPER(' '), 3, ' ') || -- Dirección envío de EECC: Piso
        LPAD(UPPER(' '), 3, ' ') || -- Dirección envío de EECC: Manzana
        LPAD(UPPER(' '), 3, ' ') || -- Dirección envío de EECC: Lote
        LPAD(UPPER(' '), 3, ' ') || -- Dirección envío de EECC: Interior
        LPAD(UPPER(' '), 3, ' ') || -- Dirección envío de EECC: Sector
        LPAD(UPPER(' '), 5, ' ') || -- Dirección envío de EECC: Kilometro
        LPAD(UPPER(' '), 5, ' ') || -- Dirección envío de EECC: Código de zona
        LPAD(UPPER(' '), 30, ' ') || -- Dirección envío de EECC: Nombre de zona
        LPAD(UPPER('0'), 9, '0') || -- Dirección envío de EECC: Ubigeo
        LPAD(UPPER(' '), 55, ' ') || -- Dirección envío de EECC: Referencia
        LPAD(UPPER('N'), 1, '0') || -- Indicador de Cargo
        LPAD(
                UPPER(CASE
                          WHEN tar.B05_USO_DISP_EFECT = 'T' THEN '1' -- Indicador de disposición de efectivo habilitado
                          WHEN tar.B05_USO_DISP_EFECT = 'N'
                              THEN '0' -- Indicador de disposición de efectivo deshabilitado
                          ELSE '0' -- Valor por defecto para disposición de efectivo
                    END), 1, '0') || -- Indicador de disposición de efectivo (botones)
        '0' || -- Indicador de sobregiro (botones)
        LPAD(
                UPPER(CASE
                          WHEN tar.B05_USO_EXTRANJERO = 'SI' THEN '1' -- Indicador de compras en el exterior habilitadas
                          WHEN tar.B05_USO_EXTRANJERO = 'NO'
                              THEN '0' -- Indicador de compras en el exterior deshabilitadas
                          ELSE '0' -- Valor por defecto para compras en el exterior
                    END), 1, '0') || -- Indicador de compras en el exterior (botones)
        LPAD(
                UPPER(CASE
                          WHEN tar.B05_USO_COMPRAS_WEB = 'SI' THEN '1' -- Indicador de compras web habilitadas
                          WHEN tar.B05_USO_COMPRAS_WEB = 'NO' THEN '0' -- Indicador de compras web deshabilitadas
                          ELSE '0' -- Valor por defecto para compras web
                    END), 1, '0') -- Indicador de compras web (botones)
    , 963, '0') AS TRAMA3
        FROM BN_SATE.BNSATE05_TARJETA tar
                 JOIN BN_SATE.BNSATE06_CLIENTE cli
                      ON tar.B06_ID_CLI = cli.B06_ID_CLI
                 JOIN BN_SATE.BNSATE00_EMPRESA emp
                      ON tar.B00_ID_EMP = emp.B00_ID_EMP

                 JOIN BN_SATE.BNSATE09_NOMBRE_CORTO codeje
                      ON emp.B00_NUM_RUC = codeje.B09_NUM_RUC

                 JOIN BN_SATE.BNSATE07_EST_TARJETA eta
                      ON eta.B05_ID_TAR = tar.B05_ID_TAR
                 INNER JOIN (SELECT tar1.B05_ID_TAR, MAX(eta1.B07_FEC_REGISTRO) B07_FEC_REGISTRO
                             FROM BN_SATE.BNSATE05_TARJETA tar1
                                      JOIN BNSATE07_EST_TARJETA eta1 ON eta1.B05_ID_TAR = tar1.B05_ID_TAR
                             GROUP BY tar1.B05_ID_TAR) q
                            ON tar.B05_ID_TAR = q.B05_ID_TAR AND eta.B07_FEC_REGISTRO = q.B07_FEC_REGISTRO
        WHERE eta.B07_ESTADO = 2 ;
    v_total_registros NUMBER := 0; -- Inicializamos la variable a cero

BEGIN
    -- Sumar uno a la variable en cada iteración del bucle
    FOR FILA IN c_solicitudes
        LOOP
            v_total_registros := v_total_registros + 1;
        END LOOP;

    -- PRIMERA LINEA HEADER A19
    dbms_output.put_line(
            'A' || --Tipo de Registro "A"
            '019' || -- Código de emisor: "019"
            TO_CHAR(SYSDATE, 'DDMMYYYY') || -- FECHA ACTUAL
            LPAD(v_total_registros, 6, '0') || -- Número Total de Registros de Datos
            LPAD(' ', 982, ' '));

    -- REGISTRANDO TRAMAS TXT
    FOR FILA IN c_solicitudes
        LOOP
            INSERT INTO BNSATE18_TRACE_TRAMA (B18_TRACE_CODE, B18_FECHA, B18_DATOS)
            VALUES (FILA.TRAMA2, SYSDATE, FILA.TRAMA1 || FILA.TRAMA2 || FILA.TRAMA3);
            dbms_output.put_line(FILA.TRAMA1 || FILA.TRAMA2 || FILA.TRAMA3);
        END LOOP;
END BNPD_00_SOLICITUD_GEN_1;
/

-- ========================================
-- Procedimiento: BNPD_13_ASIGNACION_GEN_1
-- Descripción: Genera tramas de asignación basadas en datos de asignaciones y tarjetas.
-- 
-- Este procedimiento realiza las siguientes acciones:
-- 1. Utiliza dos cursores para generar tramas:
--    a) c_one_asignation: Para asignaciones con un estado específico.
--    b) c_two_asignation: Para asignaciones con múltiples repeticiones.
-- 2. Cuenta el número total de registros.
-- 3. Genera una línea de encabezado con el total de registros.
-- 4. Procesa y imprime las tramas generadas por ambos cursores.
-- ========================================

create or replace PROCEDURE BNPD_13_ASIGNACION_GEN_1 IS

    CURSOR c_one_asignation IS
        WITH MaxDateRecords AS (SELECT COUNT(*)               AS estCount,
                                       B04_ID_CAS,
                                       MAX(B019_FEC_REGISTRO) AS MAX_FECHA
                                FROM BNSATE19_EST_ASIGNACION
                                GROUP BY B04_ID_CAS)
        SELECT LPAD(
                       LPAD(UPPER('B'), 1, '0') ||
                       LPAD(UPPER('0302'), 4, '0') ||
                       LPAD(UPPER('4220000080010000'), 16, '0') ||
                       LPAD(UPPER('19'), 2, '0') ||
                       LPAD(NVL(tar.B05_NUM_CUENTA, '0'), 19, '0') ||
                       TO_CHAR(SYSDATE, 'MMDDHHMISS') || -- DE07 - Fecha y Hora:
                       LPAD(
                               nvl((SELECT b18_trace_code
                                    FROM bnsate18_trace_trama
                                    WHERE b05_num_tarjeta = tar.B05_NUM_TARJETA), '0'), 6, '0') ||
                       LPAD(UPPER('11'), 2, '0') ||
                       LPAD(UPPER('00000000000'), 11, '0') ||
                       LPAD(UPPER('081'), 3, '0')
                   , 74, '0')                                                                           AS PART1,
               RPAD(LPAD('0117', 4, '0') || '0' || '0000' || 'N' || asi.b04_linea ||
                    TO_CHAR(asi.b04_fecha_inicio_linea, 'DDMMYYYY') || TO_CHAR(asi.b04_fecha_fin_linea, 'DDMMYYYY') ||
                    'N' || 'N' || LPAD(NVL(tar.B05_PORCENTAJE_DISP_EFECT, '000000'), 7, '0'), 926, ' ') AS linea
        FROM BNSATE04_ASIGNACION asi
                 JOIN
             bnsate05_tarjeta tar
             ON tar.b05_id_tar = asi.b05_id_tar
                 JOIN
             BNSATE19_EST_ASIGNACION etasi
             ON etasi.B04_ID_CAS = asi.B04_ID_CAS
                 AND etasi.B019_FEC_REGISTRO = (SELECT MAX_FECHA
                                                FROM MaxDateRecords
                                                WHERE MaxDateRecords.B04_ID_CAS = asi.B04_ID_CAS
                                                  AND MaxDateRecords.estCount = 1)
                 JOIN
             (SELECT COUNT(*) AS AsigCount, B05_ID_TAR, MAX(B04_FECHA_REGISTRO) AS B04_FECHA_REGISTRO
              FROM BNSATE04_ASIGNACION
              GROUP BY B05_ID_TAR) q
             ON q.B05_ID_TAR = asi.B05_ID_TAR
        WHERE etasi.B019_ESTADO = '1'
          AND q.AsigCount = 1
        ORDER BY tar.b05_num_cuenta;
    CURSOR c_two_asignation IS
        -- Similar structure as c_one_asignation
        WITH MaxDateRecords AS (SELECT COUNT(*)               AS estCount,
                                       B04_ID_CAS,
                                       MAX(B019_FEC_REGISTRO) AS MAX_FECHA
                                FROM BNSATE19_EST_ASIGNACION
                                GROUP BY B04_ID_CAS),
             NumberSeries AS (SELECT LEVEL AS repetition
                              FROM DUAL
                              CONNECT BY LEVEL <= 4)
        SELECT LPAD(
                       LPAD(UPPER('B'), 1, '0') ||
                       LPAD(UPPER('0302'), 4, '0') ||
                       LPAD(UPPER('4220000080010000'), 16, '0') ||
                       LPAD(UPPER('19'), 2, '0') ||
                       LPAD(NVL(tar.B05_NUM_CUENTA, '0'), 19, '0') ||
                       TO_CHAR(SYSDATE, 'MMDDHHMISS') ||
                       LPAD(
                               nvl((SELECT b18_trace_code
                                    FROM bnsate18_trace_trama
                                    WHERE b05_num_tarjeta = tar.B05_NUM_TARJETA), '0'), 6, '0') ||
                       LPAD(UPPER('11'), 2, '0') ||
                       LPAD(UPPER('00000000000'), 11, '0') ||
                       LPAD(UPPER('081'), 3, '0')
                   , 74, '0') AS PART1,
               CASE
                   WHEN n.repetition = 1 THEN RPAD(
                           LPAD('0119', 4, '0') || '0' || '0000' || 'N' || '1017' || '009' || asi.b04_linea, 926, ' ')
                   WHEN n.repetition = 2 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' || '1119' || '008' ||
                                                   TO_CHAR(asi.b04_fecha_inicio_linea, 'DDMMYYYY'), 926, ' ')
                   WHEN n.repetition = 3 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' || '1120' || '008' ||
                                                   TO_CHAR(asi.b04_fecha_fin_linea, 'DDMMYYYY'), 926, ' ')
                   WHEN n.repetition = 4 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' || '1123' || '007' ||
                                                   LPAD(NVL(tar.B05_PORCENTAJE_DISP_EFECT, '000000'), 7, '0'), 926, ' ')
                   END        AS linea
        FROM BNSATE04_ASIGNACION asi
                 JOIN
             bnsate05_tarjeta tar
             ON tar.b05_id_tar = asi.b05_id_tar
                 JOIN
             BNSATE19_EST_ASIGNACION etasi
             ON etasi.B04_ID_CAS = asi.B04_ID_CAS
                 AND etasi.B019_FEC_REGISTRO = (SELECT MAX_FECHA
                                                FROM MaxDateRecords
                                                WHERE MaxDateRecords.B04_ID_CAS = asi.B04_ID_CAS
                                                  AND MaxDateRecords.estCount = 1)
                 JOIN
             (SELECT COUNT(*) AS AsigCount, B05_ID_TAR, MAX(B04_FECHA_REGISTRO) AS B04_FECHA_REGISTRO
              FROM BNSATE04_ASIGNACION
              GROUP BY B05_ID_TAR) q
             ON q.B05_ID_TAR = asi.B05_ID_TAR
                 CROSS JOIN
             NumberSeries n
        WHERE etasi.B019_ESTADO = '1'
          AND q.AsigCount >= 2
        ORDER BY tar.b05_num_cuenta, n.repetition;

    -- Variables para almacenar las líneas obtenidas del cursor
    v_linea1           VARCHAR2(2000);
    v_linea2           VARCHAR2(2000);

    -- Variable para contar el número de registros
    v_numero_registros NUMBER := 0;

BEGIN

    -- Contar los registros antes de la apertura del cursor
    OPEN c_one_asignation;
    LOOP
        FETCH c_one_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_one_asignation%NOTFOUND;
        v_numero_registros := v_numero_registros + 1;
    END LOOP;
    CLOSE c_one_asignation;

    OPEN c_two_asignation;
    LOOP
        FETCH c_two_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_two_asignation%NOTFOUND;
        v_numero_registros := v_numero_registros + 1;
    END LOOP;
    CLOSE c_two_asignation;

    -- Primera línea de encabezado (header) con formato específico
    DBMS_OUTPUT.PUT_LINE('A' || '019' ||
                         TO_CHAR(SYSDATE, 'DDMMYYYY') ||
                         LPAD(v_numero_registros, 6, '0') || LPAD(' ', 982, ' '));

    OPEN c_one_asignation;
    LOOP
        FETCH c_one_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_one_asignation%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_linea1 || v_linea2); -- Imprimir la línea generada
    END LOOP;
    CLOSE c_one_asignation;

    OPEN c_two_asignation;
    LOOP
        FETCH c_two_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_two_asignation%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_linea1 || v_linea2); -- Imprimir la línea generada
    END LOOP;
    CLOSE c_two_asignation;

END BNPD_13_ASIGNACION_GEN_1;
/


-- ========================================
-- Procedimiento: BNPD_14_ASIGNACION_GEN_2
-- Descripción: Inserta registros en la tabla BNSATE19_EST_ASIGNACION para asignaciones enviadas a IZIPAY.
-- 
-- Este procedimiento realiza las siguientes acciones:
-- 1. Selecciona las asignaciones de la tabla BNSATE04_ASIGNACION.
-- 2. Une estas asignaciones con la tabla BNSATE19_EST_ASIGNACION para obtener el estado más reciente (estado = 1) de cada tarjeta.
-- 3. Inserta en la tabla BNSATE19_EST_ASIGNACION los registros seleccionados con el estado '2' (Enviadas IZIPAY) y la fecha actual como fecha de registro.
-- ========================================

create or replace PROCEDURE BNPD_14_ASIGNACION_GEN_2
    IS
BEGIN
    INSERT INTO BN_SATE.BNSATE19_EST_ASIGNACION (B04_ID_CAS, -- Identificador de tarjeta
                                                 B019_ESTADO, -- Estado de la tarjeta
                                                 B019_FEC_REGISTRO -- Motivo del estado
    )

    SELECT asi.B04_ID_CAS, -- Identificador de tarjeta
           '2',            -- Estado '2' Enviadas IZIPAY
           SYSDATE         -- Fecha de registro actual
    FROM BNSATE04_ASIGNACION asi
             -- Paso 3: Une la tabla BNSATE05_TARJETA con BNSATE07_EST_TARJETA usando una combinación de unión
             JOIN
         (SELECT B019_EASI,
                 B04_ID_CAS,
                 B019_ESTADO,
                 B019_FEC_REGISTRO
          FROM BNSATE19_EST_ASIGNACION t1
          WHERE B019_FEC_REGISTRO = (SELECT MAX(B019_FEC_REGISTRO)
                                     FROM BNSATE19_EST_ASIGNACION t2
                                     WHERE t1.B04_ID_CAS = t2.B04_ID_CAS)) etasig
         ON
             etasig.B04_ID_CAS = asi.B04_ID_CAS

    WHERE etasig.B019_ESTADO = 1;
END BNPD_14_ASIGNACION_GEN_2;
/


-- ========================================
-- Procedimiento: BNPD_09_CUENTA_ACT
-- Descripción: Actualiza cuentas y asignaciones basadas en respuestas del MEF.
-- 
-- Este procedimiento realiza las siguientes acciones:
-- 1. Inserta nuevas asignaciones en BNSATE04_ASIGNACION.
-- 2. Actualiza información de tarjetas en BNSATE05_TARJETA.
-- 3. Actualiza información de empresas en BNSATE00_EMPRESA.
-- 4. Elimina registros procesados de BNSATE13_RPTA_MEF_TEMP.
-- ========================================

DROP PROCEDURE BNPD_09_CUENTA_ACT;


create or replace PROCEDURE BNPD_09_CUENTA_ACT
    IS
BEGIN
    INSERT INTO BN_SATE.BNSATE04_ASIGNACION
    (B05_ID_TAR, B04_CODIGO_ASIGNACION, B04_FECHA_INICIO_LINEA, B04_FECHA_FIN_LINEA, B04_FECHA_REGISTRO, B04_LINEA,
     B04_CUENTA_EXPEDIENTE)
        (SELECT tar.B05_ID_TAR,
                mef.B13_SEC_OPERACION,
                mef.B13_FEC_INICIO_AUT,
                mef.B13_FEC_FIN_AUT,
                sysdate,
                mef.B13_IMPORTE,
                mef.B13_SEC_OPERACION_REF
         from BNSATE13_RPTA_MEF_TEMP mef
                  join BNSATE00_EMPRESA empre
                       on empre.B00_NUM_RUC = mef.B13_RUC_MEF_TEMP
                  join BNSATE05_TARJETA tar
                       on tar.B00_ID_EMP = empre.B00_ID_EMP and tar.B05_DISENO = SUBSTR(mef.B13_TIPO_TARJETA, -1)
                  join (SELECT t.B05_ID_TAR,
                               t.B07_ESTADO,
                               t.B07_FEC_REGISTRO
                        FROM BNSATE07_EST_TARJETA t
                                 JOIN (
                            -- Subconsulta para obtener la última fecha de cada tarjeta
                            SELECT B05_ID_TAR,
                                   MAX(B07_FEC_REGISTRO) AS max_fecha
                            FROM BNSATE07_EST_TARJETA
                            GROUP BY B05_ID_TAR) t_max
                                      ON t.B05_ID_TAR = t_max.B05_ID_TAR
                                          AND
                                         t.B07_FEC_REGISTRO = t_max.max_fecha -- Agrupa los resultados por `B04_ID_CAS`
         ) B07ET
                       on tar.B05_ID_TAR = B07ET.B05_ID_TAR
                  join BNSATE06_CLIENTE cliente
                       on tar.B06_ID_CLI = cliente.B06_ID_CLI
                           and cliente.B06_TIPO_DOCUMENTO = SUBSTR(mef.B13_TIPO_DOCUMENTO, -1)
                           AND cliente.B06_NUM_DOCUMENTO = SUBSTR(mef.B13_NUM_DOCUMENTO, -8)
         where B07ET.B07_ESTADO = '5');

    MERGE INTO BN_SATE.BNSATE05_TARJETA tar
    USING (SELECT mef.B13_FEC_INICIO_AUT,
                  mef.B13_FEC_INICIO_AUT AS B13_FEC_INICIO_AUT_DUPLICATE,
                  mef.B13_FEC_FIN_AUT,
                  mef.B13_IMPORTE,
                  tar.B05_ID_TAR
           FROM BNSATE13_RPTA_MEF_TEMP mef
                    JOIN BNSATE00_EMPRESA empre
                         ON empre.B00_NUM_RUC = mef.B13_RUC_MEF_TEMP
                    JOIN BNSATE05_TARJETA tar
                         ON tar.B00_ID_EMP = empre.B00_ID_EMP
                             AND tar.B05_DISENO = SUBSTR(mef.B13_TIPO_TARJETA, -1)
                    JOIN (SELECT t.B05_ID_TAR,
                                 t.B07_ESTADO,
                                 t.B07_FEC_REGISTRO
                          FROM BNSATE07_EST_TARJETA t
                                   JOIN (
                              -- Subconsulta para obtener la última fecha de cada tarjeta
                              SELECT B05_ID_TAR,
                                     MAX(B07_FEC_REGISTRO) AS max_fecha
                              FROM BNSATE07_EST_TARJETA
                              GROUP BY B05_ID_TAR) t_max
                                        ON t.B05_ID_TAR = t_max.B05_ID_TAR
                                            AND t.B07_FEC_REGISTRO = t_max.max_fecha) B07ET
                         ON tar.B05_ID_TAR = B07ET.B05_ID_TAR
                    JOIN BNSATE06_CLIENTE cliente
                         ON tar.B06_ID_CLI = cliente.B06_ID_CLI
                             AND cliente.B06_TIPO_DOCUMENTO = SUBSTR(mef.B13_TIPO_DOCUMENTO, -1)
                             AND cliente.B06_NUM_DOCUMENTO =
                                 CASE
                                     WHEN SUBSTR(mef.B13_TIPO_DOCUMENTO, -1) = '1'
                                         THEN SUBSTR(mef.B13_NUM_DOCUMENTO, -8)
                                     WHEN SUBSTR(mef.B13_TIPO_DOCUMENTO, -1) = '4'
                                         THEN SUBSTR(mef.B13_NUM_DOCUMENTO, -12)
                                     END
           WHERE B07ET.B07_ESTADO = '5') data
    ON (tar.B05_ID_TAR = data.B05_ID_TAR)
    WHEN MATCHED THEN
        UPDATE
        SET tar.B05_FEC_AUTORIZACION     = data.B13_FEC_INICIO_AUT,
            tar.B05_FEC_INICIO_LINEA     = data.B13_FEC_INICIO_AUT,
            tar.B05_FEC_TERMINO_LINEA    = data.B13_FEC_FIN_AUT,
            tar.B05_MONTO_LINEA_ASIGNADO = data.B13_IMPORTE;

    MERGE INTO BNSATE00_EMPRESA e
    USING (SELECT DISTINCT rpt.B13_RUC_MEF_TEMP, rpt.B13_CUENTA_CARGO
           FROM BN_SATE.BNSATE13_RPTA_MEF_TEMP rpt) c
    ON (e.B00_NUM_RUC = c.B13_RUC_MEF_TEMP)
    WHEN MATCHED THEN
        UPDATE SET e.B00_NUM_CUENTA_CORRIENTE = c.B13_CUENTA_CARGO;

    DELETE FROM BN_SATE.BNSATE13_RPTA_MEF_TEMP rpt;

    COMMIT;
END BNPD_09_CUENTA_ACT;
/
-- ========================================
-- Procedimiento: BNPD_02_SOLICITUD_ACT
-- Descripción: Actualiza información de tarjetas basada en respuestas de MC.
-- 
-- Este procedimiento realiza las siguientes acciones:
-- 1. Actualiza la tabla BNSATE05_TARJETA con información de BNSATE12_RPTA_MC_TEMP.
-- 2. Elimina registros procesados de BNSATE12_RPTA_MC_TEMP.
-- 3. Maneja excepciones y realiza rollback en caso de error.
-- ========================================

DROP PROCEDURE BNPD_02_SOLICITUD_ACT;


create or replace PROCEDURE BNPD_02_SOLICITUD_ACT
    IS
BEGIN
    BEGIN
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
               WHERE mc.B12_TIPO_RESPUESTA = '0') rptMC -- FICTA
        ON (tar.B00_ID_EMP = rptMC.idEmpre
            and tar.B06_ID_CLI = rptMC.B06_ID_CLI
            and tar.B05_ID_TAR = rptMC.B05_ID_TAR
            and tar.B05_DISENO = ObtenerDisenoTipo(rptMC.LOGO, 1)
            and tar.B05_TIPO_TARJETA = ObtenerDisenoTipo(rptMC.LOGO, 2)
            and rptMC.ESTADO = '3') -- Estado enviadas
        WHEN MATCHED THEN
            UPDATE
            SET tar.B05_NUM_TARJETA         = rptMC.B12_NUMERO_TARJETA,
                tar.B05_FEC_VENCIMIENTO     = rptMC.B12_FECHA_VENCIMIENTO_TARJETA,
                tar.B05_NUM_CUENTA          = rptMC.B12_NUMERO_CUENTA,
                tar.B05_FEC_APERTURA_CUENTA = rptMC.B12_FECHA_APERTURA_CUENTA,
                tar.B05_EST_CUENTA          = rptMC.B12_BLOQUEO_1_CUENTA;

        -- Paso 3: Elimina registros de BN_SATE.BNSATE12_RPTA_MC_TEMP con tipo de respuesta '0'
        DELETE
        FROM BN_SATE.BNSATE12_RPTA_MC_TEMP rpt
        WHERE rpt.B12_TIPO_RESPUESTA = '0';

        -- Paso 4: Realiza el commit de las transacciones
        COMMIT;
    EXCEPTION
        -- Captura de errores
        WHEN OTHERS THEN
            -- Rollback en caso de error
            ROLLBACK;
            -- Manejo del error, puedes registrar el error o lanzar una excepción
            DBMS_OUTPUT.PUT_LINE('Error en el procedimiento BNPD_02_SOLICITUD_ACT: ' || SQLERRM);
    END;

END BNPD_02_SOLICITUD_ACT;
/

-- ========================================
-- Trigger: BNTG_04_ASIGNACION
-- Descripción: Genera un ID para nuevas asignaciones antes de la inserción.
-- ========================================

DROP TRIGGER BNTG_04_ASIGNACION;

CREATE OR REPLACE TRIGGER BNTG_04_ASIGNACION
    before insert
    on BNSATE04_ASIGNACION
    for each row
BEGIN
  IF :new.B04_ID_CAS IS NULL THEN
    SELECT BNSQ_04_ASIGNACION.nextval INTO :new.B04_ID_CAS FROM DUAL;
  END IF;
END;
/

-- ========================================
-- Trigger: BNTG_04_ASIGNACION_AFTER
-- Descripción: Inserta un registro en BNSATE19_EST_ASIGNACION después de una nueva asignación.
-- ========================================

CREATE OR REPLACE TRIGGER BNTG_04_ASIGNACION_AFTER
AFTER INSERT
ON BNSATE04_ASIGNACION
FOR EACH ROW
BEGIN
  -- Supongamos que la tabla de destino es BNSATE04_LOG
  INSERT INTO BNSATE19_EST_ASIGNACION (
    B04_ID_CAS,B019_ESTADO,B019_FEC_REGISTRO) VALUES (
    :new.B04_ID_CAS, -- Utiliza el ID generado
    '1',             -- Valor de estado (ajusta según necesidad)
    SYSDATE          -- Fecha actual
  );             -- Fecha y hora actual
END;
/
-- ========================================
-- Función: ObtenerDisenoTipo
-- Descripción: Retorna el diseño o tipo de tarjeta basado en un código y un parámetro de tipo.
-- ========================================

CREATE OR REPLACE FUNCTION ObtenerDisenoTipo (
    codigo VARCHAR2,   -- Primer parámetro que recibe el código como '001', '002', etc.
    tipo  NUMBER       -- Segundo parámetro que define qué retornar: 1 para diseño, 2 para tipo de tarjeta
)
RETURN VARCHAR2          -- Tipo de dato que devuelve la función
IS
    resultado VARCHAR2(6);  -- Variable para almacenar el resultado
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
-- ========================================
-- Trigger: BNTG_05_TARJETA_EST
-- Descripción: Actualiza el estado de la tarjeta después de ciertas actualizaciones en BNSATE05_TARJETA.
-- ========================================

CREATE OR REPLACE TRIGGER BNTG_05_TARJETA_EST
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

-- ========================================
-- Procedure: Anonima Recompilar objetos
-- ========================================

BEGIN
  FOR rec IN (SELECT object_name, object_type
              FROM all_objects
              WHERE object_type IN ('PROCEDURE', 'FUNCTION')
              AND status = 'INVALID') LOOP
    EXECUTE IMMEDIATE 'ALTER ' || rec.object_type || ' ' || rec.object_name || ' COMPILE';
  END LOOP;
END;
/