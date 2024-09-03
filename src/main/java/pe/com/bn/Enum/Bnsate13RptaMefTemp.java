package pe.com.bn.Enum;

public enum Bnsate13RptaMefTemp {

    B13_SEC_OPERACION("B13_SEC_OPERACION", 0, 10, true),
    B13_TIPO_OPERACION("B13_TIPO_OPERACION", 10, 20, true),
    B13_CUENTA_CARGO("B13_CUENTA_CARGO", 20, 30, true),
    B13_TIPO_DOCUMENTO("B13_TIPO_DOCUMENTO", 30, 40, true),
    B13_NUM_DOCUMENTO("B13_NUM_DOCUMENTO", 40, 50, true),
    B13_NOMBRE_BENEFICIARIO("B13_NOMBRE_BENEFICIARIO", 50, 70, true),
    B13_NUM_TARJETA_AUT("B13_NUM_TARJETA_AUT", 70, 80, true),
    B13_FEC_INICIO_AUT("B13_FEC_INICIO_AUT", 80, 90, true),
    B13_FEC_FIN_AUT("B13_FEC_FIN_AUT", 90, 100, true),
    B13_IMPORTE("B13_IMPORTE", 100, 110, true),
    B13_SEC_OPERACION_REF("B13_SEC_OPERACION_REF", 110, 120, true),
    B13_FECHA_REGISTRO("B13_FECHA_REGISTRO", 120, 130, true);

    private final String columnName;
    private final int start;
    private final int end;
    private final boolean nullable;

    Bnsate13RptaMefTemp(String columnName, int start, int end, boolean nullable) {
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

    // Nombre de la tabla asociada a este enum
 }

