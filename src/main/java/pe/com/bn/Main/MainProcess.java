package pe.com.bn.Main;

import org.apache.log4j.Logger;
import pe.com.bn.config.log.LogConfig;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.LoteService;
import pe.com.bn.util.DbUtil;

/**
 * User: Miguel Sanchez
 * Date: 7/05/13
 * Time: 6:50 AM
 */
public class MainProcess {
    private static final Logger log = Logger.getLogger(MainProcess.class);

    public static void main(String... args)  {

        if (args.length < 4) {
            log.error("Número insuficiente de argumentos. Se requieren 4 argumentos: <urlConection> <pathFile> <pathLog> <typeProcess>");
            System.out.println("FAILED");
            System.exit(1); // Salida con código 1 indicando error
        }
        InputParametros inputParameter = new InputParametros();
        inputParameter.setUrlConection(args[0]);
        inputParameter.setPathFile(args[1]);
        inputParameter.setPathLog(args[2]);
        inputParameter.setTypeProcess(args[3]);
        LoteService service = new LoteService();
        try {
            LogConfig.configureLogFile(inputParameter.getPathLog());

            // Ejecutar el proceso
            service.process(inputParameter);
            log.info("Proceso completado exitosamente.");
            System.out.println("OK"); // Imprimir OK si todo salió bien
            System.exit(0); // Salida con código 0 indicando éxito

        } catch (Exception e) {
            log.error("Error en el proceso: " + e.getMessage(), e);
            System.out.println("FAILED"); // Imprimir FAILED si ocurrió un error
            System.exit(1); // Salida con código 1 indicando error
        }
    }
}
