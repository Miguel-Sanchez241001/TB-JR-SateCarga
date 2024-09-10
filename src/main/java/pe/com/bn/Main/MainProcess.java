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

    public static void main(String... args)  {

        if (args.length < 5) {
            log.error("Número insuficiente de argumentos. Se requieren 4 argumentos:" +
                    " <urlConection>" +
                    " <pathFile> <pathLog> " +
                    "<typeProcess> <typeProcessMC> ");
            System.out.println("FAILED");
            System.exit(1); // Salida con código 1 indicando error
        }
        InputParametros inputParameter = new InputParametros();
        inputParameter.setUrlConection(args[0]);
        inputParameter.setPathFile(args[1]);
        inputParameter.setPathLog(args[2]);
        inputParameter.setTypeProcess(args[3]);
        inputParameter.setTypeProcessMC(args[4]);
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
//        try (
//                BufferedReader reader = new BufferedReader(new FileReader(args[1]));
//                BufferedWriter writer = new BufferedWriter(new FileWriter(args[2]))
//        ) {
//            String linea = reader.readLine(); // Leer la primera línea
//
//            // Mientras haya líneas en el archivo
//            while (linea != null) {
//                // Pasar la línea al método que valida
//
//                // Escribir la línea en el archivo de salida
//                writer.write(cumpleCondicion(linea));
//                writer.newLine();
//
//                // Leer la siguiente línea
//                linea = reader.readLine();
//            }
//
//            System.out.println("Archivo modificado correctamente.");
//        } catch (IOException e) {
//            System.err.println("Error al procesar el archivo: " + e.getMessage());
//        }
//
//    }

//    private static String cumpleCondicion(String linea) {
//        if (linea.contains("15743653") || linea.contains("10135089") || linea.contains("16727214")){
//            return linea + "6001";
//        }else{
//            return linea + "9999";
//        }
//
//
//
   }
}
