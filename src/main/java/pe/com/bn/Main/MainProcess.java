package pe.com.bn.Main;

import org.apache.log4j.Logger;
import pe.com.bn.config.ioc.ContenedorIoC;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.CargaTxtService;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
            log.error("Número insuficiente de argumentos. Se requieren 5 argumentos: " +
                    "<urlConection> <pathFile> <pathFileError> <typeProcess> <typeProcessMC>");
            System.out.println("FAILED");
            System.exit(1);
        }

        ContenedorIoC contenedor = new ContenedorIoC();
        contenedor.escanearPaquete("pe.com.bn");

        InputParametros inputParameter = contenedor.obtenerBean(InputParametros.class);

        inputParameter.setUrlConection(args[0]);
        inputParameter.setPathFile(args[1]);
        inputParameter.setPathFileFail(args[2]);
        inputParameter.setTypeProcess(args[3]);
        inputParameter.setTypeProcessMC(args[4]);
        try {
            validarParametros(inputParameter);
            log.info("Parámetros validados correctamente.");
            log.info(inputParameter);
        } catch (Exception e) {
            log.error("Error en validación de parámetros: " + e.getMessage());
            System.out.println("FAILED");
            System.exit(1);
        }

        CargaTxtService service = contenedor.obtenerBean(CargaTxtService.class);

        try {
            log.info("Inicio del proceso con los parámetros proporcionados.");

            ajustarFileMefResponse(inputParameter);
            service.process();
            log.info("Proceso completado exitosamente.");
            System.out.println("OK");
            System.exit(0);
        } catch (Exception e) {
            log.error("Error en el proceso: " + e.getMessage(), e);
            System.out.println("FAILED");
            System.exit(1);
        }
    }

    public static void ajustarFileMefResponse( InputParametros inputParameter){
        if ("2".equals(inputParameter.getTypeProcess())) {
            // Expresión regular para capturar el fragmento entre guiones bajos
            String regex = "_(\\d{2})_";

            Pattern pattern = Pattern.compile(regex);
            Matcher matcher = pattern.matcher(inputParameter.getPathFile());
            String result = "";
            if (matcher.find()) {
                result = matcher.group(1); // Captura el contenido entre los guiones bajos
            }
            inputParameter.setPathFileFail(inputParameter.getPathFileFail().replace("VAL_NN_BN", "VAL_" + result + "_BN"));
            log.info(inputParameter);
        }
    }

    /**
     * Método para validar los parámetros de entrada.
     */
    private static void validarParametros(InputParametros input) throws Exception {
        String regexUrl = "^[a-zA-Z0-9_]+/[a-zA-Z0-9_]+@//\\d{1,3}(\\.\\d{1,3}){3}:\\d{2,5}/[a-zA-Z0-9_]+$";
        Pattern patternUrl = Pattern.compile(regexUrl);

        if (!patternUrl.matcher(input.getUrlConection()).matches()) {
            throw new Exception("La URL de conexión no es válida: " + input.getUrlConection());
        }

        if (!input.getTypeProcess().equals("1") && !input.getTypeProcess().equals("2")) {
            throw new Exception("El typeProcess debe ser '1' o '2'. Valor proporcionado: " + input.getTypeProcess());
        }
        if (!input.getTypeProcessMC().equals("FICTA") && !input.getTypeProcessMC().isEmpty()) {
            throw new Exception("El typeProcessMC debe ser 'FICTA' o vacío. Valor proporcionado: " + input.getTypeProcessMC());
        }
    }
}
