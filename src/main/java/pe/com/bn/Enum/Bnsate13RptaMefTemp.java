package pe.com.bn.Enum;

public enum Bnsate13RptaMefTemp {

    B13_SEC_OPERACION("B13_SEC_OPERACION", 1, 29, true),
    B13_TIPO_OPERACION("B13_TIPO_OPERACION", 30, 32, true),
    B13_RUC_MEF_TEMP("B13_RUC_MEF_TEMP", 33, 43, true),
    B13_CUENTA_CARGO("B13_CUENTA_CARGO", 44, 63, true),
    B13_FEC_INICIO_AUT("B13_FEC_INICIO_AUT", 64, 71, true),
    B13_FEC_FIN_AUT("B13_FEC_FIN_AUT", 72, 79, true),
    B13_TIPO_TARJETA("B13_TIPO_TARJETA", 80, 81, true),
    B13_MONEDA("B13_MONEDA", 82, 87, true),
    B13_IMPORTE("B13_IMPORTE", 88, 102, true),
    B13_TIPO_DOCUMENTO("B13_TIPO_DOCUMENTO", 103, 104, true),
    B13_NUM_DOCUMENTO("B13_NUM_DOCUMENTO", 105, 124, true),
     B13_FECHA_REGISTRO("B13_FECHA_REGISTRO", 0, 1, true);  // Temporalmente asignado 0, 1, ya que la fecha es generada
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

