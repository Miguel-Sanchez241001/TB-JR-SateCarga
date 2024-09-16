package pe.com.bn.Main;

import org.apache.log4j.Logger;
import pe.com.bn.config.log.LogConfig;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.LoteService;

import java.io.*;

/**
 * User: Miguel Sanchez
 * Date: 7/05/13
 * Time: 6:50 AM
 */
public class MainProcess {
    private static final Logger log = Logger.getLogger(MainProcess.class);

    public static void main(String... args) {

        // Verificación del número de argumentos
        if (args.length < 6) {
            log.error("Número insuficiente de argumentos. Se requieren 6 argumentos: " +
                    "<urlConection> <pathFile> <pathLog> <pathLogError> <typeProcess> <typeProcessMC>");
            System.out.println("FAILED");
            System.exit(1); // Salida con código 1 indicando error
        }

        // Inicializar parámetros de entrada
        InputParametros inputParameter = new InputParametros();
        inputParameter.setUrlConection(args[0]);
        inputParameter.setPathFile(args[1]);
        inputParameter.setPathLog(args[2]);
        inputParameter.setPathLogError(args[3]);
        inputParameter.setTypeProcess(args[4]);
        inputParameter.setTypeProcessMC(args[5]);

        // Crear instancia del servicio
        LoteService service = new LoteService();

        try {
            log.info("Inicio de configuración de archivos de log.");
            LogConfig.configureLogFiles(inputParameter.getPathLog(), inputParameter.getPathLogError());
            log.info("Archivos de log configurados correctamente.");

            // Ejecutar el proceso
            log.info("Inicio del proceso con los parámetros proporcionados.");
            service.process(inputParameter);
            log.info("Proceso completado exitosamente.");

            // Indicar que el proceso finalizó correctamente
            System.out.println("OK");
            System.exit(0); // Salida con código 0 indicando éxito

        } catch (Exception e) {
            log.error("Error en el proceso: " + e.getMessage(), e);

            // Evitar mostrar detalles específicos del error en la salida estándar
            System.out.println("FAILED");
            System.exit(1); // Salida con código 1 indicando error
        }
    }
}
