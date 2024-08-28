package pe.com.bn.Enum;

public enum Bnsate12RptaMcTemp {

    // Columnas de la tabla con nombre, posición de inicio, posición de fin, y si permite nulos
    TRACE("B12_TRACE", 0, 10, true),
    TIPO_DOC("B12_TIPO_DOCUMENTO", 10, 20, true),
    NUM_DOC("B12_NUMERO_DOCUMENTO", 20, 30, true),
    APELLIDOS("B12_APELLIDOS", 30, 50, true),
    NOMBRE("B12_NOMBRE", 50, 70, true),
    NUM_CUENTA("B12_NUMERO_CUENTA", 70, 90, true),
    FEC_APE_CTA("B12_FECHA_APERTURA_CUENTA", 90, 100, true),
    BLQ1_CTA("B12_BLOQUEO_1_CUENTA", 100, 110, true),
    BLQ2_CTA("B12_BLOQUEO_2_CUENTA", 110, 120, true),
    NUM_TARJ("B12_NUMERO_TARJETA", 120, 130, true),
    FEC_APE_TARJ("B12_FECHA_APERTURA_TARJETA", 130, 140, true),
    BLQ1_TARJ("B12_BLOQUEO_1_TARJETA", 140, 150, true),
    FEC_VENC_TARJ("B12_FECHA_VENCIMIENTO_TARJETA", 150, 160, true),
    COD_PROD("B12_CODIGO_PRODUCTO", 160, 170, true),
    LIN_CRED("B12_LINEA_CREDITO", 170, 180, true),
    TIPO_RESP("B12_TIPO_RESPUESTA", 180, 190, true),
    COD_BLQ("B12_CODIGO_BLOQUEO", 190, 200, true),
    MOT_BLQ("B12_MOTIVO_BLOQUEO", 200, 210, true),
    CEL("B12_CELULAR", 210, 220, true),
    EMAIL("B12_EMAIL", 220, 230, true),
    FEC_REG("B12_FECHA_REGISTRO", 230, 240, true),
    COD_ASIG("B12_CODIGO_ASIGNACION", 240, 250, true),
    FEC_INI_LIN("B12_FECHA_INICIO_LINEA", 250, 260, true),
    FEC_FIN_LIN("B12_FECHA_FIN_LINEA", 260, 270, true);

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

    // Nombre de la tabla asociado al enum
 }

