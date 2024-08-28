package pe.com.bn.Enum;
public enum TableType {
     RPTA_MC_TEMP(1, "BNSATE12_RPTA_MC_TEMP"),
     RPTA_MEF_TEMP(2, "BNSATE13_RPTA_MEF_TEMP");

    private final int tableNumber;
    private final String tableName;

    TableType(int tableNumber, String tableName) {
        this.tableNumber = tableNumber;
        this.tableName = tableName;
    }

    public int getTableNumber() {
        return tableNumber;
    }

    public String getTableName() {
        return tableName;
    }
}
