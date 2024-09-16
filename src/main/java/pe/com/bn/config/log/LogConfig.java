package pe.com.bn.config.log;

import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;

public class LogConfig {
    private static final Logger logger = Logger.getLogger(LogConfig.class);

    /**
     * Configura los archivos de log dinámicamente según las rutas proporcionadas.
     * @param logInfoPath Ruta del archivo de log para mensajes de nivel INFO.
     * @param logErrorPath Ruta del archivo de log para mensajes de nivel ERROR.
     */
    public static void configureLogFiles(String logInfoPath, String logErrorPath) {
        try {
            // Configurar el appender para INFO
            RollingFileAppender infoAppender = new RollingFileAppender();
            infoAppender.setName("A2");
            infoAppender.setFile(logInfoPath);
            infoAppender.setMaxFileSize("10MB");
            infoAppender.setMaxBackupIndex(5);
            infoAppender.setLayout(new PatternLayout("%d{ISO8601} %-5p %c %x - %m%n"));
            infoAppender.setThreshold(org.apache.log4j.Level.INFO);
            infoAppender.activateOptions();

            // Configurar el appender para ERROR
            RollingFileAppender errorAppender = new RollingFileAppender();
            errorAppender.setName("A3");
            errorAppender.setFile(logErrorPath);
            errorAppender.setMaxFileSize("10MB");
            errorAppender.setMaxBackupIndex(5);
            errorAppender.setLayout(new PatternLayout("%d{ISO8601} %-5p %c %x - %m%n"));
            errorAppender.setThreshold(org.apache.log4j.Level.ERROR);
            errorAppender.activateOptions();

            // Agregar los appenders al logger raíz
            Logger rootLogger = Logger.getRootLogger();
            rootLogger.addAppender(infoAppender);
            rootLogger.addAppender(errorAppender);

            logger.debug("Archivos de log configurados en: " + logInfoPath + " y " + logErrorPath);
        } catch (Exception e) {
            logger.error("Error al configurar los archivos de log dinámicamente", e);
        }
    }
}

