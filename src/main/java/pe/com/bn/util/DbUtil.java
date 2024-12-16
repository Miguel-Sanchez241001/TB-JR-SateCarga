package pe.com.bn.util;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DbUtil {

    private static volatile DbUtil instance;  // Instancia Singleton con volatilidad
    private static Connection connection;

    // Constructor privado para evitar la instanciación externa
    private DbUtil(String dbUrl) throws SQLException {
        try {
            // Registrar manualmente el controlador JDBC de Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Extraer información de la URL de conexión
            String regex = "^(\\w+)/(\\w+)@//([^:]+):(\\d+)/(\\w+)$";
            Pattern pattern = Pattern.compile(regex);
            Matcher matcher = pattern.matcher(dbUrl);

            if (matcher.matches()) {
                String username = matcher.group(1);
                String password = matcher.group(2);
                String host = matcher.group(3);
                String port = matcher.group(4);
                String sid = matcher.group(5);

                // Crear la URL JDBC para la base de datos Oracle
                String jdbcUrl = "jdbc:oracle:thin:@" + host + ":" + port + ":" + sid;

                // Inicializar la conexión
                connection = DriverManager.getConnection(jdbcUrl, username, password);
                connection.setAutoCommit(false); // Desactivar autocommit para manejo manual de transacciones
            } else {
                throw new IllegalArgumentException("URL de conexión no válida: " + dbUrl);
            }
        } catch (ClassNotFoundException e) {
            throw new SQLException("Controlador JDBC de Oracle no encontrado", e);
        } catch (SQLException e) {
            throw new SQLException("Error al conectar con la base de datos", e);
        }
    }

    /**
     * Método para obtener la instancia Singleton de DbUtil.
     * @param dbUrl La URL de conexión en el formato "username/password@//ip:puerto/sid".
     * @return La instancia Singleton de DbUtil.
     * @throws SQLException Si ocurre un error al crear la conexión.
     */
    public static DbUtil getInstance(String dbUrl) throws SQLException {
        if (instance == null) {
            synchronized (DbUtil.class) {
                if (instance == null) {
                    instance = new DbUtil(dbUrl);
                }
            }
        }
        return instance;
    }

    /**
     * Realiza un INSERT por lotes en la base de datos utilizando Apache DbUtils.
     * @param sql La consulta SQL de inserción.
     * @param params Un arreglo de parámetros para el batch.
     * @return Un arreglo de enteros indicando el número de filas afectadas para cada batch.
     * @throws SQLException Si ocurre un error al ejecutar la consulta.
     */
    public int[] batchInsert(String sql, Object[][] params) throws SQLException {
        QueryRunner runner = new QueryRunner();
        try {
            int[] result = runner.batch(connection, sql, params);
            connection.commit(); // Confirmar la transacción
            return result;
        } catch (SQLException e) {
            connection.rollback(); // Revertir la transacción en caso de error
            throw e;
        }
    }

    /**
     * Realiza un INSERT en la base de datos utilizando Apache DbUtils.
     * @param sql La consulta SQL de inserción.
     * @param params Los parámetros de la consulta.
     * @return El número de filas afectadas.
     * @throws SQLException Si ocurre un error al ejecutar la consulta.
     */
    public int insert(String sql, Object... params) throws SQLException {
        QueryRunner runner = new QueryRunner();
        try {
            int result = runner.update(connection, sql, params);
            connection.commit(); // Confirmar la transacción
            return result;
        } catch (SQLException e) {
            connection.rollback(); // Revertir la transacción en caso de error
            throw e;
        }
    }


    public int ejecutarCount(String sql, Object... params) throws SQLException {
        QueryRunner runner = new QueryRunner();
        try {
            // Ejecuta la consulta con ScalarHandler para obtener el resultado
            BigDecimal result = runner.query(connection, sql, new ScalarHandler<BigDecimal>(), params);
            connection.commit(); // Confirmar la transacción
            return result != null ? result.intValue() : 0; // Retorna el valor como int
        } catch (SQLException e) {
            connection.rollback(); // Revertir en caso de error
            throw e;
        }
    }

    /**
     * Cierra la conexión de la base de datos.
     */
    public void close() {
        if (connection != null) {
            try {
                connection.close();
                connection = null; // Restablecer la conexión a null para el singleton
                instance = null; // Restablecer la instancia del singleton a null
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
