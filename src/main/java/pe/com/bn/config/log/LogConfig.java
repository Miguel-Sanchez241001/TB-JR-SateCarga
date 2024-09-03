package pe.com.bn.config.log;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.apache.log4j.RollingFileAppender;

public class LogConfig {
    private static final Logger logger = Logger.getLogger(LogConfig.class);

    /**
     * Configura el archivo de log dinámicamente según la ruta proporcionada.
     * @param logFilePath Ruta del archivo de log.
     */
    public static void configureLogFile(String logFilePath) {
        // Cargar la configuración de Log4j desde el archivo de propiedades en el classpath
        PropertyConfigurator.configure(LogConfig.class.getClassLoader().getResource("log4j.properties"));

        try {
            // Obtener el appender de archivo (A2) y configurar su ruta de archivo
            RollingFileAppender fileAppender = (RollingFileAppender) Logger.getRootLogger().getAppender("A2");
            if (fileAppender != null) {
                fileAppender.setFile(logFilePath);
                fileAppender.activateOptions(); // Reconfigura el appender con el nuevo archivo
                logger.info("Archivo de log configurado en: " + logFilePath);
            } else {
                logger.error("Appender de archivo no encontrado. Verifica la configuración.");
            }
        } catch (Exception e) {
            logger.error("Error al configurar el archivo de log dinámicamente", e);
        }
    }
}

