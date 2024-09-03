package pe.com.bn.Enum;
public enum TableType {
     RPTA_MC_TEMP("1", "BNSATE12_RPTA_MC_TEMP"),
     RPTA_MEF_TEMP("2", "BNSATE13_RPTA_MEF_TEMP");

    private final String tableNumber;
    private final String tableName;

    TableType(String tableNumber, String tableName) {
        this.tableNumber = tableNumber;
        this.tableName = tableName;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public String getTableName() {
        return tableName;
    }
}
