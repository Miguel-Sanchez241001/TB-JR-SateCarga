package pe.com.bn.Main;

import org.apache.log4j.Logger;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.CargaTxtService;

/**
 * User: Miguel Sanchez
 * Date: 7/05/13
 * Time: 6:50 AM
 */
public class MainProcess {
    private static final Logger log = Logger.getLogger(MainProcess.class);

    public static void main(String... args) {

        // Verificación del número de argumentos
        if (args.length < 5) {
            log.error("Número insuficiente de argumentos. Se requieren 6 argumentos: " +
                    "<urlConection> <pathFile>  <typeProcess> <typeProcessMC>");
            System.out.println("FAILED");
            System.exit(1); // Salida con código 1 indicando error
        }

        InputParametros inputParameter = new InputParametros();
        inputParameter.setUrlConection(args[0]);
        inputParameter.setPathFile(args[1]);
        inputParameter.setPathFileFail(args[2]);
        inputParameter.setTypeProcess(args[3]);
        inputParameter.setTypeProcessMC(args[4]);
        CargaTxtService service = new CargaTxtService();

        try {
            log.info("Inicio del proceso con los parámetros proporcionados.");
            service.process(inputParameter);
            log.info("Proceso completado exitosamente.");
            System.out.println("OK");
            System.exit(0);
        } catch (Exception e) {
            log.error("Error en el proceso: " + e.getMessage(), e);
            System.out.println("FAILED");
            System.exit(1);
        }
    }
}
