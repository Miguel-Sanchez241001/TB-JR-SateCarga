create or replace NONEDITIONABLE PROCEDURE BNPD_13_ASIGNACION
IS

CURSOR c_one_asignation IS
        WITH MaxDateRecords AS (
            SELECT
                COUNT(*) AS estCount,
                B04_ID_CAS,
                MAX(B019_FEC_REGISTRO) AS MAX_FECHA
            FROM
                BNSATE19_EST_ASIGNACION
            GROUP BY
                B04_ID_CAS
        )
        SELECT
            LPAD(
                LPAD(UPPER('B'), 1, '0') ||
                LPAD(UPPER('0302'), 4, '0') ||
                LPAD(UPPER('4220000080010000'), 16, '0') ||
                LPAD(UPPER('19'), 2, '0') ||
                LPAD(NVL(tar.b05_num_cuenta, '9'), 19, '0') ||
                TO_CHAR(TO_DATE('19/02/2024', 'DD/MM/YYYY'), 'MMDDHHMISS') ||
                LPAD(
                    (SELECT b18_trace_code FROM bnsate18_trace_trama WHERE b05_num_tarjeta = tar.b05_num_tarjeta), 6, '0') ||
                LPAD(UPPER('11'), 2, '0') ||
                LPAD(UPPER('00000000000'), 11, '0') ||
                LPAD(UPPER('081'), 3, '0')
             , 74, '0') AS PART1,
            RPAD(LPAD('0117', 4, '0') || '0' || '0000' || 'N' || asi.b04_linea || TO_CHAR(asi.b04_fecha_inicio_linea, 'DDMMYYYY') || TO_CHAR(asi.b04_fecha_fin_linea, 'DDMMYYYY') || 'N' || 'N' || '0050000', 926, ' ') AS linea
        FROM
            BNSATE04_ASIGNACION asi
        JOIN
            bnsate05_tarjeta tar
            ON tar.b05_id_tar = asi.b05_id_tar
        JOIN
            BNSATE19_EST_ASIGNACION etasi
            ON etasi.B04_ID_CAS = asi.B04_ID_CAS
            AND etasi.B019_FEC_REGISTRO = (
                SELECT MAX_FECHA
                FROM MaxDateRecords
                WHERE MaxDateRecords.B04_ID_CAS = asi.B04_ID_CAS
                  AND MaxDateRecords.estCount = 1
            )
        JOIN
            (SELECT COUNT(*) AS AsigCount, B05_ID_TAR, MAX(B04_FECHA_REGISTRO) AS B04_FECHA_REGISTRO
             FROM BNSATE04_ASIGNACION
             GROUP BY B05_ID_TAR) q
            ON q.B05_ID_TAR = asi.B05_ID_TAR
         WHERE
            etasi.B019_ESTADO = '1'
            AND q.AsigCount = 1
        ORDER BY tar.b05_num_cuenta;

CURSOR c_two_asignation IS
         WITH MaxDateRecords AS (
            SELECT
                COUNT(*) AS estCount,
                B04_ID_CAS,
                MAX(B019_FEC_REGISTRO) AS MAX_FECHA
            FROM
                BNSATE19_EST_ASIGNACION
            GROUP BY
                B04_ID_CAS
        ),
        NumberSeries AS (
    SELECT LEVEL AS repetition
    FROM DUAL
    CONNECT BY LEVEL <= 4
)
        SELECT
            LPAD(
                LPAD(UPPER('B'), 1, '0') ||
                LPAD(UPPER('0302'), 4, '0') ||
                LPAD(UPPER('4220000080010000'), 16, '0') ||
                LPAD(UPPER('19'), 2, '0') ||
                LPAD(NVL(tar.b05_num_cuenta, '9'), 19, '0') ||
                TO_CHAR(TO_DATE('19/02/2024', 'DD/MM/YYYY'), 'MMDDHHMISS') ||
                LPAD(
                    (SELECT b18_trace_code FROM bnsate18_trace_trama WHERE b05_num_tarjeta = tar.b05_num_tarjeta), 6, '0') ||
                LPAD(UPPER('11'), 2, '0') ||
                LPAD(UPPER('00000000000'), 11, '0') ||
                LPAD(UPPER('081'), 3, '0')
             , 74, '0') AS PART1,

             CASE
                WHEN n.repetition = 1 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' ||'1017' || '009'  || asi.b04_linea , 926, ' ')
                WHEN n.repetition = 2 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' ||'1119' || '008'  || TO_CHAR(asi.b04_fecha_inicio_linea, 'DDMMYYYY') , 926, ' ')
                WHEN n.repetition = 3 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' ||'1120' || '008'  || TO_CHAR(asi.b04_fecha_fin_linea, 'DDMMYYYY') , 926, ' ')
                WHEN n.repetition = 4 THEN RPAD(LPAD('0119', 4, '0') || '0' || '0000' || 'N' ||'1123' || '007'  || '0050000', 926, ' ')
            END AS linea
        FROM
            BNSATE04_ASIGNACION asi
        JOIN
            bnsate05_tarjeta tar
            ON tar.b05_id_tar = asi.b05_id_tar
        JOIN
            BNSATE19_EST_ASIGNACION etasi
            ON etasi.B04_ID_CAS = asi.B04_ID_CAS
            AND etasi.B019_FEC_REGISTRO = (
                SELECT MAX_FECHA
                FROM MaxDateRecords
                WHERE MaxDateRecords.B04_ID_CAS = asi.B04_ID_CAS
                  AND MaxDateRecords.estCount = 1
            )
        JOIN
            (SELECT COUNT(*) AS AsigCount, B05_ID_TAR, MAX(B04_FECHA_REGISTRO) AS B04_FECHA_REGISTRO
             FROM BNSATE04_ASIGNACION
             GROUP BY B05_ID_TAR) q
            ON q.B05_ID_TAR = asi.B05_ID_TAR
        CROSS JOIN
    NumberSeries n
         WHERE
            etasi.B019_ESTADO = '1'
            AND q.AsigCount >= 2
        ORDER BY tar.b05_num_cuenta , n.repetition;






    -- Definición del tipo de cursor de referencia
    TYPE t_cursor IS REF CURSOR;
    c_lineas t_cursor;  -- Declaración del cursor

    -- Variables para almacenar las líneas obtenidas del cursor
    v_linea1 VARCHAR2(1021);
    v_linea2 VARCHAR2(1021);

    -- Variable para contar el número de registros
    v_numero_registros NUMBER := 0;
    v_count NUMBER := 0;
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
    DBMS_OUTPUT.PUT_LINE('A' || '019' || TO_CHAR(TO_DATE('19/02/2024', 'DD/MM/YYYY'), 'DDMMYYY') || LPAD(v_numero_registros, 6, '0') || LPAD(' ', 982, ' '));


    DBMS_OUTPUT.ENABLE(1000000);
    OPEN c_one_asignation;
    LOOP
        FETCH c_one_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_one_asignation%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_linea1 || v_linea2 );  -- Imprimir la línea generada
    END LOOP;
    CLOSE c_one_asignation;
 OPEN c_two_asignation;
    LOOP
        FETCH c_two_asignation INTO v_linea1, v_linea2;
        EXIT WHEN c_two_asignation%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_linea1 || v_linea2 );  -- Imprimir la línea generada
    END LOOP;
    CLOSE c_two_asignation;

END BNPD_13_ASIGNACION;