package pe.com.bn.Enum;

import java.util.ArrayList;
import java.util.List;

public enum Bnsate12RptaMcTemp {

    // Columnas de la tabla con nombre, posición de inicio, posición de fin, y si permite nulos
    TRACE("B12_TRACE", 1, 1, true),
     BLQ2_CTA("B12_BLOQUEO_2_CUENTA", 1, 1, true),


    FEC_APE_TARJ("B12_FECHA_APERTURA_TARJETA", 512, 7, true),
    NUM_TARJ("B12_NUMERO_TARJETA", 493, 18, true),
    FEC_VENC_TARJ("B12_FECHA_VENCIMIENTO_TARJETA", 520, 7, true),
    TIPO_DOC("B12_TIPO_DOCUMENTO", 69, 0, true),
    NUM_DOC("B12_NUMERO_DOCUMENTO", 70, 11, true),
    APELLIDOS("B12_APELLIDOS", 48, 14, true),
    NOMBRE("B12_NOMBRE", 48, 14, true),
    FEC_REG("B12_FECHA_REGISTRO", 1, 2, true),
    COD_PROD("B12_CODIGO_PRODUCTO", 45, 2, true),
    TIPO_RESP("B12_TIPO_RESPUESTA", 2, 1, true),
    COD_UNIDAD("B12_COD_INTERNO_TEMP", 489, 3, true),
    NUM_CUENTA("B12_NUMERO_CUENTA", 7, 18, true),
    FEC_APE_CTA("B12_FECHA_APERTURA_CUENTA", 117, 7, true),
    BLQ1_CTA("B12_BLOQUEO_1_CUENTA", 111, 0, true),
    SALDO("B12_LINEA_CREDITO", 229, 12, true),

    BLQ1_TARJ("B12_BLOQUEO_1_TARJETA", 140, 150, true),
    COD_BLQ("B12_CODIGO_BLOQUEO", 111, 0, true),
    LIN_CRED("B12_LINEA_CREDITO", 2, 2, true),
    MOT_BLQ("B12_MOTIVO_BLOQUEO", 1, 2, true),
    CEL("B12_CELULAR", 1, 2, true),
    EMAIL("B12_EMAIL", 1, 2, true),
    COD_ASIG("B12_CODIGO_ASIGNACION", 1, 2, true),
    FEC_INI_LIN("B12_FECHA_INICIO_LINEA", 1, 2, true),
    FEC_FIN_LIN("B12_FECHA_FIN_LINEA", 1, 2, true);

    private final String columnName;
    private final int start;
    private final int end;
    private final boolean nullable;

    Bnsate12RptaMcTemp(String columnName, int start, int end, boolean nullable) {
        this.columnName = columnName;
        this.start = start;
        this.end = end;
        this.nullable = nullable;
    }

    public String getColumnName() {
        return columnName;
    }

    public int getStart() {
        return start;
    }

    public int getEnd() {
        return end;
    }

    public boolean isNullable() {
        return nullable;
    }

    public static List<Bnsate12RptaMcTemp> getFitarQuery() {
        List<Bnsate12RptaMcTemp> mcFitar = new ArrayList<>();
        mcFitar.add(TIPO_DOC);
        mcFitar.add(NUM_DOC);
        mcFitar.add(APELLIDOS);
        mcFitar.add(NOMBRE);
        mcFitar.add(FEC_REG);
        mcFitar.add(COD_PROD);
        mcFitar.add(NUM_TARJ);
        mcFitar.add(FEC_APE_TARJ);
        mcFitar.add(FEC_VENC_TARJ);
        mcFitar.add(TIPO_RESP);
        mcFitar.add(COD_UNIDAD);
        mcFitar.add(NUM_CUENTA);
        mcFitar.add(FEC_APE_CTA);
        mcFitar.add(BLQ1_CTA);
        mcFitar.add(SALDO);
        return mcFitar;
    }

}

