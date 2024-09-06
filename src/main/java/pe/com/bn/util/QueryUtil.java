package pe.com.bn.util;

import pe.com.bn.Enum.Bnsate12RptaMcTemp;
import pe.com.bn.Enum.Bnsate13RptaMefTemp;
import pe.com.bn.Enum.TableType;

import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

public class QueryUtil {

    /**
     * Genera una consulta SQL de inserción para la tabla especificada.
     * @param tableType El tipo de tabla (definido en TableType enum).
     * @return La consulta SQL de inserción.
     */
    public static String generateInsertQuery(TableType tableType) {
        StringBuilder sql = new StringBuilder();
        StringBuilder columns = new StringBuilder();
        StringBuilder placeholders = new StringBuilder();

        // Dependiendo del tipo de tabla, obtenemos los nombres de columna correspondientes
        switch (tableType) {
            case RPTA_MC_TEMP: // Para la tabla BNSATE12_RPTA_MC_TEMP
                sql.append("INSERT INTO ").append(tableType.getTableName()).append(" (");

                for (Bnsate12RptaMcTemp field : Bnsate12RptaMcTemp.values()) {
                    columns.append(field.getColumnName()).append(", ");
                    placeholders.append("?, ");
                }
                break;

            case RPTA_MEF_TEMP: // Para la tabla BNSATE13_RPTA_MEF_TEMP
                sql.append("INSERT INTO ").append(tableType.getTableName()).append(" (");

                for (Bnsate13RptaMefTemp field : Bnsate13RptaMefTemp.values()) {
                    columns.append(field.getColumnName()).append(", ");
                    placeholders.append("?, ");
                }
                break;

            default:
                throw new IllegalArgumentException("Tipo de tabla no soportado: " + tableType);
        }

        // Eliminar la última coma y espacio extra
        if (columns.length() > 0) {
            columns.setLength(columns.length() - 2);
            placeholders.setLength(placeholders.length() - 2);
        }

        // Construye la consulta completa
        sql.append(columns).append(") VALUES (").append(placeholders).append(")");

        return sql.toString();
    }
    public static Date convertStringToSqlDate(String dateStr) throws ParseException {
        // Define el formato de la fecha
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        sdf.setLenient(false); // Asegúrate de que la fecha sea estrictamente valida
        // Convierte la cadena de fecha a java.util.Date
        java.util.Date date = sdf.parse(dateStr);
        // Convierte java.util.Date a java.sql.Date
        return new java.sql.Date(date.getTime());
    }
}
